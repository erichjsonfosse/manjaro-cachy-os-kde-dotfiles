#!/bin/bash

echo "Installing AUR packages..."

sed -Ei '/EnableAUR/s/^#//' /etc/pamac.conf

pamac build --no-confirm \
  azure-cli-bin \
  google-chrome \
  ferdium-bin \
  flutter \
  insomnia-bin \
  insomnia-designer-bin \
  noson-app \
  otf-fira-code-git \
  postman-bin \
  powershell-bin \
  xxd-standalone


echo "AUR packages installed"
