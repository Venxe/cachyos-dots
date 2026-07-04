#!/usr/bin/env bash
set -euo pipefail

readonly BETTERFOX_URL="https://raw.githubusercontent.com/yokoffing/Betterfox/main/user.js"
readonly FIREFOX_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/mozilla/firefox"
readonly CAELESTIA_PREF='user_pref("toolkit.legacyUserProfileCustomizations.stylesheets", true);'

find_profile() {
  local ini="$FIREFOX_DIR/profiles.ini"
  [[ ! -f "$ini" ]] && return 1

  local path
  path=$(awk -F= '/^\[Install/{s=1} s && /^Default=/{print $2; exit}' "$ini")

  if [[ -z "$path" ]]; then
    path=$(awk -F= '
      /^\[Profile/{s=1; p=""}
      s && /^Path=/{p=$2}
      s && /^Default=1/{if(p) {print p; exit}}
    ' "$ini")
  fi

  [[ -z "$path" ]] && return 1
  echo "$FIREFOX_DIR/$path"
}

profile=$(find_profile) || { echo "Firefox profile not found. Launch Firefox at least once first."; exit 1; }
target="$profile/user.js"


curl -sL "$BETTERFOX_URL" -o "$target"

if ! grep -q 'toolkit.legacyUserProfileCustomizations.stylesheets' "$target"; then
  printf '\n// Caelestia: Required for userChrome.css\n%s\n' "$CAELESTIA_PREF" >> "$target"
fi
