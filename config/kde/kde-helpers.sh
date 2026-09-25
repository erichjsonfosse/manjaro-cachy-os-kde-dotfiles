#!/usr/bin/env bash

# Helper to write KDE Plasma 6 config cleanly via kwriteconfig6
# Usage (positional): writeKdeConfig <file> <group> <key> <value> [type]
# Usage (flags):      writeKdeConfig -f <file> -g <group> -k <key> -v <value> [-t <type>] [--no-notify]
writeKdeConfig() {
  local file="" group="" key="" value="" type="" notify=true
  local value_set=false

  # Support positional arguments: writeKdeConfig file group key value [type]
  if [[ $# -ge 4 && "$1" != -* ]]; then
    file="$1"; group="$2"; key="$3"; value="$4"; value_set=true
    [[ -n "$5" ]] && type="$5"
  else
    # Parse flags
    while [[ $# -gt 0 ]]; do
      case "$1" in
        -f|--file)      file="$2"; shift 2 ;;
        -g|--group)     group="$2"; shift 2 ;;
        -k|--key)       key="$2"; shift 2 ;;
        -v|--value)     value="$2"; value_set=true; shift 2 ;;
        -t|--type)      type="$2"; shift 2 ;;
        --no-notify)    notify=false; shift ;;
        *)
          if declare -f logError &>/dev/null; then
            logError "Unknown option: $1"
          else
            echo "Error: Unknown option: $1" >&2
          fi
          return 1
          ;;
      esac
    done
  fi

  # Validation (value can be an empty string, but must be explicitly provided)
  if [[ -z "$file" || -z "$group" || -z "$key" || "$value_set" != true ]]; then
    if declare -f logError &>/dev/null; then
      logError "writeKdeConfig requires file, group, key, and value."
    else
      echo "Error: writeKdeConfig requires file, group, key, and value." >&2
    fi
    return 1
  fi

  # Ensure kwriteconfig6 exists
  if ! command -v kwriteconfig6 &>/dev/null; then
    if declare -f logWarning &>/dev/null; then
      logWarning "kwriteconfig6 not found. Skipping config update for: $key"
    else
      echo "Warning: kwriteconfig6 not found. Skipping config update for: $key" >&2
    fi
    return 1
  fi

  # Build command
  local cmd=(kwriteconfig6 --file "$file" --group "$group" --key "$key")
  $notify && cmd+=(--notify)
  [[ -n "$type" ]] && cmd+=(--type "$type")
  cmd+=("$value")

  # Execute config write
  "${cmd[@]}" 2>/dev/null || return 1

  return 0
}

# Alias for alternative naming
kwrite_config() {
  writeKdeConfig "$@"
}

