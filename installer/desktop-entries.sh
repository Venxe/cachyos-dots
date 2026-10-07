#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

readonly DESKTOP_DIRS=(
    "/usr/share/applications"
    "/var/lib/flatpak/exports/share/applications"
)

declare -Ar TERMINAL_ENTRIES=(
    ["vitetris"]="vitetris"
)

readonly HIDDEN_ENTRIES=(
    "/usr/share/applications/avahi-discover.desktop"
    "/usr/share/applications/bssh.desktop"
    "/usr/share/applications/bvnc.desktop"
    "/usr/share/applications/cachyos-pi.desktop"
    "/usr/share/applications/cmake-gui.desktop"
    "/usr/share/applications/foot-server.desktop"
    "/usr/share/applications/footclient.desktop"
    "/usr/share/applications/gmic_qt.desktop"
    "/usr/share/applications/libreoffice-*.desktop"
    "/usr/share/applications/lsp-plugins.desktop"
    "/usr/share/applications/lstopo.desktop"
    "/usr/share/applications/org.cachyos.KernelManager.desktop"
    "/usr/share/applications/org.cachyos.scx-manager.desktop"
    "/usr/share/applications/org.pulseaudio.pavucontrol.desktop"
    "/usr/share/applications/org.torproject.torbrowser-launcher.settings.desktop"
    "/usr/share/applications/qv4l2.desktop"
    "/usr/share/applications/qvidcap.desktop"
    "/usr/share/applications/thunar*.desktop"
    "/usr/share/applications/uuctl.desktop"
    "/usr/share/applications/winetricks.desktop"
    "/usr/share/applications/xfce4-about.desktop"
)

hide_entry() {
    local file="$1"
    [[ -f "$file" ]] || return 0
    sed -i -e '/^\[Desktop Entry\]/,/^\[/{/^NoDisplay=/d}' \
           -e '/^\[Desktop Entry\]/a NoDisplay=true' "$file"
}

main() {
    local app dir file pattern
    for app in "${!TERMINAL_ENTRIES[@]}"; do
        for dir in "${DESKTOP_DIRS[@]}"; do
            file="$dir/$app.desktop"
            if [[ -f "$file" ]]; then
                sed -i -e '/^\[Desktop Entry\]/,/^\[/{/^Exec=/d; /^Terminal=/d}' \
                       -e '/^\[Desktop Entry\]/a Exec='"${TERMINAL_ENTRIES[$app]}"'\nTerminal=true' "$file"
                info "Updated exec for $app"
                break
            fi
        done
    done

    info "Hiding specific desktop entries..."
    shopt -s nullglob
    for pattern in "${HIDDEN_ENTRIES[@]}"; do
        for file in $pattern; do
            hide_entry "$file"
        done
    done
    shopt -u nullglob

    success "Desktop entries patched successfully."
}

main "$@"
