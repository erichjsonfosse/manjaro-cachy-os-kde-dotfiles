# Refresh Herdr config if local overrides exist and base was updated
_refresh_herdr_config() {
  local herdr_user_dir="$HOME/.config/herdr"
  local base_config="${0:A:h}/../../../herdr/config.toml"
  local local_config="$herdr_user_dir/config.local.toml"
  local target_config="$herdr_user_dir/config.toml"

  if [ -f "$local_config" ] && [ -f "$base_config" ]; then
    if [ ! -f "$target_config" ] || [ "$local_config" -nt "$target_config" ] || [ "$base_config" -nt "$target_config" ]; then
      cat "$base_config" "$local_config" > "$target_config" 2>/dev/null || true
    fi
  fi
}

# Auto-start Herdr when running inside Yakuake
if command -v herdr &> /dev/null && [[ -z "$HERDR_ENV" && -o interactive ]]; then
  # Check if the shell's parent process is yakuake or if we are inside a yakuake DBus context
  if [[ "$(ps -p $PPID -o comm= 2>/dev/null)" == *"yakuake"* || -n "$YAKUAKE_DBUS_WINDOW" ]]; then
    _refresh_herdr_config
    # If starting in /, default to home folder so that Herdr sessions start in $HOME
    if [[ "$PWD" == "/" ]]; then
      cd "$HOME" || exit
    fi
    exec herdr
  fi
fi
