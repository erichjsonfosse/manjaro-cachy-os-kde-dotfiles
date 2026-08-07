#!/usr/bin/env bash


if [ "$OS_ID" = "manjaro" ]; then
  echo "Updating pacman mirrors..."
  pacman-mirrors --country Austria,Canada,Denmark,France,Germany,Greece,Italy,Japan,Netherlands,Sweden,Switzerland,United_Kingdom
fi

echo "Upgrading pacman packages..."
pacman -Syu
echo "Pacman packages upgraded"

declare -a packages=(
# Browsers
"vivaldi"
# Development
"aspnet-runtime"
"azure-cli"
"code"
"docker"
"docker-buildx"
"docker-compose"
"dotnet-host"
"dotnet-runtime"
"dotnet-sdk"
"dotnet-targeting-pack"
"nvm"
"openjdk-src"
"pyenv"
# Fonts
"noto-fonts-emoji"
"powerline-fonts"
"ttf-fira-code"
# Office
"libreoffice-fresh"
"libreoffice-fresh-nb"
"obsidian"
"xournalpp"
# Utilities
"curl"
"filezilla"
"gum"
"helm"
"inkscape"
"jq"
"kdeconnect"
"kubectl"
"make"
"mkcert"
"onefetch"
"pkgfile"
"qbittorrent"
"shellcheck"
"squashfuse"
"unzip"
"wl-clipboard"
"xclip"
"yakuake"
"zellij"
"zsh"
"zsh-autosuggestions"
"zsh-syntax-highlighting"
)

if [ "$OS_ID" = "manjaro" ]; then
  packages+=(
    "libpamac-flatpak-plugin"
    "libpamac-snap-plugin"
    "pamac"
  )
elif [ "$OS_ID" = "cachyos" ]; then
  echo "Removing CachyOS Zsh defaults..."
  pacman -Rns cachyos-zsh-config || true
  packages+=(
    "paru"
  )
fi

echo "Installing pacman packages..."
pacman -S --needed "${packages[@]}"


echo "Pacman packages installed"
