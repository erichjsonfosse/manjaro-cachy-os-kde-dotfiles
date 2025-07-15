#!/usr/bin/env bash

# Replace signingkey in the .gitconfig file
sed -i "s/MANJARO_DOTFILES_GIT_CONFIG_SIGNING_KEY/$MANJARO_DOTFILES_GIT_CONFIG_SIGNING_KEY/g" "$GIT_CONFIG_FILE"
