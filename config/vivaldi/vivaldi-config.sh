#!/usr/bin/env bash

echo "Configuring Vivaldi as default browser..."

# Set as default browser
if command -v xdg-settings &> /dev/null; then
  xdg-settings set default-web-browser vivaldi-stable.desktop || true
else
  echo "xdg-settings not found, skipping default browser assignment."
fi

# Copy Vivaldi config if it exists in the dotfiles repo
DOTFILES_VIVALDI_CONFIG="$CONFIGDIR/vivaldi/Default"
SYSTEM_VIVALDI_CONFIG="$HOMEDIR/.config/vivaldi/Default"

if [ -d "$DOTFILES_VIVALDI_CONFIG" ]; then
  echo "Found Vivaldi config in dotfiles, copying to $SYSTEM_VIVALDI_CONFIG..."
  mkdir -p "$SYSTEM_VIVALDI_CONFIG"
  cp -r "$DOTFILES_VIVALDI_CONFIG/"* "$SYSTEM_VIVALDI_CONFIG/"
  
  # Ensure correct ownership
  chown -R "$LOGNAME:$LOGNAME" "$HOMEDIR/.config/vivaldi"
else
  echo "No Vivaldi config found in dotfiles at $DOTFILES_VIVALDI_CONFIG. Skipping config sync."
fi
