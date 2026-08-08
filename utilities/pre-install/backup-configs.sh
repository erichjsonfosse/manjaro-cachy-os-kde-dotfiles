#!/usr/bin/env bash

# This script creates backups of existing configurations before the installer modifies them.
# It is designed to work both sourced (inside init.sh) and as a standalone script.

# Fallback definitions for standalone execution
if [ -z "$HOMEDIR" ]; then
  HOMEDIR="$HOME"
fi

if [ -z "$LOGNAME" ]; then
  LOGNAME="$USER"
fi

if ! command -v logHeader &>/dev/null; then
  logHeader() { echo "=== $1 ==="; }
  logInfo() { echo "  [i] $1"; }
  logSuccess() { echo "  [✔] $1"; }
fi

logHeader "Creating Configuration Backups"

backup_dir="$HOMEDIR/.manjaro-cachy-os-kde-dotfiles-backup/$(date +"%Y-%m-%d-%H-%M")"

files_to_backup=(
  "$HOMEDIR/.config/kwinrulesrc"
  "$HOMEDIR/.config/kwinrc"
  "$HOMEDIR/.zshrc"
  "$HOMEDIR/.zshrc.local"
  "$HOMEDIR/.nanorc"
  "$HOMEDIR/.ssh/config"
  "$HOMEDIR/.gitconfig"
  "$HOMEDIR/.gitconfig.local"
)

backed_up=0
for file in "${files_to_backup[@]}"; do
  if [ -f "$file" ] || [ -L "$file" ]; then
    if [ "$backed_up" -eq 0 ]; then
      mkdir -p "$backup_dir"
      backed_up=1
    fi
    cp -a "$file" "$backup_dir/"
    logInfo "Backed up: $(basename "$file")"
  fi
done

if [ "$backed_up" -eq 1 ]; then
  # Maintain correct ownership of backup folder
  chown -R "$LOGNAME:$LOGNAME" "$HOMEDIR/.manjaro-cachy-os-kde-dotfiles-backup"
  logSuccess "Backups successfully saved to: ${backup_dir#$HOMEDIR/}"
else
  logInfo "No existing configurations found to backup."
fi
