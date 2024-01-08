#!/bin/bash


echo "Updating pacman mirrors..."
pacman-mirrors -f5
echo "Upgrading pacman packages..."
pacman -Syu --noconfirm
echo "Pacman packages upgraded"

echo "Installing pacman packages..."
pacman -Sy --noconfirm \
 `# Browsers` \
 vivaldi \
 `# Development` \
 aspnet-runtime \
 docker \
 docker-compose \
 dotnet-host \
 dotnet-runtime \
 dotnet-sdk \
 dotnet-targeting-pack \
 libpamac-flatpak-plugin \
 libpamac-snap-plugin \
 nvm \
 openjdk-src \
 pyenv \
 `# Fonts` \
 noto-fonts-emoji \
 powerline-fonts \
 ttf-fira-code \
 `# Office` \
 libreoffice-fresh \
 libreoffice-fresh-nb \hyphen-nb \
 xournalpp \
 `# Utilities` \
 curl \
 filezilla \
 gufw \
 gum \
 helm \
 inkscape \
 jq \
 keditbookmarks \
 kubectl \
 make \
 pamac \
 shellcheck \
 snapd \
 squashfuse \
 ufw \
 unzip \
 xclip

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
askForReboot
