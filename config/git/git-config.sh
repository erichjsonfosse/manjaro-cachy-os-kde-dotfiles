#!/usr/bin/env bash

# Symlink the main .gitconfig and .gitignore.global
ln -sf "$CONFIGDIR/git/.gitconfig" "$GIT_CONFIG_FILE"
ln -sf "$CONFIGDIR/git/.gitignore.global" "$HOMEDIR/.gitignore.global"

# Ensure local gitconfig exists
touch "$HOMEDIR/.gitconfig.local"

# Create a local gitconfig for user-specific credentials
if [ -n "$DOTFILES_GIT_NAME" ]; then
  git config --file "$HOMEDIR/.gitconfig.local" user.name "$DOTFILES_GIT_NAME"
fi

if [ -n "$DOTFILES_GIT_EMAIL" ]; then
  git config --file "$HOMEDIR/.gitconfig.local" user.email "$DOTFILES_GIT_EMAIL"
fi

if [ -n "$DOTFILES_GIT_SIGNING_KEY" ]; then
  git config --file "$HOMEDIR/.gitconfig.local" user.signingkey "$DOTFILES_GIT_SIGNING_KEY"
fi
