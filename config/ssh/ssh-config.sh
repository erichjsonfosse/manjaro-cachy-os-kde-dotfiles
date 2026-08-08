#!/usr/bin/env bash

logHeader "Configuring SSH & SSH-Agent"

# Ensure .ssh folder exists
mkdir -p "$HOMEDIR/.ssh"

ln -sf "$CONFIGDIR/ssh/config" "$HOMEDIR/.ssh/config"
chmod 600 "$HOMEDIR/.ssh/config"

logInfo "Enabling systemd ssh-agent..."
su "$LOGNAME" -c "XDG_RUNTIME_DIR=/run/user/\$(id -u \"\$LOGNAME\") systemctl --user enable --now ssh-agent.service"

if ! grep -q "export SSH_AUTH_SOCK" "$ZSHRC_FILE"; then
  echo "" >> "$ZSHRC_FILE"
  echo "export SSH_AUTH_SOCK=\"\$XDG_RUNTIME_DIR/ssh-agent.socket\"" >> "$ZSHRC_FILE"
fi

logSuccess "SSH and SSH-Agent configuration applied!"
