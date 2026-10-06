#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

main() {
    command -v jq >/dev/null 2>&1 || error "jq is not installed, cannot patch caelestia cli.json"

    local cli_json="$HOME/.config/caelestia/cli.json"
    local post_hook_script="$HOME/.config/caelestia/post-hook.sh"
    local config='{}'
    local temp_file
    mkdir -p "$(dirname "$cli_json")"

    if [[ -f "$cli_json" ]]; then
        config=$(cat "$cli_json")
    fi

    temp_file=$(mktemp "${cli_json}.XXXXXXXX")
    if ! jq --slurp --arg post_hook "$post_hook_script" '
        if length == 1 and (.[0] | type) == "object" then .[0]
        else error("Expected one JSON object") end
        | .theme += {
            "iconTheme": "kora",
            "iconThemeDark": "kora",
            "iconThemeLight": "kora",
            "postHook": $post_hook
        }
    ' <<< "$config" > "$temp_file"; then
        rm -f -- "$temp_file"
        error "Cannot update Caelestia theme settings in $cli_json"
    fi

    mv -- "$temp_file" "$cli_json"
    success "Caelestia icon themes and postHook applied to $cli_json"
}

main "$@"
