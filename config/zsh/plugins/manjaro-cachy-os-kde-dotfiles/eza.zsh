if command -v eza &>/dev/null; then
  # Base listing with icons and grouped directories
  alias ls="eza --icons --group-directories-first"

  # Long listing with permissions, file sizes, and Git status indicators
  alias ll="eza --icons --group-directories-first -l --git"

  # Long listing including hidden files
  alias la="eza --icons --group-directories-first -la --git"

  # Tree views
  alias lt="eza --icons --group-directories-first --tree"
  alias lta="eza --icons --group-directories-first --tree -la"
fi
