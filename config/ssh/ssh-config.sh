#!/usr/bin/env bash

logHeader "Configuring SSH & SSH-Agent"

# Ensure .ssh folder exists
mkdir -p "$HOMEDIR/.ssh"

ln -sf "$CONFIGDIR/ssh/config" "$HOMEDIR/.ssh/config"
chmod 600 "$HOMEDIR/.ssh/config"

# Fix ownership immediately (vital if run as a standalone modular step!)
chown -R "$LOGNAME:$LOGNAME" "$HOMEDIR/.ssh"

logInfo "Enabling systemd ssh-agent..."
su "$LOGNAME" -c "XDG_RUNTIME_DIR=/run/user/\$(id -u \"\$LOGNAME\") systemctl --user enable --now ssh-agent.service"

# Ensure .zshrc exists before we grep/append to it
if [ ! -f "$ZSHRC_FILE" ]; then
  su "$LOGNAME" -c "touch \"$ZSHRC_FILE\""
fi

if ! grep -q "export SSH_AUTH_SOCK" "$ZSHRC_FILE"; then
  echo "" >> "$ZSHRC_FILE"
  echo "export SSH_AUTH_SOCK=\"\$XDG_RUNTIME_DIR/ssh-agent.socket\"" >> "$ZSHRC_FILE"
fi

logSuccess "SSH and SSH-Agent configuration applied!"
