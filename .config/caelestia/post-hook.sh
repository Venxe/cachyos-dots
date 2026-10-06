#!/usr/bin/env bash

set -euo pipefail

readonly THEME_FILE="$HOME/.config/equibop/themes/caelestia.theme.css"

if [[ -f "$THEME_FILE" ]]; then
    sed -i \
        -e 's/--transparency-tweaks: off;/--transparency-tweaks: on;/g' \
        -e 's/--remove-bg-layer: off;/--remove-bg-layer: on;/g' \
        -e 's/\(--bg-3: #[0-9a-fA-F]\{6\}\);/\1d9;/g' \
        -e 's/\(--bg-4: #[0-9a-fA-F]\{6\}\);/\1d9;/g' \
        "$THEME_FILE"
fi
