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
 libpamac-flatpak-plugin \
 libpamac-snap-plugin \
 libreoffice-fresh \
 openjdk-src \
 `# Fonts` \
 powerline-fonts \
 ttf-fira-code \
 `# Utilities` \
 curl \
 filezilla \
 helm \
 inkscape \
 jq \
 keditbookmarks \
 kubectl \
 pamac \
 snapd \
 squashfuse \
 ufw \
 unzip \
 xournalpp

if [ "$XDG_CURRENT_DESKTOP" = 'GNOME' ]
 then
  pacman -Sy --noconfirm \
   gnome-shell-extension-gsconnect \
   guake
fi

if [ "$XDG_CURRENT_DESKTOP" = 'KDE' ]
 then
  pacman -Sy --noconfirm \
   yakuake \
   zsh
fi


echo "Pacman packages installed"

