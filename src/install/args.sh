#!/bin/bash

# --- Install Argument Parsing ---
# INSTALL_AUTO_YES: -y runs wizard with defaults (ENTER-only). Pause at password and at "Dashboard loaded?" (see AGENTS.md).

CLEAN_INSTALL=false
WIPE_ALL=false
INSTALL_AUTO_YES=""
INSTALL_DEBUG=""

parse_install_args() {
    while [[ "$#" -gt 0 ]]; do
        case $1 in
            -c|--clean) CLEAN_INSTALL=true; shift ;;
            -d|--debug) INSTALL_DEBUG=1; shift ;;
            -w|--wipe) WIPE_ALL=true; shift ;;
            -y|--yes) INSTALL_AUTO_YES=1; shift ;;
            *) shift ;;
        esac
    done
}
