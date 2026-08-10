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
writeKdeConfig "$KXKB_CONFIG_FILE" "Layout" "Options" "grp:win_space_toggle"
writeKdeConfig "$KXKB_CONFIG_FILE" "Layout" "ResetOldOptions" "true"

logInfo "Setting Meta+Space XKB layout shortcut and clearing KWin shortcut collision..."
for group in "kwin" "org.kde.kwin"; do
  writeKdeConfig "$SHORTCUTS_CONFIG_FILE" "$group" "Switch to Next Keyboard Layout" "none,Meta+Alt+K,Switch to Next Keyboard Layout"
  writeKdeConfig "$SHORTCUTS_CONFIG_FILE" "$group" "Switch Keyboard Layout" "none,none,Switch Keyboard Layout"
done

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
