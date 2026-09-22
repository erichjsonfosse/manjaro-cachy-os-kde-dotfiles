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

logInfo "Configuring ksshaskpass and OpenSSH askpass symlink..."
mkdir -p /usr/lib/ssh
if [ -x /usr/bin/ksshaskpass ] || [ -f /usr/bin/ksshaskpass ]; then
  ln -sf /usr/bin/ksshaskpass /usr/lib/ssh/ssh-askpass
fi

# Ensure GUI applications (Obsidian, IDEs) inherit SSH_ASKPASS across Plasma 6
mkdir -p "$HOMEDIR/.config/environment.d"
cat << 'EOF' > "$HOMEDIR/.config/environment.d/ssh-askpass.conf"
SSH_ASKPASS="/usr/bin/ksshaskpass"
SSH_ASKPASS_REQUIRE="prefer"
EOF
chown -R "$LOGNAME:$LOGNAME" "$HOMEDIR/.config/environment.d"

if ! grep -q "export SSH_ASKPASS" "$ZSHRC_FILE"; then
  echo "export SSH_ASKPASS=\"/usr/bin/ksshaskpass\"" >> "$ZSHRC_FILE"
  echo "export SSH_ASKPASS_REQUIRE=\"prefer\"" >> "$ZSHRC_FILE"
fi

logSuccess "SSH, SSH-Agent, and ksshaskpass configuration applied!"
