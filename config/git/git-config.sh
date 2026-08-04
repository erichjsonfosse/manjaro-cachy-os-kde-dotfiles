#!/usr/bin/env bash

# Symlink the main .gitconfig
ln -sf "$CONFIGDIR/git/.gitconfig" "$GIT_CONFIG_FILE"

# Create a local gitconfig for user-specific credentials
cat << EOF > "$HOMEDIR/.gitconfig.local"
[user]
	name = $MANJARO_DOTFILES_GIT_CONFIG_NAME
	email = $MANJARO_DOTFILES_GIT_CONFIG_EMAIL_ADDRESS
	signingkey = $MANJARO_DOTFILES_GIT_CONFIG_SIGNING_KEY
EOF
