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
