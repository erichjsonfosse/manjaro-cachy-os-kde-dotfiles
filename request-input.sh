#!/usr/bin/env bash

# In unattended mode, credentials are pre-populated from .dotfiles.unattended
if [ "${UNATTENDED:-false}" = "true" ]; then
  return 0 2>/dev/null || exit 0
fi

######################### Git Config ##########################
DOTFILES_GIT_NAME=$(gum input --prompt "Name for Git Config: ")
DOTFILES_GIT_EMAIL=$(gum input --prompt "Email address for Git Config: ")

echo "DOTFILES_GIT_NAME=\"$DOTFILES_GIT_NAME\"" >> "$TEMPORARY_CONFIG_FILE_NAME"
echo "DOTFILES_GIT_EMAIL=\"$DOTFILES_GIT_EMAIL\"" >> "$TEMPORARY_CONFIG_FILE_NAME"
######################### Git Config ##########################
