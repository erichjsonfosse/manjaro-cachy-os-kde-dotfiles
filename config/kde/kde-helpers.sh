#!/usr/bin/env bash

# Helper to write KDE config cleanly via kwriteconfig6/5/kwriteconfig
writeKdeConfig() {
  local file="$1"
  local group="$2"
  local key="$3"
  local value="$4"

  if command -v kwriteconfig6 &> /dev/null; then
    kwriteconfig6 --notify --file "$file" --group "$group" --key "$key" "$value" 2>/dev/null || true
    # Reload KWin shortcut engine (Plasma 6)
    qdbus6 org.kde.KWin /KWin org.kde.KWin.reconfigure 2>/dev/null || true

    # Signal Global Settings update
    dbus-send --session --type=signal /KGlobalSettings org.kde.KGlobalSettings.notifyChange int32:3 int32:5 2>/dev/null || true
  else
    logWarning "kwriteconfig6 not found. Skipping config update for: $key"
  fi
  return 0
}

