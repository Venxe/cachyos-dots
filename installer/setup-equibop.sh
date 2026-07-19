#!/usr/bin/env bash
# scripts/setup-equibop.sh

set -euo pipefail

# Target files
EQUIBOP_DIR="$HOME/.config/equibop"
SETTINGS_FILE="$EQUIBOP_DIR/settings/settings.json"
THEME_FILE="$EQUIBOP_DIR/themes/caelestia.theme.css"

echo "Applying Equibop transparency configurations..."

# 1. Enable transparency in Equibop main settings
if [[ -f "$SETTINGS_FILE" ]]; then
    sed -i 's/"transparent": false/"transparent": true/g' "$SETTINGS_FILE"
    echo "Set: transparent = true -> $SETTINGS_FILE"
else
    echo "Warning: Equibop settings.json not found. Skipping main settings patch."
fi

# 2. Enable transparency layers and set background opacity to 0.85 in Caelestia CSS theme
if [[ -f "$THEME_FILE" ]]; then
    # Set --transparency-tweaks and --remove-bg-layer to on
    sed -i 's/--transparency-tweaks: off;/--transparency-tweaks: on;/g' "$THEME_FILE"
    sed -i 's/--remove-bg-layer: off;/--remove-bg-layer: on;/g' "$THEME_FILE"
    
    sed -i 's/\(--bg-3: #[0-9a-fA-F]\{6\}\);/\1d9;/g' "$THEME_FILE"
    sed -i 's/\(--bg-4: #[0-9a-fA-F]\{6\}\);/\1d9;/g' "$THEME_FILE"
    
    echo "Set: Caelestia theme transparency configs applied -> $THEME_FILE"
else
    echo "Warning: caelestia.theme.css not found. Skipping CSS patch."
fi

echo "Equibop configurations finished."

# 3. Create a post-hook for Caelestia theme engine so opacity changes survive wallpaper changes
HOOK_SCRIPT="$EQUIBOP_DIR/apply-transparency.sh"
cat << 'EOF' > "$HOOK_SCRIPT"
#!/usr/bin/env bash
THEME_FILE="$HOME/.config/equibop/themes/caelestia.theme.css"
if [[ -f "$THEME_FILE" ]]; then
    sed -i 's/--transparency-tweaks: off;/--transparency-tweaks: on;/g' "$THEME_FILE"
    sed -i 's/--remove-bg-layer: off;/--remove-bg-layer: on;/g' "$THEME_FILE"
    sed -i 's/\(--bg-3: #[0-9a-fA-F]\{6\}\);/\1d9;/g' "$THEME_FILE"
    sed -i 's/\(--bg-4: #[0-9a-fA-F]\{6\}\);/\1d9;/g' "$THEME_FILE"
fi
EOF
chmod +x "$HOOK_SCRIPT"

CLI_JSON="$HOME/.config/caelestia/cli.json"
mkdir -p "$(dirname "$CLI_JSON")"
POST_HOOK_SCRIPT="$HOME/.config/caelestia/post-hook.sh"
if [[ ! -f "$CLI_JSON" ]]; then
    echo '{"theme": {"postHook": "'"$POST_HOOK_SCRIPT"'"}}' > "$CLI_JSON"
else
    # Update existing JSON with jq
    if command -v jq >/dev/null 2>&1; then
        jq '.theme.postHook = "'"$POST_HOOK_SCRIPT"'"' "$CLI_JSON" > "${CLI_JSON}.tmp" && mv "${CLI_JSON}.tmp" "$CLI_JSON"
    fi
fi
echo "Set: Caelestia postHook applied to survive wallpaper changes."
