#!/usr/bin/env bash

# Symlink the main .gitconfig
ln -sf "$CONFIGDIR/git/.gitconfig" "$GIT_CONFIG_FILE"

# Create a local gitconfig for user-specific credentials
if [ -n "$MANJARO_DOTFILES_GIT_CONFIG_NAME" ]; then
  git config --file "$HOMEDIR/.gitconfig.local" user.name "$MANJARO_DOTFILES_GIT_CONFIG_NAME"
fi

if [ -n "$MANJARO_DOTFILES_GIT_CONFIG_EMAIL_ADDRESS" ]; then
  git config --file "$HOMEDIR/.gitconfig.local" user.email "$MANJARO_DOTFILES_GIT_CONFIG_EMAIL_ADDRESS"
fi

if [ -n "$MANJARO_DOTFILES_GIT_CONFIG_SIGNING_KEY" ]; then
  git config --file "$HOMEDIR/.gitconfig.local" user.signingkey "$MANJARO_DOTFILES_GIT_CONFIG_SIGNING_KEY"
fi
