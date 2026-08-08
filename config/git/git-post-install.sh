#!/usr/bin/env bash

logHeader "Applying Git Signing Key Configuration"

if [ -f "$GIT_CONFIG_FILE" ]; then
  # Replace signingkey placeholder in the .gitconfig file
  sed -i "s~MANJARO_DOTFILES_GIT_CONFIG_SIGNING_KEY~$MANJARO_DOTFILES_GIT_CONFIG_SIGNING_KEY~g" "$GIT_CONFIG_FILE"
  logSuccess "Git signing key successfully synchronized!"
else
  logWarning "Git configuration file ($GIT_CONFIG_FILE) not found. Skipping key replacement..."
fi
