#!/bin/bash
# audit.sh - OpenClaw Security Posture Audit
# Checks your installation against the hardening guide in docs/02-post_install/01-security-post-install.md

# Colors
BOLD='\033[1m'
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

SUCCESS_MARK="${GREEN}✓${NC}"
FAIL_MARK="${RED}✗${NC}"
WARN_MARK="${YELLOW}⚠${NC}"

# Resolve project paths
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(dirname "$SCRIPT_DIR")"
DOCKER_COMPOSE_FILE="$PROJECT_ROOT/docker-compose.yml"

echo -e "\n${BOLD}${BLUE}🦞 OpenClaw Security Audit${NC}"
echo -e "${DEM}Scanning project: $PROJECT_ROOT${NC}\n"

SCORE=0
TOTAL_CHECKS=0

check() {
    local name="$1"
    local condition="$2"
    local fail_msg="$3"
    local critical="$4" # "true" or "false"

    ((TOTAL_CHECKS++))
    if eval "$condition"; then
        echo -e "  ${SUCCESS_MARK} ${name}"
        ((SCORE++))
    else
        echo -e "  ${FAIL_MARK} ${name}"
        echo -e "      ${RED}Failure: ${fail_msg}${NC}"
        if [ "$critical" == "true" ]; then
            echo -e "      ${BOLD}${RED}CRITICAL SECURITY RISK${NC}"
        fi
    fi
}

skip_check() {
    local name="$1"
    local reason="$2"
    echo -e "  ${WARN_MARK} ${name} ${DIM}(Skipped: $reason)${NC}"
}

# --- 1. Static Configuration Analysis ---
echo -e "${BOLD}1. Docker Configuration (Static Analysis)${NC}"

if [ ! -f "$DOCKER_COMPOSE_FILE" ]; then
    echo -e "  ${FAIL_MARK} docker-compose.yml not found at $DOCKER_COMPOSE_FILE"
    exit 1
fi

check "Capability Drop (cap_drop: ALL)" \
    "grep -q 'cap_drop:' \"$DOCKER_COMPOSE_FILE\" && grep -A1 'cap_drop:' \"$DOCKER_COMPOSE_FILE\" | grep -q 'ALL'" \
    "Container has excessive Linux capabilities. Add 'cap_drop: [ALL]'." "true"

check "Privilege Escalation Protection" \
    "grep -q 'no-new-privileges:true' \"$DOCKER_COMPOSE_FILE\"" \
    "Missing 'security_opt: [no-new-privileges:true]'. Sudo escalation is possible." "true"

check "Docker Socket Not Exposed" \
    "! grep -v '#' \"$DOCKER_COMPOSE_FILE\" | grep -q '/var/run/docker.sock'" \
    "The Docker socket is exposed! Agent has GOD MODE over your host." "true"

check "Root Directory Not Mounted" \
    "! grep -v '#' \"$DOCKER_COMPOSE_FILE\" | grep -qE ' \- /:/| \- ~/:| \- \${HOME}:'" \
    "The entire root or home directory is mounted. This is catastrophic." "true"

check "Host Network Disabled" \
    "! grep -v '#' \"$DOCKER_COMPOSE_FILE\" | grep -q 'network_mode: host'" \
    "Container is using host networking. Isolation is broken." "true"

echo ""

# --- 2. Dynamic Runtime Analysis ---
echo -e "${BOLD}2. Runtime Analysis${NC}"

if docker compose ps | grep -q "Up"; then
    check "Container is Running" "true" "" "false"

    # Check for logs size
    LOG_SIZE=$(docker compose exec openclaw-gateway du -sh ~/.openclaw/logs 2>/dev/null | cut -f1)
    if [ -n "$LOG_SIZE" ]; then
        echo -e "  ${SUCCESS_MARK} Log Size: ${BOLD}$LOG_SIZE${NC}"
    else
        echo -e "  ${WARN_MARK} Could not check log size"
    fi

    # Trigger internal skill scanner
    echo -e "\n  ${CYAN}Running internal Skill Scanner...${NC}"
    SCAN_OUTPUT=$(docker compose exec openclaw-gateway clawdhub run skill-scanner --all 2>&1)
    
    if echo "$SCAN_OUTPUT" | grep -q "SAFE"; then
        echo -e "  ${SUCCESS_MARK} Skill Scanner: ${GREEN}CLEAN${NC}"
        ((SCORE++))
        ((TOTAL_CHECKS++))
    elif echo "$SCAN_OUTPUT" | grep -q "RISK"; then
        echo -e "  ${FAIL_MARK} Skill Scanner: ${RED}RISKS DETECTED${NC}"
        echo "$SCAN_OUTPUT" | grep "RISK" | sed 's/^/      /'
        ((TOTAL_CHECKS++))
    else
        # If scanner not found or failed
        echo -e "  ${WARN_MARK} Skill Scanner could not run or returned unexpected output."
        # echo "$SCAN_OUTPUT"
    fi

else
    echo -e "  ${WARN_MARK} Container is NOT running. Skipping runtime checks."
fi

echo ""

# --- 3. Host Bridge Audit ---
echo -e "${BOLD}3. Bridge & Exposure Audit${NC}"

check "Bridge Exposed (Awareness Check)" \
    "grep -v '#' \"$DOCKER_COMPOSE_FILE\" | grep -q 'host.docker.internal'" \
    "Bridge is DISABLED. Agent cannot access host services (Good for security, Bad for automation)." "false"

# Scorecard
PERCENT=$((SCORE * 100 / TOTAL_CHECKS))
echo -e "\n${BOLD}Security Score: ${PERCENT}% ($SCORE/$TOTAL_CHECKS Checks Passed)${NC}"

if [ $PERCENT -eq 100 ]; then
    echo -e "${GREEN}🏆 TOP NOTCH SECURITY DETECTED!${NC}"
    echo -e "You are running a hardened configuration."
elif [ $PERCENT -ge 80 ]; then
    echo -e "${YELLOW}💪 Good Posture.${NC} Review failures above to harden further."
else
    echo -e "${RED}⚠️  RISK DETECTED.${NC} Please fix the critical failures immediately."
fi

echo ""
