#!/bin/bash

echo "Upgrading pacman packages..."
pacman -Syu --noconfirm

echo "Installing pacman packages..."
pacman -Sy --noconfirm \
 appimagelauncher \
 libappimage \
 `# Browsers` \
 chromium \
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
 konsole \
 pamac \
 snapd \
 squashfuse \
 ufw \
 unzip \
 xournalpp \
 yakuake \
 zsh
