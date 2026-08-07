#!/usr/bin/env bash

echo "Configuring KWin Window Rules..."
KWIN_RULES_FILE="$HOMEDIR/.config/kwinrulesrc"

# Ensure the config directory exists
mkdir -p "$(dirname "$KWIN_RULES_FILE")"

# Check if a rule for Yakuake already exists
if [ -f "$KWIN_RULES_FILE" ] && grep -q "wmclass=yakuake" "$KWIN_RULES_FILE"; then
  echo "KWin window rule for Yakuake already exists. Skipping..."
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

  echo "KWin window rule for Yakuake successfully added!"

  # Notify kwin to reload configurations if running
  if pgrep -x kwin_wayland > /dev/null; then
    su "$LOGNAME" -c "qdbus org.kde.KWin /KWin reconfigure" || true
  fi
fi
