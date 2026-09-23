#!/usr/bin/env bash

# Configure Keyboard Layouts ('us', 'no'), Per-Application SwitchMode, and Global Shortcuts
KXKB_CONFIG_FILE="$HOMEDIR/.config/kxkbrc"
SHORTCUTS_CONFIG_FILE="$HOMEDIR/.config/kglobalshortcutsrc"
KWIN_CONFIG_FILE="$HOMEDIR/.config/kwinrc"

logInfo "Configuring keyboard layouts ('us', 'no') with per-application switching..."
writeKdeConfig "$KXKB_CONFIG_FILE" "Layout" "LayoutList" "us,no"
writeKdeConfig "$KXKB_CONFIG_FILE" "Layout" "Use" "true"
writeKdeConfig "$KXKB_CONFIG_FILE" "Layout" "VariantList" ","
writeKdeConfig "$KXKB_CONFIG_FILE" "Layout" "SwitchMode" "WinClass"
writeKdeConfig "$KXKB_CONFIG_FILE" "Layout" "ShowOSD" "true"
writeKdeConfig "$KXKB_CONFIG_FILE" "Layout" "Options" ""

# Stop running kglobalaccel so in-memory state doesn't overwrite kglobalshortcutsrc on exit
USER_UID=$(id -u "$LOGNAME" 2>/dev/null || echo "1000")
if command -v systemctl &>/dev/null; then
  sudo -H -u "$LOGNAME" XDG_RUNTIME_DIR="/run/user/$USER_UID" systemctl --user stop plasma-kglobalaccel.service 2>/dev/null || true
fi
killall -9 kglobalacceld 2>/dev/null || true

logInfo "Setting Meta+Space shortcut for toggling native KDE keyboard layouts..."
writeKdeConfig "$SHORTCUTS_CONFIG_FILE" "KDE Keyboard Layout Switcher" "Switch to Next Keyboard Layout" "Meta+Space,none,Switch to Next Keyboard Layout"

# Prevent KRunner from intercepting Meta+Space in Plasma 6
writeKdeConfig "$SHORTCUTS_CONFIG_FILE" "org.kde.krunner.desktop" "_launch" "Alt+Space,Alt+F2,KRunner"

logInfo "Setting F12 shortcut for Yakuake drop-down toggle..."
writeKdeConfig "$SHORTCUTS_CONFIG_FILE" "yakuake" "toggle-window-state" "F12,F12,Open/Retract Yakuake"
writeKdeConfig "$SHORTCUTS_CONFIG_FILE" "org.kde.yakuake.desktop" "_launch" "F12,F12,Open/Retract Yakuake"
writeKdeConfig "$SHORTCUTS_CONFIG_FILE" "org.kde.yakuake.desktop" "toggle-window-state" "F12,F12,Open/Retract Yakuake"

logInfo "Setting Meta+S shortcut for Application Launcher and Meta for Overview..."
# Application Launcher -> Meta+S
writeKdeConfig "$SHORTCUTS_CONFIG_FILE" "org.kde.plasmashell" "activate application launcher" "Meta+S,none,Activate Application Launcher"

# Overview -> Meta
writeKdeConfig "$SHORTCUTS_CONFIG_FILE" "kwin" "Overview" "Meta,none,Toggle Overview"

# Bare Meta key modifier -> Overview in kwinrc
writeKdeConfig "$KWIN_CONFIG_FILE" "ModifierOnlyShortcuts" "Meta" "org.kde.kwin,/KWin,org.kde.KWin,toggleOverview"

# Clear conflicting shortcuts
writeKdeConfig "$SHORTCUTS_CONFIG_FILE" "kwin" "GridScene" "none,none,Toggle Grid"
writeKdeConfig "$SHORTCUTS_CONFIG_FILE" "kwin" "ShowDesktopGrid" "none,none,Show Desktop Grid"
