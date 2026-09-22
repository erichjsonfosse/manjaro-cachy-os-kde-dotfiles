#!/usr/bin/env bash

# Symlink the main .gitconfig and .gitignore.global (run as user to preserve permissions)
su "$LOGNAME" -c "ln -sf \"$CONFIGDIR/git/.gitconfig\" \"$GIT_CONFIG_FILE\""
su "$LOGNAME" -c "ln -sf \"$CONFIGDIR/git/.gitignore.global\" \"$HOMEDIR/.gitignore.global\""

# Ensure local gitconfig exists (run as user)
su "$LOGNAME" -c "touch \"$HOMEDIR/.gitconfig.local\""

# Create a local gitconfig for user-specific credentials (run as user)
if [ -n "$DOTFILES_GIT_NAME" ]; then
  su "$LOGNAME" -c "git config --file \"$HOMEDIR/.gitconfig.local\" user.name \"$DOTFILES_GIT_NAME\""
fi

if [ -n "$DOTFILES_GIT_EMAIL" ]; then
  su "$LOGNAME" -c "git config --file \"$HOMEDIR/.gitconfig.local\" user.email \"$DOTFILES_GIT_EMAIL\""
fi

if [ -n "$DOTFILES_GIT_SIGNING_KEY" ]; then
  su "$LOGNAME" -c "git config --file \"$HOMEDIR/.gitconfig.local\" user.signingkey \"$DOTFILES_GIT_SIGNING_KEY\""
fi
