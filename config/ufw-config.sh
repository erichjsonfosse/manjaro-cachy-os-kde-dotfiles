#!/bin/bash

echo "Configuring UFW..."

# Disabling iptables Service
systemctl disable iptables.service

# Enabling UFW Service
systemctl enable ufw.service

# Allowing ssh
ufw allow ssh

# Enabling
ufw enable

# Rebooting
while true; do
  read -rp "Reboot (recommended)? (y/n)" yn
  case $yn in
    [Yy]* ) reboot; exit;;
    [Nn]* ) break;;
    * ) echo "Please answer yes or no.";;
  esac
done
