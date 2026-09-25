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

# Reload live KDE session components if running
reloadKdeSession all

logSuccess "KDE, KWin, and Keyboard configurations successfully finalized!"
