#!/bin/bash

printf "\n\n" >> "$ZSHRCFILE"
printf "export NVM_DIR=\"\$([ -z \"\${XDG_CONFIG_HOME-}\" ] && printf %%s \"\${HOME}/.nvm\" || printf %%s \"\${XDG_CONFIG_HOME}/nvm\")\"" >> "$ZSHRCFILE"
printf "\n" >> "$ZSHRCFILE"
printf "[ -s \"\$NVM_DIR/nvm.sh\" ] && \. \"\$NVM_DIR/nvm.sh\" # This loads nvm" >> "$ZSHRCFILE"
