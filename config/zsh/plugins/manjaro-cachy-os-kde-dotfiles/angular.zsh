# Lazy-load Angular CLI autocompletion
_ng_lazy_complete() {
  # If NVM lazy-loading is pending and real ng binary isn't on PATH yet, load NVM
  if (( $+functions[_omz_nvm_load] )) && ! whence -p ng >/dev/null; then
    _omz_nvm_load
  fi

  # If real ng binary is available on PATH, load official Angular completion and invoke it
  if whence -p ng >/dev/null; then
    compdef -d ng
    source <(ng completion script)
    if (( $+functions[$_comps[ng]] )); then
      "$_comps[ng]" "$@"
    fi
  fi
}

compdef _ng_lazy_complete ng
