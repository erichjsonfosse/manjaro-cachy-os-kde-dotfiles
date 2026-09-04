#!/usr/bin/env bash

# Symlink the main .gitconfig and .gitignore.global (run as user to preserve permissions)
su "$LOGNAME" -c "ln -sf \"$CONFIGDIR/git/.gitconfig\" \"$GIT_CONFIG_FILE\""
su "$LOGNAME" -c "ln -sf \"$CONFIGDIR/git/.gitignore.global\" \"$HOMEDIR/.gitignore.global\""

# Create a local gitconfig for user-specific credentials (run as user)
if [ -n "$MANJARO_DOTFILES_GIT_CONFIG_NAME" ]; then
  su "$LOGNAME" -c "git config --file \"$HOMEDIR/.gitconfig.local\" user.name \"$MANJARO_DOTFILES_GIT_CONFIG_NAME\""
fi

if [ -n "$MANJARO_DOTFILES_GIT_CONFIG_EMAIL_ADDRESS" ]; then
  su "$LOGNAME" -c "git config --file \"$HOMEDIR/.gitconfig.local\" user.email \"$MANJARO_DOTFILES_GIT_CONFIG_EMAIL_ADDRESS\""
fi

if [ -n "$MANJARO_DOTFILES_GIT_CONFIG_SIGNING_KEY" ]; then
  su "$LOGNAME" -c "git config --file \"$HOMEDIR/.gitconfig.local\" user.signingkey \"$MANJARO_DOTFILES_GIT_CONFIG_SIGNING_KEY\""
fi
