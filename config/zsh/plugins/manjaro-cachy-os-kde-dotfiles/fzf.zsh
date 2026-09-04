if command -v fzf &>/dev/null; then
  # Load official Arch / Manjaro keybindings and completion
  [ -f /usr/share/fzf/key-bindings.zsh ] && source /usr/share/fzf/key-bindings.zsh
  [ -f /usr/share/fzf/completion.zsh ] && source /usr/share/fzf/completion.zsh

  # Clean interactive layout defaults
  export FZF_DEFAULT_OPTS="--height 40% --layout=reverse --border --inline-info"

  # Rich file preview via bat when pressing Ctrl+T
  if command -v bat &>/dev/null; then
    export FZF_CTRL_T_OPTS="--preview 'bat --style=numbers --color=always --line-range :300 {} 2>/dev/null || cat {}'"
  fi

  # Directory tree preview via eza when pressing Alt+C
  if command -v eza &>/dev/null; then
    export FZF_ALT_C_OPTS="--preview 'eza --tree --level=2 --icons --color=always {} 2>/dev/null'"
  fi
fi
