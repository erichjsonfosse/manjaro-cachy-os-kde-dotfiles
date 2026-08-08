#!/usr/bin/env bash

# Helper to write KDE config cleanly
writeKdeConfig() {
  local file="$1"
  local group="$2"
  local key="$3"
  local value="$4"

  if command -v kwriteconfig6 &> /dev/null; then
    su "$LOGNAME" -c "kwriteconfig6 --file \"$file\" --group \"$group\" --key \"$key\" \"$value\""
  elif command -v kwriteconfig5 &> /dev/null; then
    su "$LOGNAME" -c "kwriteconfig5 --file \"$file\" --group \"$group\" --key \"$key\" \"$value\""
  fi
}

logHeader "Configuring KWin Window Rules"
KWIN_RULES_FILE="$HOMEDIR/.config/kwinrulesrc"
KWIN_CONFIG_FILE="$HOMEDIR/.config/kwinrc"

# Ensure config directories exist
mkdir -p "$(dirname "$KWIN_RULES_FILE")"

# 1. Configure Yakuake Keep Above Rule
if [ -f "$KWIN_RULES_FILE" ] && grep -q "wmclass=yakuake" "$KWIN_RULES_FILE"; then
  logWarning "KWin window rule for Yakuake already exists. Skipping..."
else
  # Read existing rule count, default to 0 if not present
  count=0
  if [ -f "$KWIN_RULES_FILE" ]; then
    count=$(grep -E "^count=" "$KWIN_RULES_FILE" | cut -d'=' -f2)
    count=${count:-0}
  fi

  # Increment count for new rule
  new_count=$((count + 1))

  # If file doesn't exist or is empty, initialize it
  if [ ! -f "$KWIN_RULES_FILE" ] || [ ! -s "$KWIN_RULES_FILE" ]; then
    echo -e "[General]\ncount=1\n" > "$KWIN_RULES_FILE"
  else
    # Update the count in General section
    if grep -q "^count=" "$KWIN_RULES_FILE"; then
      sed -i "s/^count=.*/count=$new_count/" "$KWIN_RULES_FILE"
    else
      # If count line is missing but General section exists, insert it
      if grep -q "\[General\]" "$KWIN_RULES_FILE"; then
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

# 2. Configure Focus Stealing Prevention to Extreme (4)
logInfo "Setting Focus Stealing Prevention to Extreme..."
writeKdeConfig "$KWIN_CONFIG_FILE" "Windows" "FocusStealingPreventionLevel" "4"
chown "$LOGNAME":"$LOGNAME" "$KWIN_CONFIG_FILE" 2>/dev/null || true

# 3. Configure Fcitx 5 as the active Wayland Input Method (Virtual Keyboard)
# This enables global 'ctrl + shift + u' unicode entry support across applications
logInfo "Setting active Input Method to Fcitx 5 (enables Ctrl+Shift+U globally)..."
writeKdeConfig "$KWIN_CONFIG_FILE" "Wayland" "InputMethod" "/usr/share/applications/org.fcitx.Fcitx5.desktop"

# 4. Notify kwin to reload configurations if running
if pgrep -x kwin_wayland > /dev/null; then
  su "$LOGNAME" -c "qdbus org.kde.KWin /KWin reconfigure" || true
fi
