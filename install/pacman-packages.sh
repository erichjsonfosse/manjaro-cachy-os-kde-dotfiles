#!/bin/bash


echo "Updating pacman mirrors..."
pacman-mirrors --country Austria,Canada,Denmark,France,Germany,Greece,Italy,Japan,Netherlands,Norway,Sweden,Switzerland,United_Kingdom
echo "Upgrading pacman packages..."
pacman -Syu --noconfirm
echo "Pacman packages upgraded"

declare -a packages=(
# Browsers
"vivaldi"
# Development
"aspnet-runtime"
"azure-cli"
"docker"
"docker-compose"
"docker-buildx"
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
"keditbookmarks"
"kubectl"
"libpamac-flatpak-plugin"
"libpamac-snap-plugin"
"make"
"onefetch"
"pamac"
"shellcheck"
"snapd"
"squashfuse"
"tinyxxd"
"unzip"
"xclip"
)

echo "Installing pacman packages..."
for p in "${packages[@]}"
do
  pacman -Sy --noconfirm "$p"
done


echo "Pacman packages installed"
askForReboot
