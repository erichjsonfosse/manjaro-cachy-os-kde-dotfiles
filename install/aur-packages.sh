#!/bin/bash

echo "Installing AUR packages..."

sed -Ei '/EnableAUR/s/^#//' /etc/pamac.conf

pamac build --no-confirm \
  google-chrome \
  ferdium-bin \
  flutter \
  insomnia-bin \
  insomnia-designer-bin \
  postman-bin \
  powershell-bin


echo "AUR packages installed"
