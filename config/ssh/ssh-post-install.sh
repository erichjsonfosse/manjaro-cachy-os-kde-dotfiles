#!/usr/bin/env bash

######################### SSH key files ##########################
while true; do
  read -rp "Generate SSH key files? (y/n)" yn
  case $yn in
    [Yy]* ) SSH_KEY_FILE="$HOMEDIR/.ssh/id_ed25519" && ssh-keygen -t ed25519 -C "$LOGNAME@$(hostname)" -f "$SSH_KEY_FILE" && chown "$LOGNAME":"$LOGNAME" "$SSH_KEY_FILE" && break;;
    [Nn]* ) break;;
    * ) echo "Please answer yes or no.";;
  esac
done
######################### SSH key files ##########################
SSH_PUBLIC_KEY_FILE="$SSH_KEY_FILE.pub"
SSH_PUBLIC_KEY_FILE_CONTENT=$(cat "$SSH_PUBLIC_KEY_FILE")

MANJARO_DOTFILES_GIT_CONFIG_SIGNING_KEY="$SSH_PUBLIC_KEY_FILE"
export MANJARO_DOTFILES_GIT_CONFIG_SIGNING_KEY

echo "MANJARO_DOTFILES_GIT_CONFIG_SIGNING_KEY=\"$SSH_PUBLIC_KEY_FILE\"" >> "$TEMPORARY_CONFIG_FILE_NAME"

echo "$MANJARO_DOTFILES_GIT_CONFIG_EMAIL_ADDRESS namespaces=\"git\" $SSH_PUBLIC_KEY_FILE_CONTENT" >> "$HOMEDIR/.ssh/allowed_signers"
