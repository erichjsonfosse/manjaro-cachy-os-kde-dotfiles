#!/usr/bin/env bash

HERDR_CONFIG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
HERDR_USER_DIR="$HOMEDIR/.config/herdr"
HERDR_CONFIG_FILE="$HERDR_USER_DIR/config.toml"
HERDR_LOCAL_CONFIG="$HERDR_USER_DIR/config.local.toml"

logHeader "Configuring Herdr workspace manager"

mkdir -p "$HERDR_USER_DIR"
mkdir -p "$HOMEDIR/.local/bin"

if [ -f "$HERDR_LOCAL_CONFIG" ]; then
  logInfo "Found local Herdr configuration ($HERDR_LOCAL_CONFIG). Assembling config.toml with local overrides..."
  rm -f "$HERDR_CONFIG_FILE"
  cat "$HERDR_CONFIG_DIR/config.toml" "$HERDR_LOCAL_CONFIG" > "$HERDR_CONFIG_FILE"
else
  logInfo "Linking base Herdr configuration to $HERDR_CONFIG_FILE..."
  rm -f "$HERDR_CONFIG_FILE"
  ln -sf "$HERDR_CONFIG_DIR/config.toml" "$HERDR_CONFIG_FILE"
fi

chown -R "$LOGNAME:$LOGNAME" "$HERDR_USER_DIR" 2>/dev/null || true
chown -R "$LOGNAME:$LOGNAME" "$HOMEDIR/.local" 2>/dev/null || true

# Install Herdr plugins
if command -v herdr &>/dev/null; then
  logInfo "Checking Herdr plugin: herdr-hud (erichjsonfosse/herdr-hud)..."
  if ! sudo -H -u "$LOGNAME" herdr plugin list 2>/dev/null | grep -q "herdr-hud"; then
    logInfo "Installing herdr-hud plugin from GitHub..."
    sudo -H -u "$LOGNAME" env PATH="$HOMEDIR/.local/bin:$PATH" herdr plugin install erichjsonfosse/herdr-hud 2>/dev/null || logWarning "Could not install herdr-hud plugin (offline or build skipped)"
  else
    logInfo "herdr-hud plugin is already installed"
  fi
fi

logSuccess "Herdr configuration applied"
