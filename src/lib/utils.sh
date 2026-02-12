#!/bin/bash

# --- Utility Functions for Clawfather ---

# Global OS Detection (Detect early for tools like sed)
OS_TYPE="unknown"
OS_NAME="$(uname -s)"
case "$OS_NAME" in
    Darwin) OS_TYPE="macos" ;;
    Linux)  OS_TYPE="linux"; [ -f /etc/os-release ] && . /etc/os-release && [ -n "$ID" ] && DISTRO=$ID || DISTRO="unknown" ;;
esac

# Cross-platform sed
sed_inplace() {
    if [ "$OS_TYPE" == "macos" ]; then
        sed -i '' "$@"
    else
        sed -i "$@"
    fi
}

# Helper for non-interactive prompts
ask_prompt() {
    local prompt="$1"
    local default="$2"
    local var_result="$3"
    local input
    
    if [ "$YES_TO_ALL" = true ]; then
        eval "$var_result=\"$default\""
        printf "   %s [%s]: %b(auto)%b\n" "$prompt" "$default" "$CYAN" "$RESET"
    else
        read -p "   $prompt [$default]: " input
        eval "$var_result=\"${input:-$default}\""
    fi
}

# Status wrappers (rely on ywizz/info.sh & ywizz/header.sh)
# $1=title, $2=wizard (optional, "1" = chained style; active section uses ◆)
header() { header_tui "$1" "" "${2:-0}"; }

# Mask secrets (tokens, API keys, passwords) in command string before debug print.
# AGENTS.md: Mask secrets as *** in the printed command.
_mask_debug_secrets() {
    local cmd="$1"
    [ -z "$cmd" ] && return
    # --gateway-token, --gateway-password, --password, --*-api-key VALUE (space or =)
    cmd=$(echo "$cmd" | sed -E 's/--(gateway-token|gateway-password|password|anthropic-api-key|gemini-api-key|zai-api-key|openai-api-key|ollama-api-key)([[:space:]]*=[[:space:]]*|[[:space:]]+)([^[:space:]]+|"[^"]*"|'"'"'[^'"'"']*'"'"')/--\1 ***/g')
    # -e VAR=value for vars containing KEY, TOKEN, SECRET, PASSWORD
    cmd=$(echo "$cmd" | sed -E 's/(-e )([A-Za-z0-9_]*(KEY|TOKEN|SECRET|PASSWORD)=)([^[:space:]]+|"[^"]*"|'"'"'[^'"'"']*'"'"')/\1\2***/g')
    echo "$cmd"
}

