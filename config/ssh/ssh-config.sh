#!/usr/bin/env bash

# Ensure .ssh folder exists
mkdir -p "$HOMEDIR/.ssh"

cp "$CONFIGDIR/ssh/config" "$HOMEDIR/.ssh/config"
chmod 600 "$HOMEDIR/.ssh/config"

echo "Enabling systemd ssh-agent..."
systemctl --user enable --now ssh-agent.service

echo "" >> "$ZSHRC_FILE"
echo "export SSH_AUTH_SOCK=\"\$XDG_RUNTIME_DIR/ssh-agent.socket\"" >> "$ZSHRC_FILE"
