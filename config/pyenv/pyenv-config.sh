#!/usr/bin/env bash

logHeader "Configuring Pyenv PATH Shims"

# Check if pyenv is installed on the system
if command -v pyenv &>/dev/null; then
  PYSHIMS=$(pyenv root)/shims
  addToZshrcPath "$PYSHIMS"
  logSuccess "Pyenv shims successfully registered in PATH!"
else
  logWarning "pyenv is not installed. Skipping Pyenv configuration..."
fi
