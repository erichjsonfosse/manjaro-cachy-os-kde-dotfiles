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

# 1. Configure Yakuake Keep Above Rule
if [ -f "$KWIN_RULES_FILE" ] && grep -q "wmclass=yakuake" "$KWIN_RULES_FILE" 2>/dev/null; then
  logWarning "KWin window rule for Yakuake already exists. Skipping..."
else
  # Read existing rule count, default to 0 if not present
  count=0
  if [ -f "$KWIN_RULES_FILE" ]; then
    count=$(grep -E "^count=" "$KWIN_RULES_FILE" 2>/dev/null | cut -d'=' -f2 || echo "0")
    count=${count:-0}
  fi

  # Increment count for new rule
  new_count=$((count + 1))

  # If file doesn't exist or is empty, initialize it
  if [ ! -f "$KWIN_RULES_FILE" ] || [ ! -s "$KWIN_RULES_FILE" ]; then
    echo -e "[General]\ncount=1\n" > "$KWIN_RULES_FILE"
  else
    # Update the count in General section
    if grep -q "^count=" "$KWIN_RULES_FILE" 2>/dev/null; then
      sed -i "s/^count=.*/count=$new_count/" "$KWIN_RULES_FILE"
    else
      # If count line is missing but General section exists, insert it
      if grep -q "\[General\]" "$KWIN_RULES_FILE" 2>/dev/null; then
        sed -i "/\[General\]/a count=$new_count" "$KWIN_RULES_FILE"
      else
        # If General section doesn't exist at all
        sed -i "1i [General]\ncount=$new_count\n" "$KWIN_RULES_FILE"
      fi
    fi
  fi

  # Append the new Yakuake keep-above rule at the end of the file
  {
    echo ""
    echo "[Rule-$new_count]"
    echo "Description=Yakuake always on top"
    echo "above=true"
    echo "aboveRule=2"
    echo "wmclass=org.kde.yakuake"
    echo "wmclassmatch=1"
  } >> "$KWIN_RULES_FILE"

  # Fix ownership
  chown "$LOGNAME":"$LOGNAME" "$KWIN_RULES_FILE"

  logSuccess "KWin window rule for Yakuake successfully added!"
fi

# Dismiss Yakuake First Run / Welcome Dialog
YAKUAKE_CONFIG_FILE="$HOMEDIR/.config/yakuakerc"
logInfo "Configuring Yakuake..."
writeKdeConfig "$YAKUAKE_CONFIG_FILE" "Behavior" "RememberFullscreen" "true"
writeKdeConfig "$YAKUAKE_CONFIG_FILE" "Dialogs" "FirstRun" "false"
writeKdeConfig "$YAKUAKE_CONFIG_FILE" "Window" "Height" "60"
writeKdeConfig "$YAKUAKE_CONFIG_FILE" "Window" "Width" "100"
chown "$LOGNAME:$LOGNAME" "$YAKUAKE_CONFIG_FILE" 2>/dev/null || true

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
