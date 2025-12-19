#!/usr/bin/env bash

# Add user to docker group
usermod -aG docker "$LOGNAME"
systemctl enable docker

askForReboot
