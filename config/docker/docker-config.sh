#!/usr/bin/env bash

# Add user to docker group
usermod -aG docker "$LOGNAME"
askForReboot
