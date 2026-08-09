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

# Notify kwin to reload configurations if running
if pgrep -x kwin_wayland > /dev/null; then
  sudo -H -u "$LOGNAME" qdbus org.kde.KWin /KWin reconfigure 2>/dev/null || true
fi

logSuccess "KDE, KWin, and Keyboard configurations successfully finalized!"
