#!/bin/bash
# --- Install Executor ---
# Orchestrator: sources pre_docker + phases, runs run_install().
# Requires: install/security.sh, gateway.sh, workspace.sh (sourced by install_clawfather.sh)

_EXECUTOR_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
_PHASES_DIR="$_EXECUTOR_DIR/phases"

[ -f "$_EXECUTOR_DIR/security.sh" ] && source "$_EXECUTOR_DIR/security.sh"
[ -f "$_EXECUTOR_DIR/gateway.sh" ] && source "$_EXECUTOR_DIR/gateway.sh"
[ -f "$_EXECUTOR_DIR/workspace.sh" ] && source "$_EXECUTOR_DIR/workspace.sh"
[ -f "$_EXECUTOR_DIR/pre_docker.sh" ] && source "$_EXECUTOR_DIR/pre_docker.sh"
[ -f "$_PHASES_DIR/setup_phase_runner.sh" ] && source "$_PHASES_DIR/setup_phase_runner.sh"
[ -f "$_PHASES_DIR/docker_launch.sh" ] && source "$_PHASES_DIR/docker_launch.sh"
[ -f "$_PHASES_DIR/phase_config.sh" ] && source "$_PHASES_DIR/phase_config.sh"
[ -f "$_PHASES_DIR/phase_skill_deps.sh" ] && source "$_PHASES_DIR/phase_skill_deps.sh"
[ -f "$_PHASES_DIR/phase_gateway_restart.sh" ] && source "$_PHASES_DIR/phase_gateway_restart.sh"
[ -f "$_PHASES_DIR/phase_pairing.sh" ] && source "$_PHASES_DIR/phase_pairing.sh"
[ -f "$_PHASES_DIR/phase_health_smoke.sh" ] && source "$_PHASES_DIR/phase_health_smoke.sh"
[ -f "$_PHASES_DIR/phase_hatch.sh" ] && source "$_PHASES_DIR/phase_hatch.sh"

fail_install() {
    printf "%bInstaller failed: %b%b%s%b\n" "${RED}" "$RESET" "$RED" "$1" "$RESET" >&2
    exit 1
}

run_install() {
    apply_security_settings
    run_pre_docker
    ask_yes_no_tui "Start docker?" "y" "START_NOW" 1 0
    if [[ "$START_NOW" =~ ^[Yy]$ ]]; then
        run_docker_launch
        run_phase_config
        run_phase_skill_deps
        run_phase_gateway_restart
        run_phase_pairing
        run_phase_health_smoke
        run_phase_hatch
    else
        fail_install "Container failed to start. Check logs: docker compose logs $GATEWAY_SERVICE"
    fi
}
