#!/usr/bin/env bash


logHeader "Installing AUR packages"

#sed -Ei '/EnableAUR/s/^#//' /etc/pamac.conf

if [ "$OS_ID" = "manjaro" ]; then
  if ! command -v paru &> /dev/null; then
    logInfo "Bootstrapping paru manually..."
    sudo pacman -S --needed --noconfirm base-devel git cargo
    rm -rf /tmp/paru-bootstrap
    su "$LOGNAME" -c "git clone https://aur.archlinux.org/paru.git /tmp/paru-bootstrap"
    su "$LOGNAME" -c "cd /tmp/paru-bootstrap && makepkg -s"
    pacman -U --noconfirm /tmp/paru-bootstrap/paru-*.pkg.tar.zst
    rm -rf /tmp/paru-bootstrap
  fi
fi

declare -a packages=(
"antigravity"
"antigravity-cli"
"google-chrome"
"hyphen-nb"
"insomnia-bin"
"jetbrains-toolbox"
"kubent-bin"
"noson-app"
"openlens-bin"
"postman-bin"
"powershell-bin"
"slack-desktop"
)

sudo -u "$LOGNAME" paru -S "${packages[@]}"


logSuccess "AUR packages installed"