# Format long docker exec commands with newlines per logical part (for debug output)
format_debug_cmd() {
    local cmd="$1"
    if [[ "$cmd" != *"docker exec"* ]]; then
        echo "$cmd"
        return
    fi
    # Continuation lines: indent so content starts after "│  [DEBUG] Command:" (wall + " " = 2, so indent = 17 to align at column 20)
    local result="" rest="$cmd" indent="                 "
    if [[ "$rest" =~ ^(docker exec)(.*) ]]; then
        result="${BASH_REMATCH[1]}"
        rest="${BASH_REMATCH[2]# }"
    fi
    while [[ "$rest" =~ ^(-[ti]|-[ti][ti])([[:space:]]*)(.*) ]] \
       || [[ "$rest" =~ ^(-e[[:space:]]+[^[:space:]]+)([[:space:]]*)(.*) ]] \
       || [[ "$rest" =~ ^(-u[[:space:]]+[^[:space:]]+)([[:space:]]*)(.*) ]] \
       || [[ "$rest" =~ ^(--user[[:space:]]+[^[:space:]]+)([[:space:]]*)(.*) ]]; do
        result="${result} ${BASH_REMATCH[1]}"
        rest="${BASH_REMATCH[3]# }"
    done
    result=$(echo "$result" | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
    if [[ "$rest" =~ ^(\"[^\"]+\"|[^[:space:]]+)[[:space:]]+(/bin/sh[[:space:]]+-c[[:space:]]+)(.*) ]]; then
        local cid_part="${BASH_REMATCH[1]}" sh_part="${BASH_REMATCH[2]}" payload="${BASH_REMATCH[3]}"
        local body_indented=""
        # If payload is a long quoted string, break at "; " for readable debug output
        if [[ "$payload" =~ ^\"(.*)\"$ ]]; then
            local inner="${BASH_REMATCH[1]}" seg
            local first=1
            while [[ -n "$inner" ]]; do
                if [[ "$inner" == *"; "* ]]; then
                    seg="${inner%%; *}"
                    inner="${inner#*; }"
                    seg=$(echo "$seg" | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
                else
                    seg=$(echo "$inner" | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
                    inner=""
                fi
                [ -n "$seg" ] && {
                    if [ "$first" -eq 1 ]; then
                        body_indented="${indent}${sh_part}\"${seg}"
                        first=0
                    else
                        body_indented="${body_indented};
${indent}${seg}"
                    fi
                }
            done
            [ "$first" -eq 0 ] && body_indented="${body_indented}\""
        fi
        [ -z "$body_indented" ] && {
            local body_part="${sh_part}${payload}"
            while IFS= read -r bline; do
                [ -z "$body_indented" ] && body_indented="${indent}${bline}" || body_indented="${body_indented}
${indent}${bline}"
            done <<< "$body_part"
        }
        result="${result}
${indent}${cid_part}
${body_indented}"
    elif [[ "$rest" =~ ^(\"[^\"]+\"|[^[:space:]]+)[[:space:]]+(.+)$ ]]; then
        local cid="${BASH_REMATCH[1]}" body="${BASH_REMATCH[2]}"
        result="${result}
${indent}${cid}"
        # Indent each line of body so multi-line sh -c "..." payloads align
        indent_body_lines() {
            local b="$1" out=""
            while IFS= read -r bl; do
                [ -z "$out" ] && out="${indent}${bl}" || out="${out}
${indent}${bl}"
            done <<< "$b"
            echo "$out"
        }
        if [[ "$body" == *" --"* ]]; then
            result="${result}
$(indent_body_lines "${body%% --*}")"
            local tail="${body#* --}"
            while [[ -n "$tail" ]]; do
                local part
                [[ "$tail" == *" --"* ]] && { part="--${tail%% --*}"; tail="${tail#* --}"; } || { part="--${tail}"; tail=""; }
                result="${result}
$(indent_body_lines "$part")"
            done
        else
            result="${result}
$(indent_body_lines "$body")"
        fi
    else
        result="${result}
${indent}${rest}"
    fi
    echo "$result"
}

# Wrap a long line at word boundaries for small terminals.
# Never break inside a quoted string (e.g. container ID).
# $1=line, $2=max width (default 72), $3=continuation indent (default 4 spaces)
_wrap_debug_line() {
    local line="$1" width="${2:-72}" cont_indent="${3:-    }"
    # Single quoted token (e.g. container ID): never wrap
    [[ "$line" =~ ^\"[^\"]*\"$ ]] && { echo "$line"; return; }
    # sh -c "..." payload: never wrap (avoids breaking inside nested quotes)
    [[ "$line" == 'sh -c "'* ]] && { echo "$line"; return; }
    [ ${#line} -le "$width" ] && { echo "$line"; return; }
    while [ -n "$line" ]; do
        line=$(echo "$line" | sed 's/^[[:space:]]*//')
        [ -z "$line" ] && break
        if [ ${#line} -le "$width" ]; then
            echo "$line"
            break
        fi
        local chunk="${line:0:$width}"
        local break_at=
        # If chunk has odd number of ", we're inside a quoted string: break after the closing "
        local nquotes=0
        local i
        for (( i=0; i < ${#chunk}; i++ )); do
            [[ "${chunk:$i:1}" == '"' ]] && nquotes=$((nquotes + 1))
        done
        if [ "$((nquotes % 2))" -eq 1 ]; then
            # Find closing " (first " after the opening one)
            local rest="${line:${#chunk}}"
            local close_pos=
            for (( i=0; i <= ${#rest}; i++ )); do
                [[ "${rest:$i:1}" == '"' ]] && { close_pos=$((${#chunk} + i)); break; }
            done
            if [ -n "$close_pos" ]; then
                break_at=$((close_pos + 1))
            fi
        fi
        if [ -z "$break_at" ]; then
            if [[ "$chunk" =~ ^(.*)[[:space:]]([^[:space:]]*)$ ]]; then
                break_at=$((${#BASH_REMATCH[1]} + 1))
            else
                break_at=$width
            fi
        fi
        echo "${line:0:$break_at}"
        line="${cont_indent}${line:$break_at}"
    done
}

# Dimmed accent for the command text (when available from install); fallback to DIM
_debug_cmd_color() { printf '%b' "${dim_color:-$DIM}"; }

# Print debug command with │ wall and orange [DEBUG] tag; command part in dimmed accent
# Single-line commands (e.g. node ... config set key value) print on one line; docker exec output is wrapped.
# Only prints when INSTALL_DEBUG is set (install_clawfather.sh -d|--debug).
print_debug_cmd() {
    [ -z "${INSTALL_DEBUG:-}" ] && return 0
    local wall="$1" cmd="$2" formatted
    cmd=$(_mask_debug_secrets "$cmd")
    local _cmd_color
    _cmd_color=$(_debug_cmd_color)
    # Debug label should stand out (orange); fall back to yellow if theme isn't loaded.
    local _dbg_tag_color="${ORANGE:-$YELLOW}"
    formatted=$(format_debug_cmd "$cmd")
    # Continuation lines align after "│  [DEBUG] Command:" (17 spaces after "│  ")
    local _debug_indent="                 "
    # If formatted is a single line (no newline), print on one line without wrapping
    if [[ "$formatted" != *$'\n'* ]]; then
        local line
        line=$(echo "$formatted" | sed 's/[[:space:]]*$//')
        [ -n "$line" ] && printf "%b %b[DEBUG]%b Debug Command: %b%s%b\n" "$wall" "$_dbg_tag_color" "$RESET" "$_cmd_color" "$line" "$RESET"
        return
    fi
    local max_width=${COLUMNS:-72}
    [ "$max_width" -gt 72 ] && max_width=72
    [ "$max_width" -lt 40 ] && max_width=40
    local first=1
    set +e
    while IFS= read -r line; do
        # Preserve leading indent (from format_debug_cmd) so continuation aligns after "Command:"
        local lead_indent=""
        [[ "$line" =~ ^([[:space:]]+)(.*) ]] && lead_indent="${BASH_REMATCH[1]}" && line="${BASH_REMATCH[2]}"
        line=$(echo "$line" | sed 's/[[:space:]]*$//')
        [ -z "$line" ] && continue
        local _wrap_width=$max_width
        [ -n "$lead_indent" ] && _wrap_width=$((max_width - ${#lead_indent}))
        [ "$_wrap_width" -lt 20 ] && _wrap_width=20
        # When wrapping the first line (no lead_indent), use 17 spaces so continuation aligns under "Command:"
        local _cont_indent="    "
        [ "$first" -eq 1 ] && [ -z "$lead_indent" ] && _cont_indent="                 "
        local _wrapped
        _wrapped=$(_wrap_debug_line "$line" "$_wrap_width" "$_cont_indent")
        local _wrapped_first=1
        while IFS= read -r wrapped_line; do
            [ -z "$wrapped_line" ] && continue
            [ -n "$lead_indent" ] && [ "$_wrapped_first" -eq 1 ] && wrapped_line="${lead_indent}${wrapped_line}" && _wrapped_first=0
            if [ "$first" -eq 1 ]; then
                printf "%b %b[DEBUG]%b Debug Command: %b%s%b\n" "$wall" "$_dbg_tag_color" "$RESET" "$_cmd_color" "$wrapped_line" "$RESET"
                first=0
            else
                # Always align continuation content under "Command:" (strip leading spaces then add standard indent)
                local _trimmed
                _trimmed=$(echo "$wrapped_line" | sed 's/^[[:space:]]*//')
                printf "%b %b%s%s%b\n" "$wall" "$_cmd_color" "$_debug_indent" "$_trimmed" "$RESET"
            fi
        done <<< "$_wrapped"
    done <<< "$formatted"
    set -e
    if [ "$first" -eq 1 ]; then
        printf "%b %b[DEBUG]%b Debug Command: %b%s%b\n" "$wall" "$_dbg_tag_color" "$RESET" "$_cmd_color" "$cmd" "$RESET"
    fi
}

ensure_docker_running() {
    # Ensure docker is in path for this function scope (macOS locations + fallback)
    export PATH=$PATH:/usr/local/bin:/opt/homebrew/bin:/Applications/Docker.app/Contents/Resources/bin
    
    if ! docker info >/dev/null 2>&1; then
        # Check if we are on macOS
        if [ "$(uname -s)" == "Darwin" ]; then
             info "Starting Docker Desktop..."
             open -a Docker
             
            # Wait for Docker to start (up to ~2 mins)
            local retries=60
            local wait_s=2
            printf "   %bWaiting for Docker to start...%b " "$CYAN" "$RESET"
            
            for ((i=0; i<retries; i++)); do
                # Check if daemon is responding
                if docker info >/dev/null 2>&1; then
                    # Add a space before the final status so the last '+' doesn't touch '[ OK ]'
                    printf " %b[ OK ]%b\n" "$GREEN" "$RESET"
                    success "Docker Desktop is running."
                    return 0
                fi
                 
                 # Visual feedback: . for wait, + if app detected but daemon not ready
                 # More robust pgrep for macOS
                 if pgrep -f "Docker.app" >/dev/null || [ -S "/var/run/docker.sock" ]; then
                     printf "+"
                 else
                     printf "."
                 fi
                 
                 sleep $wait_s
             done
             printf "\n"
             
             # Diagnostics
             if pgrep -f "Docker.app" >/dev/null; then
                 error "Docker App is running, but CLI cannot connect."
                 warn "Error details: $(docker info 2>&1 | head -n 1)"
             else
                 error "Docker App process not detected."
             fi
             
             error "Docker failed to start within timeout."
             return 1
        else
             if command -v systemctl >/dev/null 2>&1; then
                 warn "Docker daemon is not running. Attempting to start service..."
                 sudo systemctl start docker
                 sleep 3
                 if docker info >/dev/null 2>&1; then
                     success "Docker service started."
                     return 0
                 fi
             fi
             error "Docker daemon is not running. Please start it manually."
             return 1
        fi
    fi
}
