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
askForReboot
