#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

main() {
    local cli_json="$HOME/.config/caelestia/cli.json"
    mkdir -p "$(dirname "$cli_json")"

    if [[ ! -f "$cli_json" ]]; then
        echo '{"theme": {}}' > "$cli_json"
    fi

    if command -v jq >/dev/null 2>&1; then
        jq '.theme += {"iconTheme": "kora", "iconThemeDark": "kora", "iconThemeLight": "kora"}' "$cli_json" > "${cli_json}.tmp" && mv "${cli_json}.tmp" "$cli_json"
        success "Caelestia icon themes forced to 'kora' in $cli_json"
    else
        error "jq is not installed, cannot patch caelestia cli.json"
    fi
}

main "$@"
