#!/bin/bash

echo "Enabling snap service..."

# Enabling Service
systemctl enable --now snapd.socket
systemctl enable --now snapd.service

while true; do
  read -rp "Reboot (recommended)? (y/n)" yn
  case $yn in
    [Yy]* ) reboot; exit;;
    [Nn]* ) break;;
    * ) echo "Please answer yes or no.";;
  esac
done

