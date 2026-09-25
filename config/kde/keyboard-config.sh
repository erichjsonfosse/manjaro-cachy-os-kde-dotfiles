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

# Reconfigure KWin if running so layout switcher action collection is initialized with the new layout list
if pgrep -x kwin_wayland &>/dev/null || pgrep -x kwin_x11 &>/dev/null; then
  qdbus6 org.kde.KWin /KWin reconfigure &>/dev/null || true
fi

logInfo "Setting Meta+Space shortcut for toggling native KDE keyboard layouts..."
setKdeShortcut "KDE Keyboard Layout Switcher" "Switch to Next Keyboard Layout" "Meta+Space" "Meta+Alt+K" "Switch to Next Keyboard Layout"

# Prevent KRunner from intercepting Meta+Space in Plasma 6
setKdeShortcut "org.kde.krunner.desktop" "_launch" "Alt+Space" "Alt+F2" "KRunner"

logInfo "Setting F12 shortcut for Yakuake drop-down toggle..."
setKdeShortcut "yakuake" "toggle-window-state" "F12" "F12" "Open/Retract Yakuake"
setKdeShortcut "org.kde.yakuake.desktop" "_launch" "F12" "F12" "Open/Retract Yakuake"
setKdeShortcut "org.kde.yakuake.desktop" "toggle-window-state" "F12" "F12" "Open/Retract Yakuake"

logInfo "Setting Meta+S shortcut for Application Launcher and Meta for Overview..."
# Application Launcher -> Meta+S
setKdeShortcut "org.kde.plasmashell" "activate application launcher" "Meta+S" "none" "Activate Application Launcher"

# Overview -> Meta
setKdeShortcut "kwin" "Overview" "Meta" "none" "Toggle Overview"

# Bare Meta key modifier -> Overview in kwinrc
writeKdeConfig "$KWIN_CONFIG_FILE" "ModifierOnlyShortcuts" "Meta" "org.kde.kwin,/KWin,org.kde.KWin,toggleOverview"

# Clear conflicting shortcuts
setKdeShortcut "kwin" "GridScene" "none" "none" "Toggle Grid"
setKdeShortcut "kwin" "ShowDesktopGrid" "none" "none" "Show Desktop Grid"
