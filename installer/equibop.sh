#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

readonly EQUIBOP_DIR="$HOME/.config/equibop"
readonly SETTINGS_FILE="$EQUIBOP_DIR/settings/settings.json"
readonly POST_HOOK_SCRIPT="$HOME/.config/caelestia/post-hook.sh"

main() {
    if [[ -f "$SETTINGS_FILE" ]]; then
        sed -i 's/"transparent": false/"transparent": true/g' "$SETTINGS_FILE"
        success "transparent = true -> $SETTINGS_FILE"
    else
        info "Equibop settings.json not found. Skipping main settings patch."
    fi

    bash "$POST_HOOK_SCRIPT"
    success "Equibop transparency configuration completed."
}

main "$@"
