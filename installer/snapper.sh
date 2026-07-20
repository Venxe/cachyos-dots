#!/usr/bin/env bash
# scripts/snapper.sh

set -euo pipefail

SNAPPER_CONF="/etc/snapper/configs/root"

[[ $EUID -ne 0 ]] && { echo "Run as root."; exit 1; }
[[ ! -f "$SNAPPER_CONF" ]] && { echo "Not found: $SNAPPER_CONF"; exit 1; }

sed -i 's/^NUMBER_LIMIT=.*/NUMBER_LIMIT="10"/' "$SNAPPER_CONF"
echo "Set: NUMBER_LIMIT=\"10\" → $SNAPPER_CONF"
