#!/usr/bin/env bash

# Configure Fcitx 5 Wayland Virtual Keyboard, /etc/environment variables, and layout profile
KWIN_CONFIG_FILE="$HOMEDIR/.config/kwinrc"

if [ -f "/usr/share/applications/org.fcitx.Fcitx5.desktop" ]; then
  logInfo "Setting active Input Method to Fcitx 5..."
  writeKdeConfig "$KWIN_CONFIG_FILE" "Wayland" "InputMethod" "/usr/share/applications/org.fcitx.Fcitx5.desktop"
else
  logInfo "Fcitx 5 not installed. Using native KDE Plasma layout switcher (kxkb)..."
  writeKdeConfig "$KWIN_CONFIG_FILE" "Wayland" "InputMethod" ""
fi

if [ -w "/etc/environment" ]; then
  logInfo "Configuring Fcitx 5 environment variables in /etc/environment..."
  # On KDE Wayland, KWin handles GTK & Qt input natively via Wayland text-input protocols.
  # We clean up legacy GTK_IM_MODULE/QT_IM_MODULE and set XMODIFIERS for XWayland.
  sed -i '/^GTK_IM_MODULE=fcitx/d' /etc/environment 2>/dev/null || true
  sed -i '/^QT_IM_MODULE=fcitx/d' /etc/environment 2>/dev/null || true
  if [ -f "/usr/share/applications/org.fcitx.Fcitx5.desktop" ]; then
    if ! grep -q "^XMODIFIERS=@im=fcitx" /etc/environment 2>/dev/null; then
      echo "XMODIFIERS=@im=fcitx" >> /etc/environment
    fi
  fi
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

  writeKdeConfig "$FCITX5_CONFIG_FILE" "Hotkey" "TriggerKeys" "Super+space"
  writeKdeConfig "$FCITX5_CONFIG_FILE" "Hotkey/TriggerKeys" "0" "Super+space"
  writeKdeConfig "$FCITX5_CONFIG_FILE" "Hotkey/EnumerateForwardKeys" "0" "Super+space"
  writeKdeConfig "$FCITX5_CONFIG_FILE" "Behavior" "WarnAboutImModule" "False"
  chown -R "$LOGNAME:$LOGNAME" "$FCITX5_PROFILE_DIR" 2>/dev/null || true

  # Reload Fcitx 5 daemon if currently running
  if pgrep -x fcitx5 > /dev/null; then
    USER_UID=$(id -u "$LOGNAME" 2>/dev/null || echo "1000")
    DBUS_ADDR="unix:path=/run/user/$USER_UID/bus"
    sudo -H -u "$LOGNAME" DBUS_SESSION_BUS_ADDRESS="$DBUS_ADDR" fcitx5-remote -r 2>/dev/null || true
  fi
fi
