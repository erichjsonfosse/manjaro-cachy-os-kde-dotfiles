#!/bin/bash

echo "Upgrading pacman packages..."
pacman -Syu --noconfirm

echo "Installing pacman packages..."
pacman -Sy --noconfirm \
 `# Browsers` \
 vivaldi \
 `# Development` \
 docker \
 docker-compose \
 libreoffice-fresh \
 openjdk-src \
 `# Fonts` \
 powerline-fonts \
 ttf-fira-code \
 `# Utilities` \
 curl \
 filezilla \
 pamac \
 snapd \
 squashfuse \
 ufw \
 unzip \
 xournalpp \
 yakuake \
 zsh
