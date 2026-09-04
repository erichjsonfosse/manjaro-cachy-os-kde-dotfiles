#!/usr/bin/env bash

# In unattended mode, credentials are pre-populated from .dotfiles.unattended
if [ "${UNATTENDED:-false}" = "true" ]; then
  return 0 2>/dev/null || exit 0
fi

######################### Git Config ##########################
MANJARO_DOTFILES_GIT_CONFIG_NAME=$(gum input --prompt "Name for Git Config: ")
MANJARO_DOTFILES_GIT_CONFIG_EMAIL_ADDRESS=$(gum input --prompt "Email address for Git Config: ")

echo "MANJARO_DOTFILES_GIT_CONFIG_NAME=\"$MANJARO_DOTFILES_GIT_CONFIG_NAME\"" >> "$TEMPORARY_CONFIG_FILE_NAME"
echo "MANJARO_DOTFILES_GIT_CONFIG_EMAIL_ADDRESS=\"$MANJARO_DOTFILES_GIT_CONFIG_EMAIL_ADDRESS\"" >> "$TEMPORARY_CONFIG_FILE_NAME"
######################### Git Config ##########################
