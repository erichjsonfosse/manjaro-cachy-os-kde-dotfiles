#!/usr/bin/env bash

# Helper to write KDE config cleanly via kwriteconfig6/5/kwriteconfig
writeKdeConfig() {
  local file="$1"
  local group="$2"
  local key="$3"
  local value="$4"

  if command -v kwriteconfig6 &> /dev/null; then
    sudo -H -u "$LOGNAME" kwriteconfig6 --file "$file" --group "$group" --key "$key" "$value" 2>/dev/null || true
  elif command -v kwriteconfig5 &> /dev/null; then
    sudo -H -u "$LOGNAME" kwriteconfig5 --file "$file" --group "$group" --key "$key" "$value" 2>/dev/null || true
  elif command -v kwriteconfig &> /dev/null; then
    sudo -H -u "$LOGNAME" kwriteconfig --file "$file" --group "$group" --key "$key" "$value" 2>/dev/null || true
  else
    logWarning "KDE config utility (kwriteconfig) not found. Skipping config update for: $key"
  fi
  return 0
}
