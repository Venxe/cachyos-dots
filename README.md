#!/usr/bin/env bash
# setup-monitor.sh

HYPR_USER="$HOME/.config/caelestia/hypr-user.lua"

# Create file if it doesn't exist
touch "$HYPR_USER"

# Check if monitor config already exists
if grep -q "hl.monitor" "$HYPR_USER"; then
    echo "Monitor config already exists. Skipping."
    exit 0
fi

cat >> "$HYPR_USER" << 'EOF'

hl.monitor({
    output   = "DP-1",
    mode     = "2560x1440@165.08Hz",
    position = "auto",
    scale    = 1,
})
EOF

echo "Monitor config added to $HYPR_USER"
