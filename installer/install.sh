#!/usr/bin/env bash

clear

source "$(dirname "${BASH_SOURCE[0]}")/utils.sh"

DIR=$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)
readonly DIR
readonly PACKAGES_DIR="$DIR/installer/packages"
readonly SCRIPTS_DIR="$DIR/installer"

print_banner() {
    echo -e "\e[36m"
    cat << "EOF"

┌─┐┌─┐┬ ┬┬┌┬┐┌┐ ┬ ┬┬─┐┌─┐┬┌─ ┐┌─┐  ╔╦╗┌─┐┌┬┐┌─┐┬┬  ┌─┐┌─┐
└─┐├─┤└┬┘││││├┴┐│ │├┬┘├─┤├┴┐  └─┐   ║║│ │ │ ├┤ ││  ├┤ └─┐
└─┘┴ ┴ ┴ ┴┴ ┴└─┘└─┘┴└─┴ ┴┴ ┴  └─┘  ═╩╝└─┘ ┴ └  ┴┴─┘└─┘└─┘

EOF
    echo -e "\e[0m"
    echo -e "${GREEN}=== Welcome to the CachyOS Customization Installer ===${NC}"
    echo "This script will install packages and apply dotfiles/system configurations."
    echo "Active User Directory: $HOME"
}

check_privileges() {
    if [[ $EUID -eq 0 ]]; then
        error "DO NOT run this script as root (sudo ./install.sh)!\nPlease run it as a normal user; you will be prompted for a password when necessary."
    fi
    info "Root privileges are required for system-wide modifications."
    sudo -v
}

install_packages() {
    info "1/3 - Installing packages from official repositories (pacman)..."
    xargs -a "$PACKAGES_DIR/pacman.txt" -r sudo pacman -S --needed

    info "2/3 - Installing AUR packages (yay)..."
    xargs -a "$PACKAGES_DIR/yay.txt" -r yay -S --needed

    info "3/3 - Installing Flatpak packages..."
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    xargs -a "$PACKAGES_DIR/flatpak.txt" -r flatpak install -y flathub
}

apply_configurations() {
    info "Copying user configuration files (~/.config)..."
    if [[ -f "$HOME/.config/zed/settings.json" ]]; then
        rsync -aK --exclude="zed/settings.json" "$DIR/.config/" "$HOME/.config/"
    else
        rsync -aK "$DIR/.config/" "$HOME/.config/"
    fi
    success "User configurations successfully copied."

    info "Copying system configuration files (/etc)..."
    if [[ -d "$DIR/etc" ]]; then
        sudo cp -a "$DIR/etc/." /etc/
        success "System-wide (/etc) configurations applied."
    fi

    info "Setting GTK icon and cursor themes..."
    gsettings set org.gnome.desktop.interface icon-theme "kora"
    gsettings set org.gnome.desktop.interface cursor-theme "Qogir-white-cursors"
    gsettings set org.gnome.desktop.interface cursor-size 24

    info "Setting profile picture..."
    cp "$DIR/assets/.face" "$HOME/.face"
    sudo mkdir -p /usr/share/sddm/faces
    sudo cp "$DIR/assets/.face" "/usr/share/sddm/faces/$USER.face.icon"
    success "Profile picture successfully copied."

    info "Setting RTC to local time (dual-boot Windows compatibility)..."
    sudo sh -c 'printf "0.0 0 0.0\n0\nLOCAL\n" > /etc/adjtime'
    sudo hwclock --systohc --localtime
}

apply_agent_configurations() {
    info "Copying AI agent configuration files (.codex, .gemini)..."
    local agent_dirs=(".codex" ".gemini")
    local dir

    for dir in "${agent_dirs[@]}"; do
        if [[ -d "$DIR/$dir" ]]; then
            info "-> Copying $dir configuration files (~/$dir)..."
            if [[ -f "$HOME/$dir/config/mcp_config.json" ]]; then
                rsync -aK --exclude="config/mcp_config.json" "$DIR/$dir/" "$HOME/$dir/"
            else
                rsync -aK "$DIR/$dir/" "$HOME/$dir/"
            fi
            success "$dir configuration successfully copied."
        fi
    done
}

run_script() {
    local script="$SCRIPTS_DIR/$1" privilege="$2" message="$3"
    [[ -f "$script" ]] || return 0

    info "-> $message"
    if [[ "$privilege" == "root" ]]; then
        sudo bash "$script"
    else
        bash "$script"
    fi
}

execute_subscripts() {
    info "Executing custom configuration scripts..."

    run_script "snapper.sh" root "Configuring Snapper snapshot limits..."
    run_script "libvirt.sh" root "Configuring Libvirt..."
    run_script "limine-resolution.sh" root "Setting Limine bootloader resolution..."
    run_script "betterfox.sh" user "Installing BetterFox user.js..."
    run_script "equibop.sh" user "Patching Equibop transparency settings..."
    run_script "desktop-entries.sh" root "Patching desktop entries..."
    run_script "caelestia-theme.sh" user "Applying Caelestia icon themes and postHook..."
    run_script "mcp-servers.sh" user "Installing external MCP servers (context-mode, codebase-memory)..."
}

enable_services() {
    info "Enabling required services..."
    sudo systemctl daemon-reload
    sudo systemctl enable --now tailscaled.service
}

main() {
    print_banner
    check_privileges
    install_packages
    apply_configurations
    apply_agent_configurations
    execute_subscripts
    enable_services

    info "Cleaning up installation directory..."
    cd "$HOME"
    rm -rf -- "$DIR"

    success "Installation completed successfully!"
    echo -e "${YELLOW}It is recommended to reboot your computer for the changes to take full effect.${NC}"
}

main "$@"
