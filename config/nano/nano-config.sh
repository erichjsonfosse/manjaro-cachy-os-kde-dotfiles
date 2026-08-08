#!/usr/bin/env bash

logHeader "Configuring Nano Editor"
NANORC_FILE="$HOMEDIR/.nanorc"
touch "$NANORC_FILE"

# 1. Enable syntax highlighting
if ! grep -q 'include /usr/share/nano-syntax-highlighting/\*.nanorc' "$NANORC_FILE"; then
  echo "include /usr/share/nano-syntax-highlighting/*.nanorc" >> "$NANORC_FILE"
fi

# 2. Append general editor options
# Use grouped redirects (SC2129 compliant)
{
  # Check and append only if they aren't already present
  for opt in \
    "set linenumbers" \
    "set tabsize 2" \
    "set tabstospaces" \
    "set constantshow" \
    "set mouse" \
    "set softwrap"; do
    
    # Strip 'set ' prefix to search for key uniquely
    key="${opt#set }"
    if ! grep -q "set $key" "$NANORC_FILE"; then
      echo "$opt"
    fi
  done
} >> "$NANORC_FILE"

# Ensure correct ownership
chown "$LOGNAME:$LOGNAME" "$NANORC_FILE"

logSuccess "Nano editor successfully configured with 2-space tabs!"
