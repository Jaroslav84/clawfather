#!/bin/bash
# --- Phase: Restart gateway, wait for port ---
# Requires: CONTAINER_NAME, CONTAINER_HOME, _cfg_port (set by phase_config)

run_phase_gateway_restart() {
    header_tui "Starting Gateway" "" "1"
    _ph3gw_lines=1
    info "Restarting container in pairing mode..."
    _ph3gw_lines=$((_ph3gw_lines + 1))
    docker restart "$CONTAINER_NAME" >/dev/null 2>&1
    docker exec "$CONTAINER_NAME" rm -f "${CONTAINER_HOME:-/home/node}/.openclaw/gateway.pid" 2>/dev/null || true

    printf "%b %b %bGateway pairing started.%b\n" "$TUI_PREFIX" "${GREEN}[ OK ]${RESET}" "${GREEN}" "$RESET"
    _ph3gw_lines=$((_ph3gw_lines + 1))
    sleep 3
    wait_for_condition_tui "Waiting for gateway" '_c=$(curl -s -o /dev/null -w "%{http_code}" --connect-timeout 2 "http://127.0.0.1:'"${_cfg_port}"'/" 2>/dev/null); [ -n "$_c" ] && [ "$_c" != "000" ]' 90
    _ph3gw_lines=$((_ph3gw_lines + 1))
    if [ $? -ne 0 ]; then
        warn "Gateway start timed out. Check logs:"
        _ph3gw_lines=$((_ph3gw_lines + 1))
        docker compose logs --tail 15 openclaw-gateway 2>/dev/null || true
        fail_install "Aborting setup. Gateway failed to start."
    fi
    printf "\033[${_ph3gw_lines}A\r\033[K"
    printf "%b%s%b%b%b\033[K\n" "$(get_accent)" "$DIAMOND_EMPTY" "$(get_accent)" "Starting Gateway" "$RESET"
    printf "\033[$(($_ph3gw_lines - 1))B"
}
