#!/usr/bin/env bash

logHeader "Configuring Paru (AUR Helper)"

PARU_CONFIG_DIR="$HOMEDIR/.config/paru"
mkdir -p "$PARU_CONFIG_DIR"

# Copy custom paru.conf
cp "$CONFIGDIR/paru/paru.conf" "$PARU_CONFIG_DIR/paru.conf"

# Fix ownership
chown -R "$LOGNAME:$LOGNAME" "$PARU_CONFIG_DIR"

logSuccess "Paru configuration applied successfully!"
