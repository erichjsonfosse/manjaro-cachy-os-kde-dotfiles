#!/usr/bin/env bash


echo "Installing AUR packages..."

#sed -Ei '/EnableAUR/s/^#//' /etc/pamac.conf

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


echo "AUR packages installed"
