#!/usr/bin/env bash

logHeader "Applying Git Signing Key Configuration"

if [ -n "$DOTFILES_GIT_SIGNING_KEY" ]; then
  git config --file "$HOMEDIR/.gitconfig.local" user.signingkey "$DOTFILES_GIT_SIGNING_KEY"
  logSuccess "Git signing key successfully synchronized!"
else
  logInfo "No Git signing key specified (skipping)..."
fi
