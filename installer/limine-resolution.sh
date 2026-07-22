#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

readonly CONF="/boot/limine.conf"
readonly ENTRY="interface_resolution: 1920x1080"

main() {

    [[ $EUID -ne 0 ]] && error "Run as root."
    [[ ! -f "$CONF" ]] && error "Not found: $CONF"

    if grep -q "^interface_resolution:" "$CONF"; then
        sed -i "s/^interface_resolution:.*/$ENTRY/" "$CONF"
        success "Updated: $ENTRY"
    else
        sed -i "1i $ENTRY" "$CONF"
        success "Inserted: $ENTRY"
    fi
}

main "$@"