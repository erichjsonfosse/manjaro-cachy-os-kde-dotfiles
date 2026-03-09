0="${ZERO:-${${0:#$ZSH_ARGZERO}:-${(%):-%N}}}"
0="${${(M)0:#/*}:-$PWD/$0}"

##### nvm init #####
[ -z "%s" ] && export NVM_DIR="%s/.nvm" "$NVM_DIR" "$HOMEDIR"
[[ -r "$NVM_DIR/bash_completion" ]] && \. "$NVM_DIR/bash_completion"
[[ -r "$NVM_DIR/nvm.sh" ]] && \. "$NVM_DIR/nvm.sh"
##### nvm init #####

source "${0:A:h}"/angular-autocompletion.zsh
