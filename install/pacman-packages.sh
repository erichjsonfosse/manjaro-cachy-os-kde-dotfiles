#!/bin/bash

echo "Upgrading pacman packages..."
pacman -Syu --noconfirm
echo "Pacman packages upgraded"

echo "Installing pacman packages..."
pacman -Sy --noconfirm \
 `# Browsers` \
 vivaldi \
 `# Development` \
 aspnet-runtime \
 atom \
 docker \
 docker-compose \
 dotnet-host \
 dotnet-runtime \
 dotnet-sdk \
 dotnet-targeting-pack \
 guake \
 libreoffice-fresh \
 openjdk-src \
 `# Fonts` \
 powerline-fonts \
 ttf-fira-code \
 `# Utilities` \
 curl \
 filezilla \
 inkscape \
 pamac \
 snapd \
 squashfuse \
 ufw \
 unzip \
 xournalpp \
 yakuake \
 zsh


echo "Pacman packages installed"

