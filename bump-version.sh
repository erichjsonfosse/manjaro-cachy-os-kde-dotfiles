#!/usr/bin/env bash

# Create directory if it doesn't exist
mkdir -p "$HOMEDIR/.config/manjaro-dotfiles"

# Write current git commit hash as the version
git rev-parse HEAD > "$HOMEDIR/.config/manjaro-dotfiles/version"

echo "Version bumped to $(cat "$HOMEDIR/.config/manjaro-dotfiles/version")"
