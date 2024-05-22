#!/bin/bash

printf "\n\n" >> "$ZSHRCFILE"
printf "[ -z \"$NVM_DIR\" ] && export NVM_DIR=\"$HOME/.nvm\"" >> "$ZSHRCFILE"
printf "\n" >> "$ZSHRCFILE"
printf "source /usr/share/nvm/nvm.sh" >> "$ZSHRCFILE"
printf "\n" >> "$ZSHRCFILE"
printf "source /usr/share/nvm/bash_completion" >> "$ZSHRCFILE"
printf "\n" >> "$ZSHRCFILE"
printf "source /usr/share/nvm/install-nvm-exec" >> "$ZSHRCFILE"
printf "\n" >> "$ZSHRCFILE"
