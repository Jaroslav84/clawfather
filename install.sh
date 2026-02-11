#!/bin/bash
# Bootstrap: downloads clawfather and runs the real installer.
# Usage: curl -fsSL https://raw.githubusercontent.com/Jaroslav84/clawfather/master/install.sh | bash

set -e
REPO="https://github.com/Jaroslav84/clawfather/archive/refs/heads/master.tar.gz"
TMP=$(mktemp -d)
trap "rm -rf $TMP" EXIT
curl -fsSL "$REPO" | tar xz -C "$TMP"
cd "$TMP/clawfather-master"
chmod +x src/install_clawfather.sh
exec bash src/install_clawfather.sh "$@"
