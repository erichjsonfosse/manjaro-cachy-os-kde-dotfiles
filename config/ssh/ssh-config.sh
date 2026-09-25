#!/usr/bin/env bash

logHeader "Configuring SSH & SSH-Agent"

# Ensure .ssh folder exists
mkdir -p "$HOMEDIR/.ssh"

ln -sf "$CONFIGDIR/ssh/config" "$HOMEDIR/.ssh/config"
chmod 600 "$HOMEDIR/.ssh/config"

logInfo "Enabling systemd ssh-agent..."
systemctl --user enable --now ssh-agent.service

# Ensure .zshrc exists before we grep/append to it
if [ ! -f "$ZSHRC_FILE" ]; then
  touch "$ZSHRC_FILE"
fi

if ! grep -q "export SSH_AUTH_SOCK" "$ZSHRC_FILE"; then
  echo "" >> "$ZSHRC_FILE"
  echo "export SSH_AUTH_SOCK=\"\$XDG_RUNTIME_DIR/ssh-agent.socket\"" >> "$ZSHRC_FILE"
fi

logInfo "Configuring ksshaskpass and OpenSSH askpass symlink..."
if [ -x /usr/bin/ksshaskpass ] && [ ! -e /usr/lib/ssh/ssh-askpass ]; then
  if command -v sudo &>/dev/null && sudo -n true 2>/dev/null; then
    sudo mkdir -p /usr/lib/ssh
    sudo ln -sf /usr/bin/ksshaskpass /usr/lib/ssh/ssh-askpass
  fi
fi

# Ensure GUI applications (Obsidian, IDEs) inherit SSH_ASKPASS across Plasma 6
mkdir -p "$HOMEDIR/.config/environment.d"
cat << 'EOF' > "$HOMEDIR/.config/environment.d/ssh-askpass.conf"
SSH_ASKPASS="/usr/bin/ksshaskpass"
SSH_ASKPASS_REQUIRE="prefer"
EOF

if ! grep -q "export SSH_ASKPASS" "$ZSHRC_FILE"; then
  echo "export SSH_ASKPASS=\"/usr/bin/ksshaskpass\"" >> "$ZSHRC_FILE"
  echo "export SSH_ASKPASS_REQUIRE=\"prefer\"" >> "$ZSHRC_FILE"
fi

logSuccess "SSH, SSH-Agent, and ksshaskpass configuration applied!"
