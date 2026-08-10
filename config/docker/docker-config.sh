#!/usr/bin/env bash

logHeader "Configuring Docker"

# Ensure the docker group exists before adding the user to it
if ! getent group docker >/dev/null; then
  logInfo "Creating docker group..."
  groupadd docker
fi

usermod -aG docker "$LOGNAME"

# Enable systemd docker service if it exists on the system
if systemctl list-unit-files | grep -q "docker.service"; then
  systemctl enable docker
  logSuccess "Docker configuration applied successfully!"
else
  logWarning "Docker service not found on this system. Skipping service activation..."
fi
