#!/usr/bin/env bash

logHeader "Configuring Vivaldi Web Browser"

# Set as default browser
if command -v xdg-settings &> /dev/null; then
  su "$LOGNAME" -c "xdg-settings set default-web-browser vivaldi-stable.desktop" || true
else
  logWarning "xdg-settings not found, skipping default browser assignment."
fi

# Copy Vivaldi config if it exists in the dotfiles repo
DOTFILES_VIVALDI_CONFIG="$CONFIGDIR/vivaldi/Default"
SYSTEM_VIVALDI_CONFIG="$HOMEDIR/.config/vivaldi/Default"

if [ -d "$DOTFILES_VIVALDI_CONFIG" ]; then
  logInfo "Found Vivaldi profile template in dotfiles, copying..."
  mkdir -p "$SYSTEM_VIVALDI_CONFIG"
  cp -r "$DOTFILES_VIVALDI_CONFIG/"* "$SYSTEM_VIVALDI_CONFIG/"
  
  # Process Preferences.template if present
  if [ -f "$SYSTEM_VIVALDI_CONFIG/Preferences.template" ]; then
    logInfo "Processing Vivaldi Preferences template and mapping paths..."
    sed "s|__USER_HOME__|$HOMEDIR|g" "$SYSTEM_VIVALDI_CONFIG/Preferences.template" > "$SYSTEM_VIVALDI_CONFIG/Preferences"
    rm -f "$SYSTEM_VIVALDI_CONFIG/Preferences.template"
  fi

  # Ensure correct ownership
  chown -R "$LOGNAME:$LOGNAME" "$HOMEDIR/.config/vivaldi"
  logSuccess "Vivaldi configuration successfully applied!"
else
  logWarning "No Vivaldi profile template found in dotfiles at $DOTFILES_VIVALDI_CONFIG. Skipping config sync."
fi
