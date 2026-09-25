#!/usr/bin/env bash

logHeader "Mirroring Zsh Configuration to Root"

if [ -f "$HOMEDIR/.zshrc" ]; then
  # Copying .zshrc to root home folder
  sudo cp "$HOMEDIR/.zshrc" /root/.zshrc
  sudo chsh -s /bin/zsh root 2>/dev/null || true
  logSuccess "Zsh configuration mirrored to root home folder successfully!"
else
  logWarning "User .zshrc file ($HOMEDIR/.zshrc) not found. Skipping root mirror..."
fi