# Helper to set a KDE global shortcut both in config and in-memory via D-Bus (Plasma 6)
# Usage: setKdeShortcut <component> <action> <shortcut> [default] [description]
setKdeShortcut() {
  local component="$1"
  local action="$2"
  local shortcut="$3"
  local default="${4:-$shortcut}"
  local description="${5:-$action}"
  local config_file="${SHORTCUTS_CONFIG_FILE:-${HOMEDIR:-$HOME}/.config/kglobalshortcutsrc}"

  if [[ -z "$component" || -z "$action" || -z "$shortcut" ]]; then
    if declare -f logError &>/dev/null; then
      logError "setKdeShortcut requires component, action, and shortcut."
    else
      echo "Error: setKdeShortcut requires component, action, and shortcut." >&2
    fi
    return 1
  fi

  # 1. Persist to ~/.config/kglobalshortcutsrc
  writeKdeConfig "$config_file" "$component" "$action" "$shortcut,$default,$description"

  # 2. If KDE Plasma session (KWin) is running, notify KGlobalAccel immediately via D-Bus
  # This updates KWin's in-memory shortcut map immediately and prevents KWin from overwriting
  # our changes with stale in-memory state on shutdown/reboot.
  if pgrep -x kwin_wayland &>/dev/null || pgrep -x kwin_x11 &>/dev/null; then
    if [[ -z "$DBUS_SESSION_BUS_ADDRESS" && -S "/run/user/$UID/bus" ]]; then
      export DBUS_SESSION_BUS_ADDRESS="unix:path=/run/user/$UID/bus"
    fi

    if command -v busctl &>/dev/null && command -v python3 &>/dev/null; then
      local keycode
      keycode=$(python3 -c '
import sys
s = sys.argv[1].strip()
if not s or s.lower() == "none":
    sys.exit(0)
mods = 0
key = 0
special_keys = {
    "space": 0x20, "escape": 0x01000000, "tab": 0x01000001,
    "backtab": 0x01000002, "backspace": 0x01000003, "return": 0x01000004,
    "enter": 0x01000004, "insert": 0x01000006, "delete": 0x01000007,
    "home": 0x01000010, "end": 0x01000011, "left": 0x01000012,
    "up": 0x01000013, "right": 0x01000014, "down": 0x01000015,
    "pageup": 0x01000016, "pagedown": 0x01000017
}
for p in s.split("+"):
    p_lower = p.lower()
    if p_lower == "meta":
        mods |= 0x10000000
    elif p_lower in ("ctrl", "control"):
        mods |= 0x04000000
    elif p_lower == "alt":
        mods |= 0x08000000
    elif p_lower == "shift":
        mods |= 0x02000000
    elif p_lower in special_keys:
        key = special_keys[p_lower]
    elif p_lower.startswith("f") and p_lower[1:].isdigit():
        n = int(p_lower[1:])
        if 1 <= n <= 35:
            key = 0x01000030 + (n - 1)
    elif len(p) == 1:
        key = ord(p.upper())
print(mods | key)
' "$shortcut" 2>/dev/null || echo "")

      if [[ -z "$keycode" || "$keycode" -eq 0 ]]; then
        busctl --user call org.kde.kglobalaccel /kglobalaccel org.kde.KGlobalAccel setForeignShortcut asai 4 "$component" "$action" "$component" "$description" 0 &>/dev/null || true
      else
        busctl --user call org.kde.kglobalaccel /kglobalaccel org.kde.KGlobalAccel setForeignShortcut asai 4 "$component" "$action" "$component" "$description" 1 "$keycode" &>/dev/null || true
      fi
    fi
  fi

  return 0
}

# Reload live KDE Plasma 6 session components
# Usage: reloadKdeSession [all|kwin|shortcuts|yakuake]
reloadKdeSession() {
  local target="${1:-all}"

  # If not in an active graphical session (e.g. running from TTY, chroot, or initial install), exit early
  if ! pgrep -x kwin_wayland &>/dev/null && ! pgrep -x kwin_x11 &>/dev/null; then
    return 0
  fi

  case "$target" in
    kwin)
      qdbus6 org.kde.KWin /KWin reconfigure &>/dev/null || true
      ;;
    shortcuts)
      if command -v systemctl &>/dev/null; then
        systemctl --user restart plasma-kglobalaccel.service &>/dev/null || true
      fi
      ;;
    yakuake)
      if command -v yakuake &>/dev/null; then
        pkill -x yakuake 2>/dev/null || true
        sleep 0.3
        yakuake &>/dev/null &
        disown
      fi
      ;;
    all)
      # Reload KWin (window rules, input behavior, modifier shortcuts, layouts)
      qdbus6 org.kde.KWin /KWin reconfigure &>/dev/null || true

      # Reload kglobalaccel so modified shortcuts are active immediately
      if command -v systemctl &>/dev/null; then
        systemctl --user restart plasma-kglobalaccel.service &>/dev/null || true
      fi

      # Relaunch Yakuake with updated configuration if installed
      if command -v yakuake &>/dev/null; then
        pkill -x yakuake 2>/dev/null || true
        sleep 0.3
        yakuake &>/dev/null &
        disown
      fi
      ;;
    *)
      if declare -f logWarning &>/dev/null; then
        logWarning "Unknown reload target: $target (expected: all, kwin, shortcuts, yakuake)"
      else
        echo "Warning: Unknown reload target: $target" >&2
      fi
      return 1
      ;;
  esac

  return 0
}
