#!/bin/bash
# --- Phase: Checklist, npm install (skill dependencies) ---
# Requires: CONTAINER_NAME, TUI_PREFIX

run_phase_skill_deps() {
    select_tui "Package manager" "npm
bun" "" "" "PM_SEL" 0 "true" 1 0
    _pm="${PM_SEL:-npm}"

    SKILL_DEPS_OPTIONS="🧩 clawhub"
    SKILL_DEPS_DESC="Use ClawHub CLI to search, install, update, and publish agent skills from clawhub.ai with npm."
    SKILL_DEPS_SUBTITLES=""
    checklist_tui "Install packages" "$SKILL_DEPS_OPTIONS" "$SKILL_DEPS_DESC" "$SKILL_DEPS_SUBTITLES" "" "SKILL_DEPS" "false" 1 0
    _npm_pkgs=""
    [ "${SKILL_DEPS_0:-false}" = "true" ] && _npm_pkgs="clawhub"
    if [ -z "$_npm_pkgs" ]; then
        printf "%b%s %b%s%b\n" "$(get_accent)" "$TREE_MID" "$RESET" "skipped" "$RESET"
    elif [ -n "$_npm_pkgs" ]; then
        if [ "$_pm" = "bun" ]; then
            _user_local="export PATH=\"\\\$HOME/.bun/bin:\\\$PATH\" && mkdir -p \"\\\$HOME/.bun/bin\" 2>/dev/null; "
            _install_cmd="${_user_local}bun install -g $_npm_pkgs"
        else
            _user_local="export PATH=\"\\\$HOME/.local/bin:\\\$PATH\" && export NPM_CONFIG_PREFIX=\"\\\$HOME/.local\" && mkdir -p \"\\\$HOME/.local/bin\" && "
            _install_cmd="${_user_local}npm install -g --no-color --no-progress $_npm_pkgs"
        fi
        _pkgs_display=$(echo "$_npm_pkgs" | sed 's/ /, /g')
        info "Installing skill dependencies ($_pkgs_display)..."
        _npm_cmd="docker exec \"$CONTAINER_NAME\" sh -c \"$_install_cmd\""
        _pkgs_dbg_log="/tmp/pkgs_dbg_$$"
        { print_debug_cmd "$TUI_PREFIX" "$_npm_cmd"; } 2>&1 | tee "$_pkgs_dbg_log"
        rm -f "$_pkgs_dbg_log"
        set +e
        _pm_label="$(printf '%s' "$_pm" | tr '[:lower:]' '[:upper:]')"
        run_with_progress_bar "Installing $_npm_pkgs..." "docker exec \"$CONTAINER_NAME\" sh -c \"$_install_cmd\"" "$_pm_label"
        _npm_rc=$?
        set -e
        if [ "${_npm_rc:-0}" -ne 0 ]; then
            fail_install "$_pm install failed (exit ${_npm_rc})."
        fi
        if [ "${SKILL_DEPS_0:-false}" = "true" ]; then
            printf "%b %b %bclawhub installed.%b\n" "$TUI_PREFIX" "${GREEN}[ OK ]${RESET}" "$GREEN" "$RESET"
        fi
    fi
}
