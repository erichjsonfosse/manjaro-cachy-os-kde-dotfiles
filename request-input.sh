#!/bin/bash

tmpConfigFile="tmpConfigFile.tmp";

######################### Git Config ##########################
read -rp 'Git Config Name: ' MANJARO_DOTFILES_GITCONFIG_NAME
read -rp 'Git Config Email: ' MANJARO_DOTFILES_GITCONFIG_EMAIL

echo "MANJARO_DOTFILES_GITCONFIG_NAME=\"$MANJARO_DOTFILES_GITCONFIG_NAME\"" >> $tmpConfigFile
echo "MANJARO_DOTFILES_GITCONFIG_EMAIL=\"$MANJARO_DOTFILES_GITCONFIG_EMAIL\"" >> $tmpConfigFile
######################### Git Config ##########################

# Ensure .ssh folder exists
mkdir -p "$HOMEDIR/.ssh"

######################### SSH key files ##########################
while true; do
  read -rp "Generate SSH key files? (y/n)" yn
  case $yn in
    [Yy]* ) SSHKEYFILENAME="$HOMEDIR/.ssh/id_ed25519" && ssh-keygen -t ed25519 -f "$SSHKEYFILENAME" && chown "$LOGNAME":"$LOGNAME" "$SSHKEYFILENAME" && break;;
    [Nn]* ) break;;
    * ) echo "Please answer yes or no.";;
  esac
done
######################### SSH key files ##########################
