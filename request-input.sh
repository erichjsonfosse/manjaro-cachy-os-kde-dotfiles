#!/usr/bin/env bash

######################### Git Config ##########################
read -rp 'Name for Git Config: ' MANJARO_DOTFILES_GIT_CONFIG_NAME
read -rp 'Email address for Git Config: ' MANJARO_DOTFILES_GIT_CONFIG_EMAIL_ADDRESS

echo "MANJARO_DOTFILES_GIT_CONFIG_NAME=\"$MANJARO_DOTFILES_GIT_CONFIG_NAME\"" >> "$TEMPORARY_CONFIG_FILE_NAME"
echo "MANJARO_DOTFILES_GIT_CONFIG_EMAIL_ADDRESS=\"$MANJARO_DOTFILES_GIT_CONFIG_EMAIL_ADDRESS\"" >> "$TEMPORARY_CONFIG_FILE_NAME"
######################### Git Config ##########################
