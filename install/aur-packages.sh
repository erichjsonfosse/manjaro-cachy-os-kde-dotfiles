#!/bin/bash

echo "Installing AUR packages..."

sed -Ei '/EnableAUR/s/^#//' /etc/pamac.conf

pamac build --no-confirm \
  google-chrome \
  flutter \
  insomnia-bin \
  insomnia-designer-bin \
  otf-fira-code-git \
  postman-bin \
  powershell-bin


echo "AUR packages installed"
