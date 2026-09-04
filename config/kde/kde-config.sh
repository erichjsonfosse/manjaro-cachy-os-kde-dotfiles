#!/usr/bin/env bash

# Master KDE & KWin Configuration Orchestrator
KDE_CONFIG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source shared helpers
source "$KDE_CONFIG_DIR/kde-helpers.sh"

# Source modular KDE sub-configurations
source "$KDE_CONFIG_DIR/kwin-config.sh"
source "$KDE_CONFIG_DIR/yakuake-config.sh"
source "$KDE_CONFIG_DIR/keyboard-config.sh"
# Ensure KWin Wayland InputMethod is empty (using native KDE kxkb layout switcher)
writeKdeConfig "$HOMEDIR/.config/kwinrc" "Wayland" "InputMethod" ""

# Clean up any residual Fcitx5 user configs and environment variables
rm -rf "$HOMEDIR/.config/fcitx5" "$HOMEDIR/.config/autostart/org.fcitx.Fcitx5.desktop" "$HOMEDIR/.config/autostart/fcitx5.desktop" 2>/dev/null || true
if [ -f "/etc/environment" ]; then
  sudo sed -i '/^GTK_IM_MODULE=/d' /etc/environment 2>/dev/null || true
  sudo sed -i '/^QT_IM_MODULE=/d' /etc/environment 2>/dev/null || true
  sudo sed -i '/^XMODIFIERS=/d' /etc/environment 2>/dev/null || true
fi

# Notify kwin and kglobalaccel to reload configurations if running
if pgrep -x kwin_wayland > /dev/null || pgrep -x kwin_x11 > /dev/null; then
  USER_UID=$(id -u "$LOGNAME" 2>/dev/null || echo "1000")
  DBUS_ADDR="unix:path=/run/user/$USER_UID/bus"
  sudo -H -u "$LOGNAME" DBUS_SESSION_BUS_ADDRESS="$DBUS_ADDR" qdbus6 org.kde.KWin /KWin reconfigure >/dev/null 2>&1 || true
  sudo -H -u "$LOGNAME" DBUS_SESSION_BUS_ADDRESS="$DBUS_ADDR" qdbus6 org.kde.keyboard /Layouts reloadConfig >/dev/null 2>&1 || true
  sudo -H -u "$LOGNAME" DBUS_SESSION_BUS_ADDRESS="$DBUS_ADDR" qdbus6 org.kde.kglobalaccel /kglobalaccel reloadConfig >/dev/null 2>&1 || true

  # Launch or restart Yakuake so it is active immediately in the live session
  if command -v yakuake &>/dev/null; then
    pkill -x yakuake 2>/dev/null || true
    sleep 0.3
    sudo -H -u "$LOGNAME" DBUS_SESSION_BUS_ADDRESS="$DBUS_ADDR" yakuake &>/dev/null &
    disown
  fi
fi

logSuccess "KDE, KWin, and Keyboard configurations successfully finalized!"
