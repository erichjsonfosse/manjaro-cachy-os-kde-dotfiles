#!/usr/bin/env bash

# Configure Fcitx 5 Wayland Virtual Keyboard, /etc/environment variables, and layout profile
KWIN_CONFIG_FILE="$HOMEDIR/.config/kwinrc"

logInfo "Configuring KWin Wayland to use Fcitx 5 input method..."
writeKdeConfig "$KWIN_CONFIG_FILE" "Wayland" "InputMethod" "/usr/share/applications/org.fcitx.Fcitx5.desktop"

if [ -f "/etc/environment" ]; then
  # On KDE Plasma Wayland, KWin handles GTK & Qt input natively via Wayland text-input protocols.
  # Do NOT set GTK_IM_MODULE or QT_IM_MODULE on Wayland, as it triggers Fcitx 5 Wayland Diagnose warnings.
  sudo sed -i '/^GTK_IM_MODULE=/d' /etc/environment 2>/dev/null || true
  sudo sed -i '/^QT_IM_MODULE=/d' /etc/environment 2>/dev/null || true
  if ! grep -q "^XMODIFIERS=" /etc/environment 2>/dev/null; then
    echo "XMODIFIERS=@im=fcitx" | sudo tee -a /etc/environment >/dev/null || true
  fi
fi

FCITX5_PROFILE_DIR="$HOMEDIR/.config/fcitx5"
FCITX5_PROFILE_FILE="$FCITX5_PROFILE_DIR/profile"
FCITX5_CONFIG_FILE="$FCITX5_PROFILE_DIR/config"
AUTOSTART_DIR="$HOMEDIR/.config/autostart"
SHORTCUTS_CONFIG_FILE="$HOMEDIR/.config/kglobalshortcutsrc"

if [ -d "$HOMEDIR/.config" ]; then
  mkdir -p "$FCITX5_PROFILE_DIR" "$AUTOSTART_DIR"

  # Ensure Fcitx 5 autostart desktop entry exists
  cat << 'EOF' > "$AUTOSTART_DIR/org.fcitx.Fcitx5.desktop"
[Desktop Entry]
Name=Fcitx 5
Exec=fcitx5
Icon=org.fcitx.Fcitx5
Type=Application
Categories=Utility;
X-KDE-StartupNotify=false
X-KDE-autostart-after=panel
EOF

  cat << 'EOF' > "$FCITX5_PROFILE_FILE"
[Groups/0]
Name=Default
Default Layout=us
DefaultIM=keyboard-us

[Groups/0/Items/0]
Name=keyboard-us
Layout=us

[Groups/0/Items/1]
Name=keyboard-no
Layout=no

[GroupOrder]
0=Default
EOF

  cat << 'EOF' > "$FCITX5_CONFIG_FILE"
[Hotkey]
TriggerKeys=Super+Space
AltTriggerKeys=Alt+Shift
EnumerateForwardKeys=Super+Space
EnumerateSkipFirst=False

[Behavior]
WarnAboutImModule=False
EOF

  # Register Meta+Space for Fcitx 5 in KDE Plasma global shortcuts
  for desktop_id in "org.fcitx.Fcitx5.desktop" "fcitx5.desktop" "fcitx5"; do
    writeKdeConfig "$SHORTCUTS_CONFIG_FILE" "$desktop_id" "ToggleIM" "Meta+Space,none,Toggle Input Method"
    writeKdeConfig "$SHORTCUTS_CONFIG_FILE" "$desktop_id" "SwitchForward" "Meta+Space,none,Switch to Next Input Method"
  done

  chown -R "$LOGNAME:$LOGNAME" "$FCITX5_PROFILE_DIR" "$AUTOSTART_DIR" 2>/dev/null || true

  # Reload Fcitx 5 daemon if currently running
  if pgrep -x fcitx5 > /dev/null; then
    USER_UID=$(id -u "$LOGNAME" 2>/dev/null || echo "1000")
    DBUS_ADDR="unix:path=/run/user/$USER_UID/bus"
    sudo -H -u "$LOGNAME" DBUS_SESSION_BUS_ADDRESS="$DBUS_ADDR" fcitx5-remote -r >/dev/null 2>&1 || true
  fi
fi
