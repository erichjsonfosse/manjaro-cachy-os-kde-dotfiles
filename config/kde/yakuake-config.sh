#!/usr/bin/env bash

# Configure Yakuake settings and autostart
YAKUAKE_CONFIG_FILE="$HOMEDIR/.config/yakuakerc"
logInfo "Configuring Yakuake..."
writeKdeConfig "$YAKUAKE_CONFIG_FILE" "Behavior" "RememberFullscreen" "true"
writeKdeConfig "$YAKUAKE_CONFIG_FILE" "Dialogs" "FirstRun" "false"
writeKdeConfig "$YAKUAKE_CONFIG_FILE" "Window" "Height" "60"
writeKdeConfig "$YAKUAKE_CONFIG_FILE" "Window" "Width" "100"
chown "$LOGNAME:$LOGNAME" "$YAKUAKE_CONFIG_FILE" 2>/dev/null || true

# Enable Yakuake autostart on login
AUTOSTART_DIR="$HOMEDIR/.config/autostart"
YAKUAKE_AUTOSTART_FILE="$AUTOSTART_DIR/org.kde.yakuake.desktop"
logInfo "Configuring Yakuake to start automatically on login..."
mkdir -p "$AUTOSTART_DIR"

if [ -f "/usr/share/applications/org.kde.yakuake.desktop" ]; then
  cp "/usr/share/applications/org.kde.yakuake.desktop" "$YAKUAKE_AUTOSTART_FILE"
else
  cat << 'EOF' > "$YAKUAKE_AUTOSTART_FILE"
[Desktop Entry]
Categories=Qt;KDE;System;TerminalEmulator;
Comment=A drop-down terminal emulator based on KDE Konsole technology.
DBusActivatable=true
Exec=yakuake
GenericName=Drop-down Terminal
Icon=yakuake
Name=Yakuake
StartupNotify=false
Terminal=false
Type=Application
EOF
fi

chown -R "$LOGNAME:$LOGNAME" "$AUTOSTART_DIR" 2>/dev/null || true
