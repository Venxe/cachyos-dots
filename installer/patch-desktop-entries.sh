#!/usr/bin/env bash
set -euo pipefail

readonly DESKTOP_DIRS=(
  "/usr/share/applications"
  "/var/lib/flatpak/exports/share/applications"
)

declare -A exec_map=(
)

hidden_list=(
  "/usr/share/applications/avahi-discover.desktop"
  "/usr/share/applications/bssh.desktop"
  "/usr/share/applications/bvnc.desktop"
  "/usr/share/applications/cmake-gui.desktop"
  "/usr/share/applications/foot-server.desktop"
  "/usr/share/applications/footclient.desktop"
  "/usr/share/applications/gmic_qt.desktop"
  "/usr/share/applications/libreoffice-*.desktop"
  "/usr/share/applications/lsp-plugins.desktop"
  "/usr/share/applications/lstopo.desktop"
  "/usr/share/applications/org.pulseaudio.pavucontrol.desktop"
  "/usr/share/applications/org.torproject.torbrowser-launcher.settings.desktop"
  "/usr/share/applications/qv4l2.desktop"
  "/usr/share/applications/qvidcap.desktop"
  "/usr/share/applications/thunar*.desktop"
  "/usr/share/applications/uuctl.desktop"
  "/usr/share/applications/winetricks.desktop"
  "/usr/share/applications/xfce4-about.desktop"
)

update_exec() {
  local file=$1 cmd=$2
  [[ ! -f "$file" ]] && return 0
  sed -i -e '/^\[Desktop Entry\]/,/^\[/{/^Exec=/d; /^Terminal=/d}' \
         -e '/^\[Desktop Entry\]/a Exec='"$cmd"'\nTerminal=false' "$file"
}

hide_entry() {
  local file=$1
  [[ ! -f "$file" ]] && return 0
  sed -i -e '/^\[Desktop Entry\]/,/^\[/{/^NoDisplay=/d}' \
         -e '/^\[Desktop Entry\]/a NoDisplay=true' "$file"
}

if (( ${#exec_map[@]} > 0 )); then
  for app in "${!exec_map[@]}"; do
    for dir in "${DESKTOP_DIRS[@]}"; do
      file="$dir/${app}.desktop"
      [[ -f "$file" ]] && update_exec "$file" "${exec_map[$app]}" && break
    done
  done
fi

shopt -s nullglob
if (( ${#hidden_list[@]} > 0 )); then
  for pattern in "${hidden_list[@]}"; do
    for file in $pattern; do
      hide_entry "$file"
    done
  done
fi
shopt -u nullglob