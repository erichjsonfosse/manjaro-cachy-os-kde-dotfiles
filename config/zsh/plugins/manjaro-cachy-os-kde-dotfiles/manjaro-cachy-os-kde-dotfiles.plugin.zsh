0="${ZERO:-${${0:#$ZSH_ARGZERO}:-${(%):-%N}}}"
0="${${(M)0:#/*}:-$PWD/$0}"

source "${0:A:h}"/aliases.zsh
source "${0:A:h}"/direnv.zsh
source "${0:A:h}"/gh-cli.zsh
source "${0:A:h}"/git.zsh
source "${0:A:h}"/uuid.zsh
source "${0:A:h}"/zellij.zsh

