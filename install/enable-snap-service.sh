#!/bin/bash

echo "Enabling snap service..."

# Enabling Service
systemctl enable --now snapd.socket

reboot
exit
