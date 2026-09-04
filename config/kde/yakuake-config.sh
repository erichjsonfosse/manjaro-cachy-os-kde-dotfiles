#!/usr/bin/env bash

# Configure Yakuake settings and autostart
YAKUAKE_CONFIG_FILE="$HOMEDIR/.config/yakuakerc"
AUTOSTART_DIR="$HOMEDIR/.config/autostart"
YAKUAKE_AUTOSTART_FILE="$AUTOSTART_DIR/org.kde.yakuake.desktop"

logInfo "Configuring Yakuake..."

# Stop any running Yakuake instance so in-memory state doesn't overwrite yakuakerc on exit
pkill -x yakuake 2>/dev/null || true
sleep 0.3

mkdir -p "$HOMEDIR/.config" "$AUTOSTART_DIR"
chown -R "$LOGNAME:$LOGNAME" "$HOMEDIR/.config" 2>/dev/null || true

writeKdeConfig "$YAKUAKE_CONFIG_FILE" "Behavior" "RememberFullscreen" "true"
writeKdeConfig "$YAKUAKE_CONFIG_FILE" "Dialogs" "FirstRun" "false"
writeKdeConfig "$YAKUAKE_CONFIG_FILE" "Window" "Height" "60"
writeKdeConfig "$YAKUAKE_CONFIG_FILE" "Window" "Width" "100"
writeKdeConfig "$YAKUAKE_CONFIG_FILE" "Window" "KeepAbove" "true"
writeKdeConfig "$YAKUAKE_CONFIG_FILE" "Window" "KeepOpen" "false"
chown "$LOGNAME:$LOGNAME" "$YAKUAKE_CONFIG_FILE" 2>/dev/null || true

# Enable Yakuake autostart on login (without DBusActivatable so systemd launches it reliably)
logInfo "Configuring Yakuake to start automatically on login..."
cat << 'EOF' > "$YAKUAKE_AUTOSTART_FILE"
[Desktop Entry]
Categories=Qt;KDE;System;TerminalEmulator;
Comment=A drop-down terminal emulator based on KDE Konsole technology.
Exec=yakuake
GenericName=Drop-down Terminal
Icon=yakuake
Name=Yakuake
StartupNotify=false
Terminal=false
Type=Application
X-KDE-AutostartScript=true
EOF

# Remove legacy/duplicate autostart entry if present
rm -f "$AUTOSTART_DIR/yakuake.desktop" 2>/dev/null || true
chown -R "$LOGNAME:$LOGNAME" "$AUTOSTART_DIR" 2>/dev/null || true
