# Lazy-load Angular CLI autocompletion
_ng_lazy_complete() {
  # If NVM lazy-loading is pending and ng isn't found yet, trigger NVM loader
  if ! command -v ng &>/dev/null && (( $+functions[_omz_nvm_load] )); then
    _omz_nvm_load
  fi

  # If ng command is available, load official Angular completion and invoke it
  if command -v ng &>/dev/null; then
    compdef -d ng
    source <(ng completion script)
    _ng "$@"
  fi
}

compdef _ng_lazy_complete ng
