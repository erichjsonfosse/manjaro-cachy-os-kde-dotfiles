if command -v bat &>/dev/null; then
  # Alias cat to bat (without paging by default, matching standard cat behavior)
  alias cat="bat --paging=never"

  # Syntax-highlighted manual pages using bat
  export MANPAGER="sh -c 'col -bx | bat -l man -p'"
fi
