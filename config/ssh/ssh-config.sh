#!/usr/bin/env bash

# Ensure .ssh folder exists
mkdir -p "$HOMEDIR/.ssh"

cp "$CONFIGDIR/ssh/config" "$HOMEDIR/.ssh/config"
chmod 600 "$HOMEDIR/.ssh/config"
