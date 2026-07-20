#!/usr/bin/env bash
# scripts/limine-resolution.sh

set -euo pipefail

CONF="/boot/limine.conf"
ENTRY="interface_resolution: 1920x1080"

[[ $EUID -ne 0 ]] && { echo "Run as root."; exit 1; }
[[ ! -f "$CONF" ]] && { echo "Not found: $CONF"; exit 1; }

if grep -q "^interface_resolution:" "$CONF"; then
    sed -i "s/^interface_resolution:.*/$ENTRY/" "$CONF"
    echo "Updated: $ENTRY"
else
    sed -i "1i $ENTRY" "$CONF"
    echo "Inserted: $ENTRY"
fi