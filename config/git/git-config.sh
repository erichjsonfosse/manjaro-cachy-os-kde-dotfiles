#!/usr/bin/env bash

# Add .gitconfig
cp -f "$CONFIGDIR/git/.gitconfig" "$GIT_CONFIG_FILE"

# Replace name and email in the .gitconfig file
sed -i "s/MANJARO_DOTFILES_GIT_CONFIG_NAME/$MANJARO_DOTFILES_GIT_CONFIG_NAME/g" "$GIT_CONFIG_FILE"
sed -i "s/MANJARO_DOTFILES_GIT_CONFIG_EMAIL_ADDRESS/$MANJARO_DOTFILES_GIT_CONFIG_EMAIL_ADDRESS/g" "$GIT_CONFIG_FILE"
