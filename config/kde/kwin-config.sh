#!/usr/bin/env bash

# Configure KWin Window Rules and Focus Stealing Prevention
logHeader "Configuring KWin Window Rules"
KWIN_RULES_FILE="$HOMEDIR/.config/kwinrulesrc"
KWIN_CONFIG_FILE="$HOMEDIR/.config/kwinrc"

mkdir -p "$(dirname "$KWIN_RULES_FILE")"

# 1. Configure Yakuake Keep Above and Focus Rules (KDE Plasma 6)
existing_rules=""
if command -v kreadconfig6 &>/dev/null; then
  existing_rules=$(sudo -H -u "$LOGNAME" kreadconfig6 --file "$KWIN_RULES_FILE" --group "General" --key "rules" 2>/dev/null || echo "")
fi

if [[ "$existing_rules" != *"yakuake-always-on-top"* ]]; then
  if [ -n "$existing_rules" ]; then
    new_rules="${existing_rules},yakuake-always-on-top"
  else
    new_rules="yakuake-always-on-top"
  fi
  writeKdeConfig "$KWIN_RULES_FILE" "General" "rules" "$new_rules"
fi

sec="yakuake-always-on-top"
writeKdeConfig "$KWIN_RULES_FILE" "$sec" "Description" "Yakuake always on top and focused"
writeKdeConfig "$KWIN_RULES_FILE" "$sec" "above" "true"
writeKdeConfig "$KWIN_RULES_FILE" "$sec" "aboverule" "3"
writeKdeConfig "$KWIN_RULES_FILE" "$sec" "focus" "true"
writeKdeConfig "$KWIN_RULES_FILE" "$sec" "focusrule" "3"
writeKdeConfig "$KWIN_RULES_FILE" "$sec" "focusstealing" "0"
writeKdeConfig "$KWIN_RULES_FILE" "$sec" "focusstealingrule" "3"
writeKdeConfig "$KWIN_RULES_FILE" "$sec" "desktopfile" "org.kde.yakuake"
writeKdeConfig "$KWIN_RULES_FILE" "$sec" "desktopfilematch" "1"
writeKdeConfig "$KWIN_RULES_FILE" "$sec" "wmclass" "yakuake"
writeKdeConfig "$KWIN_RULES_FILE" "$sec" "wmclasscomplete" "false"
writeKdeConfig "$KWIN_RULES_FILE" "$sec" "wmclassmatch" "2"

chown "$LOGNAME:$LOGNAME" "$KWIN_RULES_FILE" 2>/dev/null || true
logSuccess "KWin window rule for Yakuake successfully configured!"

# 2. Configure Focus Stealing Prevention to Medium (2)
logInfo "Setting Focus Stealing Prevention to Medium (2)..."
writeKdeConfig "$KWIN_CONFIG_FILE" "Windows" "FocusStealingPreventionLevel" "2"
chown "$LOGNAME":"$LOGNAME" "$KWIN_CONFIG_FILE" 2>/dev/null || true
