#!/usr/bin/env bash

# Configure Keyboard Layouts ('us', 'no'), Per-Application SwitchMode, and Global Shortcuts
KXKB_CONFIG_FILE="$HOMEDIR/.config/kxkbrc"
SHORTCUTS_CONFIG_FILE="$HOMEDIR/.config/kglobalshortcutsrc"
KWIN_CONFIG_FILE="$HOMEDIR/.config/kwinrc"

logInfo "Configuring keyboard layouts ('us', 'no') with per-application switching..."
writeKdeConfig "$KXKB_CONFIG_FILE" "Layout" "LayoutList" "us,no"
writeKdeConfig "$KXKB_CONFIG_FILE" "Layout" "Use" "true"
writeKdeConfig "$KXKB_CONFIG_FILE" "Layout" "VariantList" ","
writeKdeConfig "$KXKB_CONFIG_FILE" "Layout" "SwitchMode" "application"
writeKdeConfig "$KXKB_CONFIG_FILE" "Layout" "ShowOSD" "true"
writeKdeConfig "$KXKB_CONFIG_FILE" "Layout" "Options" "grp:win_space_toggle"
writeKdeConfig "$KXKB_CONFIG_FILE" "Layout" "ResetOldOptions" "true"

# Apply live XKB keymap options if setxkbmap is available
if command -v setxkbmap &>/dev/null; then
  sudo -H -u "$LOGNAME" DISPLAY="${DISPLAY:-:0}" setxkbmap -layout us,no -option grp:win_space_toggle 2>/dev/null || true
fi

logInfo "Setting Meta+Space shortcut for toggling keyboard layouts..."
writeKdeConfig "$SHORTCUTS_CONFIG_FILE" "kwin" "Switch to Next Keyboard Layout" "Meta+Space,Meta+Alt+K,Switch to Next Keyboard Layout"
writeKdeConfig "$SHORTCUTS_CONFIG_FILE" "kwin" "Switch Keyboard Layout" "Meta+Space,none,Switch Keyboard Layout"

# Prevent KRunner from intercepting Meta+Space
writeKdeConfig "$SHORTCUTS_CONFIG_FILE" "org.kde.krunner.desktop" "_launch" "Alt+Space,Alt+F2,KRunner"

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
