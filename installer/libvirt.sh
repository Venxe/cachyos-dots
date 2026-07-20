#!/usr/bin/env bash
# scripts/libvirt.sh

set -euo pipefail

LIBVIRTD_CONF="/etc/libvirt/libvirtd.conf"
QEMU_CONF="/etc/libvirt/qemu.conf"

[[ $EUID -ne 0 ]] && { echo "Run as root."; exit 1; }
[[ -z "${SUDO_USER:-}" ]] && { echo "Run with sudo, not as root directly."; exit 1; }

TARGET_USER="$SUDO_USER"

for f in "$LIBVIRTD_CONF" "$QEMU_CONF"; do
    [[ ! -f "$f" ]] && { echo "Not found: $f"; exit 1; }
done

set_or_replace() {
    local file="$1" key="$2" value="$3"
    if grep -qE "^#?[[:space:]]*${key}[[:space:]]*=" "$file"; then
        sed -i "s|^#\?[[:space:]]*${key}[[:space:]]*=.*|${key} = ${value}|" "$file"
    else
        echo "${key} = ${value}" >> "$file"
    fi
    echo "Set: ${key} = ${value} → ${file}"
}

set_or_replace "$LIBVIRTD_CONF" "unix_sock_group"    "'libvirt'"
set_or_replace "$LIBVIRTD_CONF" "unix_sock_rw_perms" "'0770'"
set_or_replace "$QEMU_CONF"     "user"               "\"${TARGET_USER}\""
set_or_replace "$QEMU_CONF"     "group"              "\"${TARGET_USER}\""

usermod -aG libvirt "$TARGET_USER"
echo "Added ${TARGET_USER} to libvirt group."

systemctl enable --now libvirtd
echo "libvirtd enabled and started."

echo "Done. Log out and back in for group changes to take effect."