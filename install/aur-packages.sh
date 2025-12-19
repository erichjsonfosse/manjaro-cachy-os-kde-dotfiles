#!/usr/bin/env bash

echo "Clearing pamac build files cache..."
pamac clean --build-files --no-confirm

echo "Installing AUR packages..."

#sed -Ei '/EnableAUR/s/^#//' /etc/pamac.conf

declare -a packages=(
"google-chrome"
"ferdium-bin"
"hyphen-nb"
"insomnia-bin"
"kubent-bin"
"noson-app"
"openlens-bin"
"postman-bin"
"powershell-bin"
)

for p in "${packages[@]}"
do
  pamac build --no-confirm "$p"
done


echo "AUR packages installed"
