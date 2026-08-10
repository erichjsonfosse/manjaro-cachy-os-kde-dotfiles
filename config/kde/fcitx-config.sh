#!/usr/bin/env bash

# Configure Fcitx 5 Wayland Virtual Keyboard, /etc/environment variables, and layout profile
KWIN_CONFIG_FILE="$HOMEDIR/.config/kwinrc"

logInfo "Configuring KWin to use native KDE Plasma 6 keyboard layout switcher (kxkb)..."
writeKdeConfig "$KWIN_CONFIG_FILE" "Wayland" "InputMethod" ""

if [ -w "/etc/environment" ]; then
  # On KDE Wayland, KWin handles GTK & Qt input natively via Wayland text-input protocols.
  sed -i '/^GTK_IM_MODULE=/d' /etc/environment 2>/dev/null || true
  sed -i '/^QT_IM_MODULE=/d' /etc/environment 2>/dev/null || true
fi

FCITX5_PROFILE_DIR="$HOMEDIR/.config/fcitx5"
FCITX5_PROFILE_FILE="$FCITX5_PROFILE_DIR/profile"
FCITX5_CONFIG_FILE="$FCITX5_PROFILE_DIR/config"

if [ -d "$HOMEDIR/.config" ]; then
  mkdir -p "$FCITX5_PROFILE_DIR"
  cat << 'EOF' > "$FCITX5_PROFILE_FILE"
[Groups/0]
Name=Default
Default Layout=us
DefaultIM=keyboard-us

[Groups/0/Items/0]
Name=keyboard-us
Layout=

[Groups/0/Items/1]
Name=keyboard-no
Layout=

[GroupOrder]
0=Default
EOF

  cat << 'EOF' > "$FCITX5_CONFIG_FILE"
[Hotkey]
TriggerKeys=Super+space
EnumerateForwardKeys=Super+space
EnumerateSkipFirst=False

[Behavior]
WarnAboutImModule=False
EOF

  chown -R "$LOGNAME:$LOGNAME" "$FCITX5_PROFILE_DIR" 2>/dev/null || true

  # Reload Fcitx 5 daemon if currently running
  if pgrep -x fcitx5 > /dev/null; then
    USER_UID=$(id -u "$LOGNAME" 2>/dev/null || echo "1000")
    DBUS_ADDR="unix:path=/run/user/$USER_UID/bus"
    sudo -H -u "$LOGNAME" DBUS_SESSION_BUS_ADDRESS="$DBUS_ADDR" fcitx5-remote -r >/dev/null 2>&1 || true
  fi
fi
