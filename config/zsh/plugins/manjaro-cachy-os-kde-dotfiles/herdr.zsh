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
#if command -v herdr &> /dev/null && [[ -z "$HERDR_ENV" && -o interactive ]]; then
#  # Check if the shell's parent process is yakuake or if we are inside a yakuake DBus context
#  if [[ "$(ps -p $PPID -o comm= 2>/dev/null)" == *"yakuake"* || -n "$YAKUAKE_DBUS_WINDOW" ]]; then
#    _refresh_herdr_config
#    # If starting in /, default to home folder so that Herdr sessions start in $HOME
#    if [[ "$PWD" == "/" ]]; then
#      cd "$HOME" || exit
#    fi
#    exec herdr
#  fi
#fi

# Auto-start Herdr when running inside Yakuake
#if command -v herdr &> /dev/null && [[ -z "$HERDR_ENV" && -o interactive ]]; then
#  if [[ "$(ps -p $PPID -o comm= 2>/dev/null)" == *"yakuake"* || -n "$YAKUAKE_DBUS_WINDOW" ]]; then
#    _refresh_herdr_config
#    if [[ "$PWD" == "/" ]]; then
#      cd "$HOME" || exit
#    fi
#
#    # Defer exec to the first precmd hook so PTY initialization completes first
#    _autostart_herdr() {
#      add-zsh-hook -d precmd _autostart_herdr
#      exec herdr
#    }
#    autoload -Uz add-zsh-hook
#    add-zsh-hook precmd _autostart_herdr
#  fi
#fi


#if command -v herdr &> /dev/null && [[ -z "$HERDR_ENV" && -o interactive ]]; then
#  if [[ "$(ps -p $PPID -o comm= 2>/dev/null)" == *"yakuake"* || -n "$YAKUAKE_DBUS_WINDOW" ]]; then
#    _prompt_herdr_widget() {
#      zle -D zle-line-init
#      zle -I
#
#      # Wait for Yakuake to finish its drop-down window resize animation
#      local initial_cols current_cols count=0
#      initial_cols=$(stty size < /dev/tty 2>/dev/null | cut -d' ' -f2)
#      while (( count < 15 )); do
#        current_cols=$(stty size < /dev/tty 2>/dev/null | cut -d' ' -f2)
#        if [[ -n "$current_cols" ]]; then
#          if (( current_cols > 100 || current_cols != initial_cols )); then
#            break
#          fi
#        fi
#        sleep 0.05
#        (( count++ ))
#      done
#
#      local response
#      if read -r "response?Start Herdr? [Y/n] " < /dev/tty; then
#        if [[ -z "$response" || "$response" =~ ^[yY] ]]; then
#          _refresh_herdr_config
#          if [[ "$PWD" == "/" ]]; then
#            cd "$HOME" || exit
#          fi
#          exec herdr
#        fi
#      fi
#
#      zle reset-prompt
#    }
#
#    _setup_herdr_prompt() {
#      add-zsh-hook -d precmd _setup_herdr_prompt
#      zle -N zle-line-init _prompt_herdr_widget
#    }
#    autoload -Uz add-zsh-hook
#    add-zsh-hook precmd _setup_herdr_prompt
#  fi
#fi

