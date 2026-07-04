#!/usr/bin/env bash
set -euo pipefail

readonly BETTERFOX_URL="https://raw.githubusercontent.com/yokoffing/Betterfox/main/user.js"
readonly FIREFOX_DIR="$HOME/.mozilla/firefox"
readonly CAELESTIA_PREF='user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);'

find_profile() {
  local dir
  for pattern in "*.default-release" "*.default"; do
    dir=$(find "$FIREFOX_DIR" -maxdepth 1 -type d -name "$pattern" -print -quit 2>/dev/null)
    [[ -n "$dir" ]] && echo "$dir" && return 0
  done
  return 1
}

profile=$(find_profile) || { echo "Firefox profile not found. Launch Firefox at least once first."; exit 1; }
target="$profile/user.js"


curl -sL "$BETTERFOX_URL" -o "$target"

if ! grep -q 'toolkit.legacyUserProfileCustomizations.stylesheets' "$target"; then
  printf '\n// Caelestia: Required for userChrome.css\n%s\n' "$CAELESTIA_PREF" >> "$target"
fi
