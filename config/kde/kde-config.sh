#!/usr/bin/env bash

# Helper to write KDE config cleanly
writeKdeConfig() {
  local file="$1"
  local group="$2"
  local key="$3"
  local value="$4"

  if command -v kwriteconfig6 &> /dev/null; then
    sudo -H -u "$LOGNAME" kwriteconfig6 --file "$file" --group "$group" --key "$key" "$value" 2>/dev/null || true
  elif command -v kwriteconfig5 &> /dev/null; then
    sudo -H -u "$LOGNAME" kwriteconfig5 --file "$file" --group "$group" --key "$key" "$value" 2>/dev/null || true
  elif command -v kwriteconfig &> /dev/null; then
    sudo -H -u "$LOGNAME" kwriteconfig --file "$file" --group "$group" --key "$key" "$value" 2>/dev/null || true
  else
    logWarning "KDE config utility (kwriteconfig) not found. Skipping config update for: $key"
  fi
  return 0
}

logHeader "Configuring KWin Window Rules"
KWIN_RULES_FILE="$HOMEDIR/.config/kwinrulesrc"
KWIN_CONFIG_FILE="$HOMEDIR/.config/kwinrc"

# Ensure config directories exist
mkdir -p "$(dirname "$KWIN_RULES_FILE")"

# 1. Configure Yakuake Keep Above Rule (KDE Plasma 6 & Plasma 5 compatible)
existing_rules=""
if command -v kreadconfig6 &>/dev/null; then
  existing_rules=$(sudo -H -u "$LOGNAME" kreadconfig6 --file "$KWIN_RULES_FILE" --group "General" --key "rules" 2>/dev/null || echo "")
elif command -v kreadconfig5 &>/dev/null; then
  existing_rules=$(sudo -H -u "$LOGNAME" kreadconfig5 --file "$KWIN_RULES_FILE" --group "General" --key "rules" 2>/dev/null || echo "")
fi

if [[ "$existing_rules" == *"yakuake"* ]] || ([ -f "$KWIN_RULES_FILE" ] && grep -q "wmclass=org.kde.yakuake" "$KWIN_RULES_FILE" 2>/dev/null); then
  logWarning "KWin window rule for Yakuake already exists. Skipping..."
else
  # KDE Plasma 6 rules list format
  if [ -n "$existing_rules" ]; then
    new_rules="${existing_rules},yakuake-always-on-top"
  else
    new_rules="yakuake-always-on-top"
  fi

  writeKdeConfig "$KWIN_RULES_FILE" "General" "rules" "$new_rules"
  writeKdeConfig "$KWIN_RULES_FILE" "yakuake-always-on-top" "Description" "Yakuake always on top"
  writeKdeConfig "$KWIN_RULES_FILE" "yakuake-always-on-top" "above" "true"
  writeKdeConfig "$KWIN_RULES_FILE" "yakuake-always-on-top" "aboveRule" "2"
  writeKdeConfig "$KWIN_RULES_FILE" "yakuake-always-on-top" "wmclass" "org.kde.yakuake"
  writeKdeConfig "$KWIN_RULES_FILE" "yakuake-always-on-top" "wmclassmatch" "1"

  # Legacy Plasma 5 count format fallback
  count=$(grep -E "^count=" "$KWIN_RULES_FILE" 2>/dev/null | cut -d'=' -f2 || echo "0")
  count=${count:-0}
  new_count=$((count + 1))
  writeKdeConfig "$KWIN_RULES_FILE" "General" "count" "$new_count"

  writeKdeConfig "$KWIN_RULES_FILE" "Rule-$new_count" "Description" "Yakuake always on top"
  writeKdeConfig "$KWIN_RULES_FILE" "Rule-$new_count" "above" "true"
  writeKdeConfig "$KWIN_RULES_FILE" "Rule-$new_count" "aboveRule" "2"
  writeKdeConfig "$KWIN_RULES_FILE" "Rule-$new_count" "wmclass" "org.kde.yakuake"
  writeKdeConfig "$KWIN_RULES_FILE" "Rule-$new_count" "wmclassmatch" "1"

  chown "$LOGNAME:$LOGNAME" "$KWIN_RULES_FILE" 2>/dev/null || true
  logSuccess "KWin window rule for Yakuake successfully added!"
fi

