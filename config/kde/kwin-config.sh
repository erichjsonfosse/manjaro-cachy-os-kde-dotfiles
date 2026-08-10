#!/usr/bin/env bash

# Configure KWin Window Rules and Focus Stealing Prevention
logHeader "Configuring KWin Window Rules"
KWIN_RULES_FILE="$HOMEDIR/.config/kwinrulesrc"
KWIN_CONFIG_FILE="$HOMEDIR/.config/kwinrc"

mkdir -p "$(dirname "$KWIN_RULES_FILE")"

# 1. Configure Yakuake Keep Above and Focus Rules (KDE Plasma 6 & Plasma 5 compatible)
existing_rules=""
if command -v kreadconfig6 &>/dev/null; then
  existing_rules=$(sudo -H -u "$LOGNAME" kreadconfig6 --file "$KWIN_RULES_FILE" --group "General" --key "rules" 2>/dev/null || echo "")
elif command -v kreadconfig5 &>/dev/null; then
  existing_rules=$(sudo -H -u "$LOGNAME" kreadconfig5 --file "$KWIN_RULES_FILE" --group "General" --key "rules" 2>/dev/null || echo "")
fi

if [[ "$existing_rules" != *"yakuake"* ]]; then
  if [ -n "$existing_rules" ]; then
    new_rules="${existing_rules},yakuake-always-on-top"
  else
    new_rules="yakuake-always-on-top"
  fi
  writeKdeConfig "$KWIN_RULES_FILE" "General" "rules" "$new_rules"
fi

# Always update rule parameters (Plasma 6 & 5 format)
writeKdeConfig "$KWIN_RULES_FILE" "yakuake-always-on-top" "Description" "Yakuake always on top and focused"
writeKdeConfig "$KWIN_RULES_FILE" "yakuake-always-on-top" "above" "true"
writeKdeConfig "$KWIN_RULES_FILE" "yakuake-always-on-top" "aboveRule" "3"
writeKdeConfig "$KWIN_RULES_FILE" "yakuake-always-on-top" "focus" "true"
writeKdeConfig "$KWIN_RULES_FILE" "yakuake-always-on-top" "focusrule" "3"
writeKdeConfig "$KWIN_RULES_FILE" "yakuake-always-on-top" "focusstealing" "0"
writeKdeConfig "$KWIN_RULES_FILE" "yakuake-always-on-top" "focusstealingrule" "3"
writeKdeConfig "$KWIN_RULES_FILE" "yakuake-always-on-top" "types" "1"
writeKdeConfig "$KWIN_RULES_FILE" "yakuake-always-on-top" "wmclass" "yakuake"
writeKdeConfig "$KWIN_RULES_FILE" "yakuake-always-on-top" "wmclasscomplete" "false"
writeKdeConfig "$KWIN_RULES_FILE" "yakuake-always-on-top" "wmclassmatch" "2"

# Legacy Plasma 5 count format fallback
if ! grep -q "wmclass=yakuake" "$KWIN_RULES_FILE" 2>/dev/null; then
  count=$(grep -E "^count=" "$KWIN_RULES_FILE" 2>/dev/null | cut -d'=' -f2 || echo "0")
  count=${count:-0}
  new_count=$((count + 1))
  writeKdeConfig "$KWIN_RULES_FILE" "General" "count" "$new_count"

  writeKdeConfig "$KWIN_RULES_FILE" "Rule-$new_count" "Description" "Yakuake always on top and focused"
  writeKdeConfig "$KWIN_RULES_FILE" "Rule-$new_count" "above" "true"
  writeKdeConfig "$KWIN_RULES_FILE" "Rule-$new_count" "aboveRule" "3"
  writeKdeConfig "$KWIN_RULES_FILE" "Rule-$new_count" "focus" "true"
  writeKdeConfig "$KWIN_RULES_FILE" "Rule-$new_count" "focusrule" "3"
  writeKdeConfig "$KWIN_RULES_FILE" "Rule-$new_count" "focusstealing" "0"
  writeKdeConfig "$KWIN_RULES_FILE" "Rule-$new_count" "focusstealingrule" "3"
  writeKdeConfig "$KWIN_RULES_FILE" "Rule-$new_count" "types" "1"
  writeKdeConfig "$KWIN_RULES_FILE" "Rule-$new_count" "wmclass" "yakuake"
  writeKdeConfig "$KWIN_RULES_FILE" "Rule-$new_count" "wmclasscomplete" "false"
  writeKdeConfig "$KWIN_RULES_FILE" "Rule-$new_count" "wmclassmatch" "2"
fi

chown "$LOGNAME:$LOGNAME" "$KWIN_RULES_FILE" 2>/dev/null || true
logSuccess "KWin window rule for Yakuake successfully configured!"

# 2. Configure Focus Stealing Prevention to Extreme (4)
logInfo "Setting Focus Stealing Prevention to Extreme..."
writeKdeConfig "$KWIN_CONFIG_FILE" "Windows" "FocusStealingPreventionLevel" "4"
chown "$LOGNAME":"$LOGNAME" "$KWIN_CONFIG_FILE" 2>/dev/null || true
