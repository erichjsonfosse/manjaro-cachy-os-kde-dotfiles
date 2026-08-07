# Auto-start Zellij when running inside Yakuake
if command -v zellij &> /dev/null && [[ -z "$ZELLIJ" && -o interactive ]]; then
  # Check if the shell's parent process is yakuake or if we are inside a yakuake DBus context
  if [[ "$(ps -p $PPID -o comm= 2>/dev/null)" == *"yakuake"* || -n "$YAKUAKE_DBUS_WINDOW" ]]; then
    # Start zellij and attach to an existing session named 'yakuake' or create it
    exec zellij attach -c yakuake
  fi
fi
