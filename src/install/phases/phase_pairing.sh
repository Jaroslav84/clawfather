#!/bin/bash
# --- Phase: Dashboard URL, approve loops, secure gateway ---
# Requires: CONTAINER_NAME, CONTAINER_HOME, OPENCLAW_CMD, _cfg_port, _cfg_token (from phase_config)

run_phase_pairing() {
    _INSTALL_AUTO_YES_SAVED="${INSTALL_AUTO_YES:-}"
    unset INSTALL_AUTO_YES
    header_tui "Open this URL in your browser" "" "1"
    _ph4_lines=1
    PAIR_URL="http://localhost:${_cfg_port}/?token=${_cfg_token}"
    printf "%b%s %b👉 %b%s%b\n" "$accent_color" "$TREE_MID" "$BOLD" "$CYAN" "$PAIR_URL" "$RESET"
    _ph4_lines=$((_ph4_lines + 1))
    while true; do
        sleep 0.5
        for _d in 1 2 3 4 5; do
            while read -r -t 0.1 -n 10000 discard; do :; done 2>/dev/null || true
            while read -r -t 0 -n 10000 discard; do read -r discard; done 2>/dev/null || true
        done
        select_tui "Dashboard loaded?" "Yes, proceed to pairing
No, page is not loading" "" "" "DASH_LOADED" 0 "true" 1 0 2000
        _ph4_lines=$((_ph4_lines + 2))
        if [[ "$DASH_LOADED" == *"Yes"* ]]; then
            break
        else
            warn "Please check if the container is running and port ${_cfg_port} is accessible."
            _ph4_lines=$((_ph4_lines + 1))
            ask_yes_no_tui "Try again?" "y" "RETRY_DASH" 1 0
            _ph4_lines=$((_ph4_lines + 2))
            if [[ "$RETRY_DASH" == "n" ]]; then
                fail_install "Gateway requires browser pairing."
            fi
        fi
    done
    printf "\033[${_ph4_lines}A\r\033[K"
    printf "%b%s%b%b%b\033[K\n" "$(get_accent)" "$DIAMOND_EMPTY" "$(get_accent)" "Open this URL in your browser" "$RESET"
    printf "\033[$(($_ph4_lines - 1))B"
    [ -n "${_INSTALL_AUTO_YES_SAVED:-}" ] && INSTALL_AUTO_YES="$_INSTALL_AUTO_YES_SAVED"

    header_tui "Pairing (1 of 2): grabbing devices" "" "1"
    _ph5_lines=1
    if ! docker inspect "$CONTAINER_NAME" --format '{{.State.Status}}' 2>/dev/null | grep -q "running"; then
        fail_install "Gateway container ($GATEWAY_SERVICE) is not running!"
    fi
    _ph5_env=(-e HOME="${CONTAINER_HOME:-/home/node}" -e OPENCLAW_BIND="${GATEWAY_BIND:-lan}")
    _ph5_pair_url="ws://127.0.0.1:${_cfg_port}"
    _ph5_pair_succeeded=0
    info "Checking for paired devices.."
    _ph5_lines=$((_ph5_lines + 1))
    if [ -n "${INSTALL_DEBUG:-}" ]; then
        _pair_probe=$(docker exec "${_ph5_env[@]}" "$CONTAINER_NAME" $OPENCLAW_CMD devices list --url "$_ph5_pair_url" --token "${_cfg_token:-}" 2>&1) || true
        if [ -n "$_pair_probe" ]; then
            printf '%s\n' "$_pair_probe" | head -12 | while read -r _line; do
                [ -n "$_line" ] && printf "%b %b %s\n" "$TUI_PREFIX" "${DIM}[devices]${RESET}" "$_line"
            done
            _ph5_lines=$((_ph5_lines + $(printf '%s\n' "$_pair_probe" | head -12 | wc -l | tr -d ' ')))
        else
            printf "%b %b %b(devices list returned empty — check gateway and token)%b\n" "$TUI_PREFIX" "${DIM}[devices]${RESET}" "$DIM" "$RESET"
            _ph5_lines=$((_ph5_lines + 1))
        fi
    fi
    _pair_ids_line=$(
        docker exec "${_ph5_env[@]}" "$CONTAINER_NAME" sh -c \
            "$OPENCLAW_CMD devices list --json --url \"$_ph5_pair_url\" --token \"${_cfg_token:-}\" 2>/dev/null | node -e 'const fs=require(\"fs\");let d;try{d=JSON.parse(fs.readFileSync(0,\"utf8\"));}catch(e){process.exit(0);}const pending=(d.pending||[]).map(p=>p.requestId).filter(Boolean);const approved=(d.approved||[]).map(a=>a.id||a.deviceId||a.requestId).filter(Boolean);const ids=[...new Set([...pending,...approved])];if(ids.length) console.log(\"Grabbed device IDs: \"+ids.join(\", \"));' 2>/dev/null" \
            2>/dev/null
    ) || true
    if [ -n "${_pair_ids_line:-}" ]; then
        printf "%b %b %s\n" "$TUI_PREFIX" "${CYAN}[INFO]${RESET}" "$_pair_ids_line"
        _ph5_lines=$((_ph5_lines + 1))
    fi
    PAIR_CHECK_CMD="docker exec $(printf '%s ' "${_ph5_env[@]}") \"$CONTAINER_NAME\" sh -c \"$OPENCLAW_CMD devices list --json --url \\\"$_ph5_pair_url\\\" --token \\\"${_cfg_token:-}\\\" | node -e \\\"JSON.parse(require('fs').readFileSync(0)).pending.forEach(p => console.log(p.requestId))\\\" 2>/dev/null | while read id; do [ -n \\\"\\\$id\\\" ] && $OPENCLAW_CMD devices approve \\\"\\\$id\\\" --url \\\"$_ph5_pair_url\\\" --token \\\"${_cfg_token:-}\\\"; done; $OPENCLAW_CMD devices list --url \\\"$_ph5_pair_url\\\" --token \\\"${_cfg_token:-}\\\" | grep -q 'Paired ([1-9])'\""
    _ph5_dbg_log="/tmp/ph5_dbg_$$"
    { print_debug_cmd "$(printf "%b%s%b" "$accent_color" "$TREE_MID" "$RESET")" "$PAIR_CHECK_CMD"; } 2>&1 | tee "$_ph5_dbg_log"
    _ph5_lines=$((_ph5_lines + $(wc -l < "$_ph5_dbg_log" 2>/dev/null || echo 0)))
    rm -f "$_ph5_dbg_log"
    _pair_ret_file="/tmp/pr_$$"
    PAIR_WRAPPER='( ( eval "$PAIR_CHECK_CMD" 2>&1; echo $? > "'"$_pair_ret_file"'") | while read -r line; do if [[ "$line" == Approved* ]]; then printf "%b %b %b%s%b\n" "$TUI_PREFIX" "${GREEN}[ OK ]${RESET}" "$GREEN" "$line" "$RESET"; fi; done; _r=$(cat "'"$_pair_ret_file"'" 2>/dev/null || echo 1); exit "$_r" )'
    while true; do
        set +e
        wait_for_condition_tui "Waiting for pairing..." "$PAIR_WRAPPER" 30
        _pair_wait_rc=$?
        set -e
        _ph5_lines=$((_ph5_lines + 1))
        rm -f "$_pair_ret_file" 2>/dev/null || true
        if [ "$_pair_wait_rc" -eq 0 ]; then
            _ph5_pair_succeeded=1
            if [ -n "${INSTALL_DEBUG:-}" ]; then
                docker exec "${_ph5_env[@]}" "$CONTAINER_NAME" $OPENCLAW_CMD devices list --url "$_ph5_pair_url" --token "${_cfg_token:-}" 2>/dev/null | grep -A 100 'Approved' | grep '│' | awk -v t="$TREE_MID" -v d="$DIM" -v r="$RESET" '{print t "  " d $2 r}' || true
            fi
            success "Approve request grabbed"
            _ph5_lines=$((_ph5_lines + 1))
            break
        fi
        _retry_auto_saved="${INSTALL_AUTO_YES:-}"
        unset INSTALL_AUTO_YES
        sleep 0.5
        for _d in 1 2 3 4 5; do
            while read -r -t 0.1 -n 10000 discard; do :; done 2>/dev/null || true
            while read -r -t 0 -n 10000 discard; do read -r discard; done 2>/dev/null || true
        done
        ask_yes_no_tui "Retry?" "y" "RETRY_PAIR_INITIAL" 1 0
        [ -n "${_retry_auto_saved:-}" ] && INSTALL_AUTO_YES="$_retry_auto_saved"
        _ph5_lines=$((_ph5_lines + 2))
        if [[ ! "$RETRY_PAIR_INITIAL" =~ ^[Yy]$ ]]; then
            warn "Pairing timeout."
            warn "No devices paired automatically. Please check the dashboard."
            _ph5_lines=$((_ph5_lines + 2))
            if [ -n "${INSTALL_DEBUG:-}" ]; then
                _pair_diag=$(docker exec "${_ph5_env[@]}" "$CONTAINER_NAME" $OPENCLAW_CMD devices list --url "$_ph5_pair_url" --token "${_cfg_token:-}" 2>&1) || true
                [ -n "$_pair_diag" ] && printf "%b %b %b%s%b\n" "$TUI_PREFIX" "${DIM}[diagnostic]${RESET}" "$DIM" "$_pair_diag" "$RESET" | head -20
            fi
            break
        fi
    done

    if [ "${_ph5_pair_succeeded:-0}" -eq 1 ]; then
        _ph2_dim_msg="${DIM}$(get_accent)"
        info "Setting allowInsecureAuth to FALSE"
        _ph5_lines=$((_ph5_lines + 1))
        _secure_cfg_cmd="docker exec -e HOME=\"\${CONTAINER_HOME:-/home/node}\" \"$CONTAINER_NAME\" $OPENCLAW_CMD config set gateway.controlUi.allowInsecureAuth false"
        _ph5_sec_log="/tmp/ph5_sec_$$"
        { print_debug_cmd "$TUI_PREFIX" "$_secure_cfg_cmd"; } 2>&1 | tee "$_ph5_sec_log"
        _ph5_lines=$((_ph5_lines + $(wc -l < "$_ph5_sec_log" 2>/dev/null || echo 0)))
        rm -f "$_ph5_sec_log"
        _ph5_compose_log="/tmp/ph5_compose_$$"
        docker exec -e HOME="${CONTAINER_HOME:-/home/node}" "$CONTAINER_NAME" $OPENCLAW_CMD config set gateway.controlUi.allowInsecureAuth false 2>&1 | tee "$_ph5_compose_log" | while read -r line; do
            line="${line#$'\r'}"; [[ "$line" =~ ^[✔✓x](.*) ]] && line="${BASH_REMATCH[1]}"; [ -z "$line" ] && continue
            if [[ "$line" = *"Failed to discover Ollama"* ]]; then printf "%b %b %b%s%b\n" "$TUI_PREFIX" "${RED}[ERROR]${RESET}" "$RED" "$line" "$RESET"; elif [[ "$line" =~ [eE][rR][rR][oO][rR] ]]; then printf "%b %b %b%s%b\n" "$TUI_PREFIX" "${RED}[ERROR]${RESET}" "$RED" "$line" "$RESET"; elif [ -n "${INSTALL_DEBUG:-}" ]; then if [[ "$line" = *Updated* ]]; then printf "%b %b %b%s%b\n" "$TUI_PREFIX" "${ORANGE:-$YELLOW}[DEBUG]${RESET}" "$_ph2_dim_msg" "$line" "$RESET"; else printf "%b %b %s\n" "$TUI_PREFIX" "${ORANGE:-$YELLOW}[DEBUG]${RESET}" "$line"; fi; fi
        done
        _ph5_lines=$((_ph5_lines + $(wc -l < "$_ph5_compose_log" 2>/dev/null || echo 0)))
        rm -f "$_ph5_compose_log"
        sleep 2
        info "Restarting container in secure mode... No more talking. just you and me!"
        _ph5_lines=$((_ph5_lines + 1))
        _restart_cmd="docker restart $CONTAINER_NAME"
        _ph5_restart_log="/tmp/ph5_restart_$$"
        { print_debug_cmd "$TUI_PREFIX" "$_restart_cmd"; } 2>&1 | tee "$_ph5_restart_log"
        _ph5_lines=$((_ph5_lines + $(wc -l < "$_ph5_restart_log" 2>/dev/null || echo 0)))
        rm -f "$_ph5_restart_log"
        docker restart "$CONTAINER_NAME" >/dev/null 2>&1
        printf "%b %b %bContainer restarted%b\n" "$TUI_PREFIX" "${GREEN}[ OK ]${RESET}" "$GREEN" "$RESET"
        _ph5_lines=$((_ph5_lines + 1))
        docker exec "$CONTAINER_NAME" rm -f "${CONTAINER_HOME:-/home/node}/.openclaw/gateway.pid" 2>/dev/null || true
        sleep 3
        wait_for_condition_tui "Starting secure gateway..." '_c=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 2 "http://127.0.0.1:'"${_cfg_port}"'/" 2>/dev/null); [ -n "$_c" ] && [ "$_c" != "000" ]' 90
        _ph5_lines=$((_ph5_lines + 1))
        if [ $? -ne 0 ]; then
            warn "Gateway secure start timed out. Check logs:"
            _ph5_lines=$((_ph5_lines + 1))
            docker compose logs --tail 15 openclaw-gateway 2>/dev/null || true
            fail_install "Aborting setup. Gateway failed to start in secure mode."
        fi
        printf "\033[${_ph5_lines}A\r\033[K"
        printf "%b%s%b%b%b\033[K\n" "$(get_accent)" "$DIAMOND_EMPTY" "$(get_accent)" "Pairing (1 of 2): grabbing devices" "$RESET"
        printf "\033[$(($_ph5_lines - 1))B"

        _final_ret_file="/tmp/pf_$$"
        FINAL_PAIR_CMD='docker exec -e HOME="'"${CONTAINER_HOME:-/home/node}"'" -e OPENCLAW_BIND="'"${GATEWAY_BIND:-lan}"'" '"$CONTAINER_NAME"' sh -c '\'''"$OPENCLAW_CMD"' devices list --json --url ws://127.0.0.1:'"${_cfg_port}"' --token "'"${_cfg_token:-}"'" | node -e "JSON.parse(require(\"fs\").readFileSync(0)).pending.forEach(p => console.log(p.requestId))" 2>/dev/null | while read id; do [ -n "$id" ] && out=$('"$OPENCLAW_CMD"' devices approve "$id" --url ws://127.0.0.1:'"${_cfg_port}"' --token "'"${_cfg_token:-}"'") && echo "$out"; done; '"$OPENCLAW_CMD"' devices list --url ws://127.0.0.1:'"${_cfg_port}"' --token "'"${_cfg_token:-}"'" | grep -q "Paired ([1-9])"'\'''
        FINAL_PAIR_WRAPPER='( ( eval "$FINAL_PAIR_CMD" 2>&1; echo $? > "'"$_final_ret_file"'") | while read -r line; do if [[ "$line" == Approved* ]]; then printf "%b %b %b%s%b\n" "$TUI_PREFIX" "${GREEN}[ OK ]${RESET}" "$GREEN" "$line" "$RESET"; fi; done; _r=$(cat "'"$_final_ret_file"'" 2>/dev/null || echo 1); exit "$_r" )'
        _ph7_prev_lines=0
        while true; do
            if [ "$_ph7_prev_lines" -gt 0 ]; then
                header_tui_collapse "Pairing (2 of 2): 💍 to make the family grow" "$_ph7_prev_lines"
            else
                header_tui "Pairing (2 of 2): 💍 to make the family grow" "" "1"
            fi
            _ph7_lines=1
            info "Ensuring all remaining requests are approved..."
            _ph7_lines=$((_ph7_lines + 1))
            set +e
            wait_for_condition_tui "Finalizing pairing..." "$FINAL_PAIR_WRAPPER" 30 "Pairing failed"
            _ph7_rc=$?
            set -e
            _ph7_lines=$((_ph7_lines + 1))
            rm -f "$_final_ret_file" 2>/dev/null || true
            if [ "$_ph7_rc" -eq 0 ]; then
                success "All devices secured and approved! 🛡️"
                _ph7_lines=$((_ph7_lines + 1))
                printf "\033[${_ph7_lines}A\r\033[K"
                printf "%b%s%b%b%b\033[K\n" "$(get_accent)" "$DIAMOND_EMPTY" "$(get_accent)" "Pairing (2 of 2): 💍 to make the family grow" "$RESET"
                printf "\033[$(($_ph7_lines - 1))B"
                break
            fi
            _retry_final_saved="${INSTALL_AUTO_YES:-}"
            unset INSTALL_AUTO_YES
            sleep 0.5
            for _d in 1 2 3 4 5; do
                while read -r -t 0.1 -n 10000 discard; do :; done 2>/dev/null || true
                while read -r -t 0 -n 10000 discard; do read -r discard; done 2>/dev/null || true
            done
            ask_yes_no_tui "Re-try pairing?" "y" "RETRY_PAIR" 1 0
            [ -n "${_retry_final_saved:-}" ] && INSTALL_AUTO_YES="$_retry_final_saved"
            _ph7_lines=$((_ph7_lines + 2))
            if [[ ! "$RETRY_PAIR" =~ ^[Yy]$ ]]; then
                warn "No additional devices found post-restart."
                _ph7_lines=$((_ph7_lines + 1))
                printf "\033[${_ph7_lines}A\r\033[K"
                printf "%b%s%b%b%b\033[K\n" "$(get_accent)" "$DIAMOND_EMPTY" "$(get_accent)" "Pairing (2 of 2): 💍 to make the family grow" "$RESET"
                printf "\033[$(($_ph7_lines - 1))B"
                break
            fi
            _ph7_prev_lines="$_ph7_lines"
        done
    else
        warn "Skipping secure mode (no devices paired); dashboard remains in token-only mode."
        warn "allowInsecureAuth is still enabled."
        _ph5_lines=$((_ph5_lines + 2))
        printf "\033[${_ph5_lines}A\r\033[K"
        printf "%b%s%b%b%b\033[K\n" "$(get_accent)" "$DIAMOND_EMPTY" "$(get_accent)" "Pairing (1 of 2): grabbing devices" "$RESET"
        printf "\033[$(($_ph5_lines - 1))B"
    fi
}
