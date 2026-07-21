#!/usr/bin/env bash

source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

readonly SNAPPER_CONF="/etc/snapper/configs/root"

main() {

    [[ $EUID -ne 0 ]] && error "Run as root."
    [[ ! -f "$SNAPPER_CONF" ]] && error "Not found: $SNAPPER_CONF"

    sed -i 's/^NUMBER_LIMIT=.*/NUMBER_LIMIT="10"/' "$SNAPPER_CONF"
    success "NUMBER_LIMIT=\"10\" → $SNAPPER_CONF"
}

main "$@"
