0="${ZERO:-${${0:#$ZSH_ARGZERO}:-${(%):-%N}}}"
0="${${(M)0:#/*}:-$PWD/$0}"

# Establish NVM_DIR if not set
if [ -z "$NVM_DIR" ]; then
  export NVM_DIR="$HOME/.nvm"
fi

# High-Performance Lazy Loader for NVM and Node/NPM
_load_nvm() {
  # Unbind lazy functions to run only once
  unset -f nvm node npm npx pnpm yarn
  
  # Source NVM configurations
  if [ -s "$NVM_DIR/nvm.sh" ]; then
    \. "$NVM_DIR/nvm.sh"
  fi
  if [ -s "$NVM_DIR/bash_completion" ]; then
    \. "$NVM_DIR/bash_completion"
  fi
}

# Bind lazy triggers
nvm() { _load_nvm; nvm "$@"; }
node() { _load_nvm; node "$@"; }
npm() { _load_nvm; npm "$@"; }
npx() { _load_nvm; npx "$@"; }
pnpm() { _load_nvm; pnpm "$@"; }
yarn() { _load_nvm; yarn "$@"; }

# Source helper hooks
source "${0:A:h}"/angular-autocompletion.zsh
