#!/usr/bin/env bash
# scripts/setup-caelestia-icons.sh

set -euo pipefail

echo "Patching Caelestia theme engine to persist 'kora' icons..."
CLI_JSON="$HOME/.config/caelestia/cli.json"
mkdir -p "$(dirname "$CLI_JSON")"

if [[ ! -f "$CLI_JSON" ]]; then
    echo '{"theme": {}}' > "$CLI_JSON"
fi

if command -v jq >/dev/null 2>&1; then
    jq '.theme += {"iconTheme": "kora", "iconThemeDark": "kora", "iconThemeLight": "kora"}' "$CLI_JSON" > "${CLI_JSON}.tmp" && mv "${CLI_JSON}.tmp" "$CLI_JSON"
    echo "Set: Caelestia icon themes forced to 'kora' in $CLI_JSON"
else
    echo "Warning: jq is not installed, cannot patch caelestia cli.json"
fi
