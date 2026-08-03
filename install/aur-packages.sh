#!/usr/bin/env bash

if [ "$OS_ID" = "manjaro" ]; then
  echo "Clearing pamac build files cache..."
  pamac clean --build-files --no-confirm
fi

echo "Installing AUR packages..."

#sed -Ei '/EnableAUR/s/^#//' /etc/pamac.conf

declare -a packages=(
"antigravity"
"antigravity-cli"
"ferdium-bin"
"google-chrome"
"hyphen-nb"
"insomnia-bin"
"jetbrains-toolbox"
"kubent-bin"
"noson-app"
"openlens-bin"
"postman-bin"
"powershell-bin"
)

if [ "$OS_ID" = "manjaro" ]; then
  pamac build --no-confirm "${packages[@]}"
elif [ "$OS_ID" = "cachyos" ]; then
  sudo -u "$LOGNAME" paru -S --noconfirm "${packages[@]}"
else
  echo "Unsupported OS for AUR packages, skipping..."
fi


echo "AUR packages installed"
