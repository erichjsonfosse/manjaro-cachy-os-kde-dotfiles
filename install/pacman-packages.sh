#!/usr/bin/env bash


if [ "$OS_ID" = "manjaro" ]; then
  echo "Updating pacman mirrors..."
  pacman-mirrors --country Austria,Canada,Denmark,France,Germany,Greece,Italy,Japan,Netherlands,Norway,Sweden,Switzerland,United_Kingdom
fi

echo "Upgrading pacman packages..."
pacman -Syu --noconfirm
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
"gnome-shell-extension-gsconnect"
"guake"
"gum"
"helm"
"inkscape"
"jq"
"kubectl"
"make"
"onefetch"
"pkgfile"
"qbittorrent"
"shellcheck"
"squashfuse"
"tinyxxd"
"unzip"
"xclip"
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
  pacman -Rns --noconfirm cachyos-zsh-config || true
fi

echo "Installing pacman packages..."
pacman -S --needed --noconfirm "${packages[@]}"


echo "Pacman packages installed"
askForReboot
