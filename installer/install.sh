#!/usr/bin/env bash

# ---------------------------------------------------------
# 1. Renkler ve Yardımcı Fonksiyonlar
# ---------------------------------------------------------
GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m' # No Color

info() { echo -e "${BLUE}[BİLGİ]${NC} $1"; }
success() { echo -e "${GREEN}[BAŞARILI]${NC} $1"; }
warn() { echo -e "${YELLOW}[UYARI]${NC} $1"; }
error() { echo -e "${RED}[HATA]${NC} $1"; exit 1; }

# Betiğin çalıştığı ana dizini bul (Nereden çalıştırılırsa çalıştırılsın dinamik yollar çalışır)
DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

# Root olarak çalıştırılmasını engelle (Çünkü yay ve $HOME ayarları bozulur)
if [[ $EUID -eq 0 ]]; then
    error "Bu betiği root (sudo ./install.sh) olarak ÇALIŞTIRMAYIN!\nLütfen normal kullanıcı olarak çalıştırın, gerektiğinde şifre sorulacaktır."
fi

# Aktif kullanıcının dizinini dinamik olarak al
USER_HOME="$HOME"

echo -e "${GREEN}=== CachyOS Özelleştirme Kurulumuna Hoş Geldiniz ===${NC}"
echo "Bu betik paketleri kuracak ve dotfiles (Symlink) / sistem ayarlarını uygulayacaktır."
echo "Aktif Kullanıcı Dizini: $USER_HOME"
sleep 2

# ---------------------------------------------------------
# 2. Yetki Kontrolü
# ---------------------------------------------------------
info "Sistem genelinde değişiklikler için root yetkisine ihtiyaç var."
sudo -v || error "Sudo yetkisi alınamadı, kurulum iptal ediliyor."

# ---------------------------------------------------------
# 3. Paket Kurulumları
# ---------------------------------------------------------
info "1/3 - Resmi depolardan paketler kuruluyor (pacman)..."
sudo pacman -S --needed --noconfirm - < "$DIR/installer/packages/pacman.txt" || warn "Bazı pacman paketleri kurulamadı."

info "2/3 - AUR paketleri kuruluyor (yay)..."
if command -v yay &> /dev/null; then
    yay -S --needed --noconfirm - < "$DIR/installer/packages/yay.txt" || warn "Bazı AUR paketleri kurulamadı."
else
    warn "Yay yüklü bulunamadı! AUR paketleri atlanıyor..."
fi

info "3/3 - Flatpak paketleri kuruluyor..."
if command -v flatpak &> /dev/null; then
    flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
    flatpak install -y flathub $(cat "$DIR/installer/packages/flatpak.txt") || warn "Bazı flatpak paketleri kurulamadı."
else
    warn "Flatpak kurulu değil, bu adım atlanıyor."
fi

# ---------------------------------------------------------
# 4. Yapılandırma Dosyalarını (Symlink) Uygulama
# ---------------------------------------------------------
info "Kullanıcı yapılandırma dosyaları (~/.config) Symlink olarak ekleniyor..."
mkdir -p "$USER_HOME/.config"

# .config içindeki her klasör/dosya için döngü oluştur
for item in "$DIR/.config/"*; do
    if [ -e "$item" ]; then
        target_name=$(basename "$item")
        
        # Eğer hedefte zaten aynı isimde gerçek bir klasör/dosya varsa (symlink değilse) yedekle
        if [ -e "$USER_HOME/.config/$target_name" ] && [ ! -L "$USER_HOME/.config/$target_name" ]; then
            warn "$target_name hedefte zaten var. Mevcut olan yedekleniyor: $target_name.bak"
            mv "$USER_HOME/.config/$target_name" "$USER_HOME/.config/$target_name.bak"
        fi
        
        # Symlink oluştur (-s: symlink, -f: force/üzerine yaz, -n: sembolik bağları izleme)
        ln -sfn "$item" "$USER_HOME/.config/$target_name"
        echo -e "  -> Symlink oluşturuldu: .config/$target_name"
    fi
done
success "Kullanıcı yapılandırmaları başarıyla symlink edildi."

# ---------------------------------------------------------
# 5. Sistem Dosyalarını (/etc) Uygulama
# ---------------------------------------------------------
# NOT: /etc dizini root yetkisi gerektirir. Güvenlik ve yetki sorunlarından kaçınmak için
#      /etc altındaki dosyalar symlink YAPILMAMALIDIR, cp komutu ile normal kopyalanır.
info "Sistem yapılandırma dosyaları (/etc) kopyalanıyor..."
if [ -d "$DIR/etc" ] && [ "$(ls -A "$DIR/etc")" ]; then
    sudo cp -r "$DIR/etc/"* /etc/
    success "Sistem geneli (/etc) yapılandırmaları uygulandı."
else
    info "/etc dizininde uygulanacak ayar bulunamadı."
fi

# ---------------------------------------------------------
# 6. Alt Betikleri (Sub-scripts) Çalıştırma
# ---------------------------------------------------------
info "Özel yapılandırma betikleri çalıştırılıyor..."

if [ -f "$DIR/installer/setup-libvirt.sh" ]; then
    info "-> Libvirt yapılandırılıyor..."
    sudo bash "$DIR/installer/setup-libvirt.sh"
fi

if [ -f "$DIR/installer/set-limine-resolution.sh" ]; then
    info "-> Limine bootloader çözünürlüğü ayarlanıyor..."
    sudo bash "$DIR/installer/set-limine-resolution.sh"
fi

# ---------------------------------------------------------
# 7. Son İşlemler & Servisler
# ---------------------------------------------------------
info "Gerekli servisler etkinleştiriliyor..."
sudo systemctl daemon-reload
sudo systemctl enable --now tailscaled.service 2>/dev/null || true

success "Kurulum başarıyla tamamlandı!"
echo -e "${YELLOW}Değişikliklerin tam anlamıyla etkili olması için bilgisayarınızı yeniden başlatmanız tavsiye edilir.${NC}"
