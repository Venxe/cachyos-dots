#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

readonly BETTERFOX_URL="https://raw.githubusercontent.com/yokoffing/Betterfox/main/user.js"
readonly FIREFOX_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/mozilla/firefox"
readonly CAELESTIA_PREF='user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);'

find_profile() {
    local ini="$FIREFOX_DIR/profiles.ini" path
    [[ -f "$ini" ]] || return 1
    path=$(awk '
        { sub(/\r$/, "") }
        /^\[/ { install = /^\[Install/ }
        install && /^Default=/ { sub(/^Default=/, ""); print; exit }
    ' "$ini")

    if [[ -z "$path" ]]; then
        path=$(awk '
            function emit() {
                if (profile && is_default && path != "") { print path; return 1 }
                return 0
            }
            { sub(/\r$/, "") }
            /^\[/ {
                if (emit()) { found = 1; exit }
                profile = /^\[Profile/; path = ""; is_default = 0
            }
            profile && /^Path=/ { path = substr($0, 6) }
            profile && /^Default=1$/ { is_default = 1 }
            END { if (!found) emit() }
        ' "$ini")
    fi

    [[ -n "$path" ]] || return 1
    [[ "$path" == /* ]] || path="$FIREFOX_DIR/$path"
    [[ -d "$path" ]] || return 1
    printf '%s\n' "$path"
}

main() {
    local profile
    profile=$(find_profile) || error "Firefox profile not found. Launch Firefox at least once first."
    local target="$profile/user.js"
    local temp_file
    temp_file=$(mktemp "$profile/.user.js.XXXXXXXX")
    trap 'rm -f -- "$temp_file"' EXIT

    curl -fsSL "$BETTERFOX_URL" -o "$temp_file"
    [[ -s "$temp_file" ]] || error "BetterFox download is empty. Existing user.js was preserved."

    if ! grep -q 'toolkit.legacyUserProfileCustomizations.stylesheets' "$temp_file"; then
        printf '\n// Caelestia: Required for userChrome.css\n%s\n' "$CAELESTIA_PREF" >> "$temp_file"
    fi
    mv -- "$temp_file" "$target"
    trap - EXIT
    success "BetterFox configurations applied to $target"
}

main "$@"
