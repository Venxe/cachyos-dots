#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

readonly EQUIBOP_DIR="$HOME/.config/equibop"
readonly SETTINGS_FILE="$EQUIBOP_DIR/settings/settings.json"
readonly THEME_FILE="$EQUIBOP_DIR/themes/caelestia.theme.css"

main() {

    if [[ -f "$SETTINGS_FILE" ]]; then
        sed -i 's/"transparent": false/"transparent": true/g' "$SETTINGS_FILE"
        success "transparent = true -> $SETTINGS_FILE"
    else
        info "Equibop settings.json not found. Skipping main settings patch."
    fi

    if [[ -f "$THEME_FILE" ]]; then
        sed -i 's/--transparency-tweaks: off;/--transparency-tweaks: on;/g' "$THEME_FILE"
        sed -i 's/--remove-bg-layer: off;/--remove-bg-layer: on;/g' "$THEME_FILE"
        
        sed -i 's/\(--bg-3: #[0-9a-fA-F]\{6\}\);/\1d9;/g' "$THEME_FILE"
        sed -i 's/\(--bg-4: #[0-9a-fA-F]\{6\}\);/\1d9;/g' "$THEME_FILE"
        
        success "Caelestia theme transparency configs applied -> $THEME_FILE"
    else
        info "caelestia.theme.css not found. Skipping CSS patch."
    fi

    local hook_script="$EQUIBOP_DIR/apply-transparency.sh"
    cat << 'EOF' > "$hook_script"
#!/usr/bin/env bash
THEME_FILE="$HOME/.config/equibop/themes/caelestia.theme.css"
if [[ -f "$THEME_FILE" ]]; then
    sed -i 's/--transparency-tweaks: off;/--transparency-tweaks: on;/g' "$THEME_FILE"
    sed -i 's/--remove-bg-layer: off;/--remove-bg-layer: on;/g' "$THEME_FILE"
    sed -i 's/\(--bg-3: #[0-9a-fA-F]\{6\}\);/\1d9;/g' "$THEME_FILE"
    sed -i 's/\(--bg-4: #[0-9a-fA-F]\{6\}\);/\1d9;/g' "$THEME_FILE"
fi
EOF
    chmod +x "$hook_script"

    local cli_json="$HOME/.config/caelestia/cli.json"
    mkdir -p "$(dirname "$cli_json")"
    local post_hook_script="$HOME/.config/caelestia/post-hook.sh"
    
    if [[ ! -f "$cli_json" ]]; then
        echo '{"theme": {"postHook": "'"$post_hook_script"'"}}' > "$cli_json"
    else
        if command -v jq >/dev/null 2>&1; then
            jq '.theme.postHook = "'"$post_hook_script"'"' "$cli_json" > "${cli_json}.tmp" && mv "${cli_json}.tmp" "$cli_json"
        fi
    fi
    success "Caelestia postHook applied to survive wallpaper changes."
}

main "$@"
