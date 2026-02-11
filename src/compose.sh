#!/bin/bash
# Wrapper for docker compose that loads .env and .env.install before running.
# Use: ./src/compose.sh up -d
# Or: ./src/compose.sh down
# Ensures compose variable substitution works for both secrets and install config.

cd "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)" || exit 1
set -a
[ -f .env ] && . .env
[ -f .env.install ] && . .env.install
set +a
exec docker compose "$@"
