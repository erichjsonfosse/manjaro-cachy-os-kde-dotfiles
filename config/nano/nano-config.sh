#!/usr/bin/env bash

# Enable syntax highlighting for nano
touch "$HOMEDIR/.nanorc"
if ! grep -q 'include /usr/share/nano-syntax-highlighting/\*.nanorc' "$HOMEDIR/.nanorc"; then
  echo "include /usr/share/nano-syntax-highlighting/*.nanorc" >> "$HOMEDIR/.nanorc"
fi