# Dismiss Yakuake First Run / Welcome Dialog
YAKUAKE_CONFIG_FILE="$HOMEDIR/.config/yakuakerc"
logInfo "Configuring Yakuake..."
writeKdeConfig "$YAKUAKE_CONFIG_FILE" "Behavior" "RememberFullscreen" "true"
writeKdeConfig "$YAKUAKE_CONFIG_FILE" "Dialogs" "FirstRun" "false"
writeKdeConfig "$YAKUAKE_CONFIG_FILE" "Window" "Height" "60"
writeKdeConfig "$YAKUAKE_CONFIG_FILE" "Window" "Width" "100"
# Enable Yakuake autostart on login
AUTOSTART_DIR="$HOMEDIR/.config/autostart"
YAKUAKE_AUTOSTART_FILE="$AUTOSTART_DIR/org.kde.yakuake.desktop"
logInfo "Configuring Yakuake to start automatically on login..."
mkdir -p "$AUTOSTART_DIR"

if [ -f "/usr/share/applications/org.kde.yakuake.desktop" ]; then
  cp "/usr/share/applications/org.kde.yakuake.desktop" "$YAKUAKE_AUTOSTART_FILE"
else
  cat << 'EOF' > "$YAKUAKE_AUTOSTART_FILE"
[Desktop Entry]
Categories=Qt;KDE;System;TerminalEmulator;
Comment=A drop-down terminal emulator based on KDE Konsole technology.
DBusActivatable=true
Exec=yakuake
GenericName=Drop-down Terminal
Icon=yakuake
Name=Yakuake
StartupNotify=false
Terminal=false
Type=Application
EOF
fi

chown -R "$LOGNAME:$LOGNAME" "$AUTOSTART_DIR" 2>/dev/null || true

# 2. Configure Focus Stealing Prevention to Extreme (4)
logInfo "Setting Focus Stealing Prevention to Extreme..."
writeKdeConfig "$KWIN_CONFIG_FILE" "Windows" "FocusStealingPreventionLevel" "4"
chown "$LOGNAME":"$LOGNAME" "$KWIN_CONFIG_FILE" 2>/dev/null || true

# 3. Configure Fcitx 5 as the active Wayland Input Method (Virtual Keyboard)
logInfo "Setting active Input Method to Fcitx 5..."
writeKdeConfig "$KWIN_CONFIG_FILE" "Wayland" "InputMethod" "/usr/share/applications/org.fcitx.Fcitx5.desktop"

# 4. Configure Keyboard Layouts ('us', 'no'), Per-Application SwitchMode, and Meta+Space Shortcut
logInfo "Configuring keyboard layouts ('us', 'no') with per-application switching..."
KXKB_CONFIG_FILE="$HOMEDIR/.config/kxkbrc"
SHORTCUTS_CONFIG_FILE="$HOMEDIR/.config/kglobalshortcutsrc"

writeKdeConfig "$KXKB_CONFIG_FILE" "Layout" "LayoutList" "us,no"
writeKdeConfig "$KXKB_CONFIG_FILE" "Layout" "Use" "true"
writeKdeConfig "$KXKB_CONFIG_FILE" "Layout" "VariantList" ","
writeKdeConfig "$KXKB_CONFIG_FILE" "Layout" "SwitchMode" "application"
writeKdeConfig "$KXKB_CONFIG_FILE" "Layout" "ShowOSD" "true"

logInfo "Setting Meta+Space shortcut for toggling keyboard layouts..."
writeKdeConfig "$SHORTCUTS_CONFIG_FILE" "kwin" "Switch to Next Keyboard Layout" "Meta+Space,Meta+Space,Switch to Next Keyboard Layout"

# 5. Configure Fcitx 5 layout profile & shortcut alignment if present
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

  writeKdeConfig "$FCITX5_CONFIG_FILE" "Hotkey/TriggerKeys" "0" "Super+space"
  chown -R "$LOGNAME:$LOGNAME" "$FCITX5_PROFILE_DIR" 2>/dev/null || true
fi

# 6. Notify kwin to reload configurations if running
if pgrep -x kwin_wayland > /dev/null; then
  sudo -H -u "$LOGNAME" qdbus org.kde.KWin /KWin reconfigure 2>/dev/null || true
fi

logSuccess "KWin and Keyboard configurations successfully finalized!"
