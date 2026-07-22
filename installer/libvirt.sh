#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

readonly LIBVIRTD_CONF="/etc/libvirt/libvirtd.conf"
readonly QEMU_CONF="/etc/libvirt/qemu.conf"

set_or_replace() {
    local file="$1" key="$2" value="$3"
    if grep -qE "^#?[[:space:]]*${key}[[:space:]]*=" "$file"; then
        sed -i "s|^#\?[[:space:]]*${key}[[:space:]]*=.*|${key} = ${value}|" "$file"
    else
        echo "${key} = ${value}" >> "$file"
    fi
    success "${key} = ${value} → ${file}"
}

main() {

    [[ $EUID -ne 0 ]] && error "Run as root."
    [[ -z "${SUDO_USER:-}" ]] && error "Run with sudo, not as root directly."

    local target_user="$SUDO_USER"

    for f in "$LIBVIRTD_CONF" "$QEMU_CONF"; do
        [[ ! -f "$f" ]] && error "Not found: $f"
    done

    set_or_replace "$LIBVIRTD_CONF" "unix_sock_group"    "'libvirt'"
    set_or_replace "$LIBVIRTD_CONF" "unix_sock_rw_perms" "'0770'"
    set_or_replace "$QEMU_CONF"     "user"               "\"${target_user}\""
    set_or_replace "$QEMU_CONF"     "group"              "\"${target_user}\""

    usermod -aG libvirt "$target_user"
    success "Added ${target_user} to libvirt group."

    systemctl enable --now libvirtd
    success "libvirtd enabled and started."

    info "Done. Log out and back in for group changes to take effect."
}

main "$@"