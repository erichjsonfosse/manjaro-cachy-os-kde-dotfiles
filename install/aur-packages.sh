#!/usr/bin/env bash


echo "Installing AUR packages..."

#sed -Ei '/EnableAUR/s/^#//' /etc/pamac.conf

if [ "$OS_ID" = "manjaro" ]; then
  if ! command -v paru &> /dev/null; then
    echo "Bootstrapping paru via pamac..."
    pamac build paru
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


echo "AUR packages installed"
