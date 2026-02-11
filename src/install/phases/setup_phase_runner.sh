#!/bin/bash
# --- run_setup_phase() — source first before other phase scripts ---
# Requires: CONTAINER_NAME, CONTAINER_HOME, USE_CLI_RUN, CLI_RUN_ENTRYPOINT, TUI_PREFIX, GATEWAY_BIND
# Optional: _cfg_token (for health/agent phases)

run_setup_phase() {
    local phase_name="$1"
    local cmd="$2"
    local timeout_sec="${3:-90}"
    local skip_header="${4:-}"
    local _ph_use_exec_for_gateway=0
    if [ -n "${USE_CLI_RUN:-}" ] && { [[ "$cmd" == *"health"* ]] || [[ "$cmd" == *"agent"* ]] || [[ "$cmd" == *"setup"* ]]; }; then
        _ph_use_exec_for_gateway=1
    fi
    if [ -n "${USE_CLI_RUN:-}" ] && [ ${#CLI_RUN_ENTRYPOINT[@]} -gt 0 ] && [[ "$cmd" == openclaw\ * ]] && [ "$_ph_use_exec_for_gateway" -eq 0 ]; then
        cmd="${cmd#openclaw }"
    fi
    local acc=$(get_accent)
    local _ph_fifo phase_debug_count=0 phase_output_count=0
    local _ph_max_timeout=$(( timeout_sec * 10 )) _ph_timeout_count=0 _ph_bg_pid
    _ph_fifo=""
    if [[ "$cmd" != *"setup"* ]] && [[ "$cmd" != *"config set"* ]] && [[ "$cmd" != *"health"* ]]; then
        _ph_fifo=$(mktemp -u 2>/dev/null || echo "/tmp/ph_fifo_$$")
        mkfifo "$_ph_fifo" 2>/dev/null || true
    fi
    [ -z "$skip_header" ] && printf "%b%s%b%b%b\n" "$acc" "$DIAMOND_FILLED" "$acc" "$phase_name" "$RESET"
    _ph_env=(-e OPENCLAW_BIND="${GATEWAY_BIND:-lan}")
    _ph_home="${CONTAINER_HOME:-/home/node}"
    _ph_env=(-e HOME="$_ph_home" "${_ph_env[@]}")
    if [[ "$cmd" == *"health"* ]] || [[ "$cmd" == *"agent"* ]]; then
        [ -n "${_cfg_token:-}" ] && _ph_env+=(-e OPENCLAW_GATEWAY_TOKEN="$_cfg_token")
    fi
    _ph_exec_u=()
    [[ "$_ph_home" == "/root" ]] && _ph_exec_u=(-u root)
    if [ "$_ph_use_exec_for_gateway" -eq 1 ]; then
        _ph_exec_prefix="docker exec $(printf '%s ' "${_ph_exec_u[@]}" "${_ph_env[@]}" | sed 's/OPENCLAW_GATEWAY_TOKEN=[^[:space:]]*/OPENCLAW_GATEWAY_TOKEN=***/g') \"$CONTAINER_NAME\" /bin/sh -c \""
        _ph_exec_debug="${_ph_exec_prefix}${cmd}\""
    elif [ -n "${USE_CLI_RUN:-}" ]; then
        if [ ${#CLI_RUN_ENTRYPOINT[@]} -gt 0 ]; then
            _ph_exec_prefix="docker compose run --rm -T $(printf '%s ' "${CLI_RUN_ENTRYPOINT[@]}") $(printf '%s ' "${_ph_env[@]}" | sed 's/OPENCLAW_GATEWAY_TOKEN=[^[:space:]]*/OPENCLAW_GATEWAY_TOKEN=***/g') openclaw-cli "
        else
            _ph_exec_prefix="docker compose run --rm -T $(printf '%s ' "${_ph_env[@]}" | sed 's/OPENCLAW_GATEWAY_TOKEN=[^[:space:]]*/OPENCLAW_GATEWAY_TOKEN=***/g') openclaw-cli /bin/sh -c \""
        fi
        if [ ${#CLI_RUN_ENTRYPOINT[@]} -gt 0 ]; then
            _ph_exec_debug="${_ph_exec_prefix}${cmd}"
        else
            _ph_exec_debug="${_ph_exec_prefix}${cmd}\""
        fi
    else
        _ph_exec_prefix="docker exec $(printf '%s ' "${_ph_exec_u[@]}" "${_ph_env[@]}" | sed 's/OPENCLAW_GATEWAY_TOKEN=[^[:space:]]*/OPENCLAW_GATEWAY_TOKEN=***/g') \"$CONTAINER_NAME\" /bin/sh -c \""
        _ph_exec_debug="${_ph_exec_prefix}${cmd}\""
    fi
    _ph_dbg_log="/tmp/ph_dbg_$$"
    { print_debug_cmd "$TUI_PREFIX" "$_ph_exec_debug"; } 2>&1 | tee "$_ph_dbg_log"
    phase_debug_count=$((phase_debug_count + $(wc -l < "$_ph_dbg_log" 2>/dev/null || echo 0)))
    rm -f "$_ph_dbg_log"
    if [ "$_ph_use_exec_for_gateway" -eq 1 ]; then
        printf "%b %b Container: %s\n" "$TUI_PREFIX" "${CYAN}[INFO]${RESET}" "$CONTAINER_NAME"
    elif [ -n "${USE_CLI_RUN:-}" ]; then
        printf "%b %b Using: docker compose run --rm -T openclaw-cli\n" "$TUI_PREFIX" "${CYAN}[INFO]${RESET}"
    else
        printf "%b %b Container: %s\n" "$TUI_PREFIX" "${CYAN}[INFO]${RESET}" "$CONTAINER_NAME"
    fi
    phase_debug_count=$((phase_debug_count + 1))
    if [[ "$cmd" == *"health"* ]] || [[ "$cmd" == *"agent"* ]]; then
        printf "%b %b Env: HOME=%s (match gateway) OPENCLAW_BIND=%s OPENCLAW_GATEWAY_TOKEN=***\n" "$TUI_PREFIX" "${CYAN}[INFO]${RESET}" "$_ph_home" "${GATEWAY_BIND:-lan}"
    else
        printf "%b %b Env: HOME=%s OPENCLAW_BIND=%s\n" "$TUI_PREFIX" "${CYAN}[INFO]${RESET}" "$_ph_home" "${GATEWAY_BIND:-lan}"
    fi
    phase_debug_count=$((phase_debug_count + 1))
    printf "%b %b Starting subprocess...\n" "$TUI_PREFIX" "${CYAN}[INFO]${RESET}"
    phase_debug_count=$((phase_debug_count + 1))
    if [ -n "$_ph_fifo" ] && [ -p "$_ph_fifo" ]; then
        printf '\033[?25l'
        if [ "$_ph_use_exec_for_gateway" -eq 1 ]; then
            ( docker exec "${_ph_exec_u[@]}" "${_ph_env[@]}" "$CONTAINER_NAME" /bin/sh -c "$cmd" 2>&1; echo "__PHASE_DONE__" ) > "$_ph_fifo" &
        elif [ -n "${USE_CLI_RUN:-}" ]; then
            if [ ${#CLI_RUN_ENTRYPOINT[@]} -gt 0 ]; then
                ( docker compose run --rm -T "${CLI_RUN_ENTRYPOINT[@]}" "${_ph_env[@]}" openclaw-cli $cmd 2>&1; echo "__PHASE_DONE__" ) > "$_ph_fifo" &
            else
                ( docker compose run --rm -T "${_ph_env[@]}" openclaw-cli /bin/sh -c "$cmd" 2>&1; echo "__PHASE_DONE__" ) > "$_ph_fifo" &
            fi
        else
            ( docker exec "${_ph_exec_u[@]}" "${_ph_env[@]}" "$CONTAINER_NAME" /bin/sh -c "$cmd" 2>&1; echo "__PHASE_DONE__" ) > "$_ph_fifo" &
        fi
        _ph_bg_pid=$!
        disown $_ph_bg_pid 2>/dev/null || true
        exec 3< "$_ph_fifo"
        while true; do
            if read -t 0.1 -u 3 -r line 2>/dev/null; then
                _ph_timeout_count=0
                [ "$line" = "__PHASE_DONE__" ] && break
                clean_line=$(echo "$line" | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
                clean_line="${clean_line#$'\r'}"; [[ "$clean_line" =~ ^[✔✓x](.*) ]] && clean_line="${BASH_REMATCH[1]}"
                [ -z "$clean_line" ] && continue
                _phase_plain_ok=0
                out_prefix="${CYAN}[INFO]${RESET}"
                out_color="$CYAN"
                if [[ "$clean_line" =~ ^[[:space:]]*Workspace[[:space:]]OK: ]] || [[ "$clean_line" =~ ^[[:space:]]*Sessions[[:space:]]OK: ]]; then
                    out_prefix="${GREEN}[ OK ]${RESET}"
                    out_color="${GREEN}"
                    _phase_plain_ok=1
                fi
                if [[ "$clean_line" =~ "Failed to discover Ollama" ]]; then
                    out_prefix="${RED}[ERROR]${RESET}"
                    out_color="${RED}"
                fi
                if [[ "$clean_line" =~ "Failed to discover Ollama" ]] && [[ "$clean_line" =~ "fetch failed" ]]; then
                    printf "%b %b %b%s%b\n" "$TUI_PREFIX" "$out_prefix" "$out_color" "$clean_line" "$RESET"
                    printf "%b %b%s%b\n" "$TUI_PREFIX" "$DIM" "Ensure Ollama is running on the host and reachable (host.docker.internal:11434)." "$RESET"
                    phase_output_count=$((phase_output_count + 2))
                    continue
                fi
                if [[ "$clean_line" =~ [eE][rR][rR][oO][rR] ]]; then
                    out_prefix="${RED}[ERROR]${RESET}"
                    out_color="${RED}"
                elif [[ "$clean_line" =~ "Error" ]] || [[ "$clean_line" =~ "Fail" ]] || [[ "$clean_line" =~ "err" ]]; then
                    out_prefix="${RED}[FAIL]${RESET}"
                    out_color="${RED}"
                elif [[ "$clean_line" =~ "Success" ]] || [[ "$clean_line" =~ "Done" ]] || [[ "$clean_line" =~ "Complete" ]] || [[ "$clean_line" =~ "passed" ]]; then
                    out_prefix="${GREEN}[ OK ]${RESET}"
                    out_color="${GREEN}"
                elif [[ "$clean_line" =~ "Warn" ]]; then
                    out_prefix="${YELLOW}[WARN]${RESET}"
                    out_color="${YELLOW}"
                fi
                if [ "$_phase_plain_ok" = "1" ]; then
                    printf "%b %b %s\n" "$TUI_PREFIX" "$out_prefix" "$clean_line"
                elif [[ "$out_prefix" = *"[INFO]"* ]]; then
                    printf "%b %b %s\n" "$TUI_PREFIX" "$out_prefix" "$clean_line"
                else
                    printf "%b %b %b%s%b\n" "$TUI_PREFIX" "$out_prefix" "$out_color" "$clean_line" "$RESET"
                fi
                phase_output_count=$((phase_output_count + 1))
            else
                _ph_timeout_count=$((_ph_timeout_count + 1))
                if [ "$_ph_timeout_count" -ge "$_ph_max_timeout" ]; then
                    printf "\033[?25h"
                    printf "%b %b %bPhase timed out (%ds) - continuing.%b\n" "$TUI_PREFIX" "${YELLOW}[WARN]${RESET}" "$YELLOW" "$timeout_sec" "$RESET" >&2
                    phase_output_count=$((phase_output_count + 1))
                    kill "$_ph_bg_pid" 2>/dev/null || true
                    break
                fi
            fi
        done
        exec 3<&-
        rm -f "$_ph_fifo"
        wait 2>/dev/null || true
        printf "\033[?25h"
    else
        _ph_out_log="/tmp/ph_out_$$"
        if [ "$_ph_use_exec_for_gateway" -eq 1 ]; then
            docker exec "${_ph_exec_u[@]}" "${_ph_env[@]}" "$CONTAINER_NAME" /bin/sh -c "$cmd" 2>&1 > "$_ph_out_log" || true
        elif [ -n "${USE_CLI_RUN:-}" ]; then
            if [ ${#CLI_RUN_ENTRYPOINT[@]} -gt 0 ]; then
                docker compose run --rm -T "${CLI_RUN_ENTRYPOINT[@]}" "${_ph_env[@]}" openclaw-cli $cmd 2>&1 > "$_ph_out_log" || true
            else
                docker compose run --rm -T "${_ph_env[@]}" openclaw-cli /bin/sh -c "$cmd" 2>&1 > "$_ph_out_log" || true
            fi
        else
            docker exec "${_ph_exec_u[@]}" "${_ph_env[@]}" "$CONTAINER_NAME" /bin/sh -c "$cmd" 2>&1 > "$_ph_out_log" || true
        fi
        phase_output_count=0
        while IFS= read -r line; do
            clean_line=$(echo "$line" | sed 's/^[[:space:]]*//' | sed 's/[[:space:]]*$//')
            clean_line="${clean_line#$'\r'}"; [[ "$clean_line" =~ ^[✔✓x](.*) ]] && clean_line="${BASH_REMATCH[1]}"
            [ -z "$clean_line" ] && continue
            _phase_plain_ok=0
            out_prefix="${CYAN}[INFO]${RESET}"
            out_color="$CYAN"
            if [[ "$clean_line" =~ ^[[:space:]]*Workspace[[:space:]]OK: ]] || [[ "$clean_line" =~ ^[[:space:]]*Sessions[[:space:]]OK: ]]; then
                out_prefix="${GREEN}[ OK ]${RESET}"
                out_color="${GREEN}"
                _phase_plain_ok=1
            fi
            if [[ "$clean_line" =~ "Failed to discover Ollama" ]]; then out_prefix="${RED}[ERROR]${RESET}"; out_color="${RED}"; fi
            if [[ "$clean_line" =~ "Failed to discover Ollama" ]] && [[ "$clean_line" =~ "fetch failed" ]]; then
                printf "%b %b %b%s%b\n" "$TUI_PREFIX" "$out_prefix" "$out_color" "$clean_line" "$RESET"
                printf "%b %b%s%b\n" "$TUI_PREFIX" "$DIM" "Ensure Ollama is running on the host and reachable (host.docker.internal:11434)." "$RESET"
                phase_output_count=$((phase_output_count + 2))
                continue
            fi
            if [[ "$clean_line" =~ [eE][rR][rR][oO][rR] ]]; then out_prefix="${RED}[ERROR]${RESET}"; out_color="${RED}"
            elif [[ "$clean_line" =~ "Error" ]] || [[ "$clean_line" =~ "Fail" ]] || [[ "$clean_line" =~ "err" ]]; then out_prefix="${RED}[FAIL]${RESET}"; out_color="${RED}"; fi
            if [[ "$clean_line" =~ "Success" ]] || [[ "$clean_line" =~ "Done" ]] || [[ "$clean_line" =~ "Complete" ]] || [[ "$clean_line" =~ "passed" ]]; then out_prefix="${GREEN}[ OK ]${RESET}"; out_color="${GREEN}"; fi
            if [[ "$clean_line" =~ "Warn" ]]; then out_prefix="${YELLOW}[WARN]${RESET}"; out_color="${YELLOW}"; fi
            if [ "$_phase_plain_ok" = "1" ]; then
                printf "%b %b %s\n" "$TUI_PREFIX" "$out_prefix" "$clean_line"
            elif [[ "$out_prefix" = *"[INFO]"* ]]; then
                printf "%b %b %s\n" "$TUI_PREFIX" "$out_prefix" "$clean_line"
            else
                printf "%b %b %b%s%b\n" "$TUI_PREFIX" "$out_prefix" "$out_color" "$clean_line" "$RESET"
            fi
            phase_output_count=$((phase_output_count + 1))
        done < "$_ph_out_log"
        rm -f "$_ph_out_log"
    fi
    local _ph_total=$((1 + phase_debug_count + phase_output_count))
    printf "\033[${_ph_total}A\r\033[K"
    printf "%b%s%b%b%b\033[K\n" "$acc" "$DIAMOND_EMPTY" "$acc" "$phase_name" "$RESET"
    printf "\033[$(($_ph_total - 1))B"
}
