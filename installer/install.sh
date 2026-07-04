#!/usr/bin/env bash

clear

# --- BASH STRICT MODE & ERROR HANDLING ---
set -Eeuo pipefail
trap 'error "Failed at line $LINENO: $BASH_COMMAND\nInstallation aborted!"' ERR

# --- CONSTANTS ---
readonly GREEN='\033[0;32m'
readonly BLUE='\033[0;34m'
readonly YELLOW='\033[1;33m'
readonly RED='\033[0;31m'
readonly NC='\033[0m'

readonly DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
readonly PACKAGES_DIR="$DIR/installer/packages"
readonly SCRIPTS_DIR="$DIR/installer"

# --- HELPER FUNCTIONS ---
info() { echo -e "${BLUE}[INFO]${NC} $1"; }
success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
error() { echo -e "${RED}[ERROR]${NC} $1"; exit 1; }

# --- CORE FUNCTIONS ---
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
    command -v yay >/dev/null 2>&1 || error "Yay is required but not installed!"
    xargs -a "$PACKAGES_DIR/yay.txt" -r yay -S --needed

    info "3/3 - Installing Flatpak packages..."
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    xargs -a "$PACKAGES_DIR/flatpak.txt" -r flatpak install -y flathub
}

apply_configurations() {
    info "Copying user configuration files (~/.config)..."
    rsync -aK "$DIR/.config/" "$HOME/.config/"
    success "User configurations successfully copied."

    info "Copying system configuration files (/etc)..."
    if [[ -d "$DIR/etc" ]]; then
        sudo cp -a "$DIR/etc/." /etc/
        success "System-wide (/etc) configurations applied."
    fi

    info "Setting GTK icon and cursor themes..."
    gsettings set org.gnome.desktop.interface icon-theme "kora"
    gsettings set org.gnome.desktop.interface cursor-theme "Qogir-Dark"
    gsettings set org.gnome.desktop.interface cursor-size 24
}

execute_subscripts() {
    info "Executing custom configuration scripts..."
    
    if [[ -f "$SCRIPTS_DIR/setup-libvirt.sh" ]]; then
        info "-> Configuring Libvirt..."
        sudo bash "$SCRIPTS_DIR/setup-libvirt.sh"
    fi

    if [[ -f "$SCRIPTS_DIR/set-limine-resolution.sh" ]]; then
        info "-> Setting Limine bootloader resolution..."
        sudo bash "$SCRIPTS_DIR/set-limine-resolution.sh"
    fi

    if [[ -f "$SCRIPTS_DIR/patch-desktop-entries.sh" ]]; then
        info "-> Patching desktop entries..."
        sudo bash "$SCRIPTS_DIR/patch-desktop-entries.sh"
    fi

    if [[ -f "$SCRIPTS_DIR/setup-betterfox.sh" ]]; then
        info "-> Installing BetterFox user.js..."
        bash "$SCRIPTS_DIR/setup-betterfox.sh"
    fi
}

enable_services() {
    info "Enabling required services..."
    sudo systemctl daemon-reload
    sudo systemctl enable --now tailscaled.service
}

# --- MAIN EXECUTION ---
main() {
    print_banner
    check_privileges
    install_packages
    apply_configurations
    execute_subscripts
    enable_services
    
    info "Cleaning up installation directory..."
    cd "$HOME" || true
    rm -rf "$DIR"
    
    success "Installation completed successfully!"
    echo -e "${YELLOW}It is recommended to reboot your computer for the changes to take full effect.${NC}"
}

main "$@"
