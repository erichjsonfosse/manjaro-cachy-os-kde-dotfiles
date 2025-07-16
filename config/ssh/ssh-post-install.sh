#!/usr/bin/env bash

######################### SSH key files ##########################
while true; do
  read -rp "Generate SSH key files? (y/n)" yn
  case $yn in
    [Yy]* ) SSH_KEY_FILE_NAME="$HOMEDIR/.ssh/id_ed25519" && ssh-keygen -t ed25519 -C "$LOGNAME@$HOST" -f "$SSH_KEY_FILE_NAME" && chown "$LOGNAME":"$LOGNAME" "$SSH_KEY_FILE_NAME" && break;;
    [Nn]* ) break;;
    * ) echo "Please answer yes or no.";;
  esac
done
######################### SSH key files ##########################
MANJARO_DOTFILES_GIT_CONFIG_SIGNING_KEY="$SSH_KEY_FILE_NAME"
export MANJARO_DOTFILES_GIT_CONFIG_SIGNING_KEY

echo "MANJARO_DOTFILES_GIT_CONFIG_SIGNING_KEY=\"$SSH_KEY_FILE_NAME.pub\"" >> "$TEMPORARY_CONFIG_FILE_NAME"

SSH_PUBLIC_KEY_FILE_CONTENT=$(cat ~/.ssh/"$SSH_KEY_FILE_NAME".pub)
echo "$MANJARO_DOTFILES_GIT_CONFIG_EMAIL_ADDRESS namespaces=\"git\" $SSH_PUBLIC_KEY_FILE_CONTENT" >> ~/.ssh/allowed_signers
