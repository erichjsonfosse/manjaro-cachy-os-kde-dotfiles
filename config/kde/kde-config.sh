#!/usr/bin/env bash

# Master KDE & KWin Configuration Orchestrator
KDE_CONFIG_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Source shared helpers
source "$KDE_CONFIG_DIR/kde-helpers.sh"

# Source modular KDE sub-configurations
source "$KDE_CONFIG_DIR/kwin-config.sh"
source "$KDE_CONFIG_DIR/yakuake-config.sh"
source "$KDE_CONFIG_DIR/keyboard-config.sh"
source "$KDE_CONFIG_DIR/fcitx-config.sh"

# Notify kwin and kglobalaccel to reload configurations if running
if pgrep -x kwin_wayland > /dev/null || pgrep -x kwin_x11 > /dev/null; then
  USER_UID=$(id -u "$LOGNAME" 2>/dev/null || echo "1000")
  DBUS_ADDR="unix:path=/run/user/$USER_UID/bus"
  sudo -H -u "$LOGNAME" DBUS_SESSION_BUS_ADDRESS="$DBUS_ADDR" qdbus6 org.kde.KWin /KWin reconfigure 2>/dev/null || \
  sudo -H -u "$LOGNAME" DBUS_SESSION_BUS_ADDRESS="$DBUS_ADDR" qdbus org.kde.KWin /KWin reconfigure 2>/dev/null || true
  sudo -H -u "$LOGNAME" DBUS_SESSION_BUS_ADDRESS="$DBUS_ADDR" qdbus6 org.kde.keyboard /Layouts reloadConfig >/dev/null 2>&1 || true
  sudo -H -u "$LOGNAME" DBUS_SESSION_BUS_ADDRESS="$DBUS_ADDR" qdbus org.kde.keyboard /Layouts reloadConfig >/dev/null 2>&1 || true
  sudo -H -u "$LOGNAME" DBUS_SESSION_BUS_ADDRESS="$DBUS_ADDR" qdbus6 org.kde.kglobalaccel /kglobalaccel reloadConfig >/dev/null 2>&1 || true
  sudo -H -u "$LOGNAME" DBUS_SESSION_BUS_ADDRESS="$DBUS_ADDR" qdbus org.kde.kglobalaccel /kglobalaccel reloadConfig >/dev/null 2>&1 || true
fi

logSuccess "KDE, KWin, and Keyboard configurations successfully finalized!"
