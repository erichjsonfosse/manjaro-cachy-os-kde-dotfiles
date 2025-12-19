#!/usr/bin/env bash

{
  printf "\n\n"
  printf "##### starship init #####"
  printf "\n"
  printf "eval \"%s\"" "\$(starship init zsh)"
  printf "\n"
  printf "##### starship init #####"
  printf "\n"
} >> "$ZSHRC_FILE"
