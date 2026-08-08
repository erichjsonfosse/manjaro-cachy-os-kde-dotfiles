#!/usr/bin/env bash

logHeader "Configuring Pyenv PATH Shims"

# Check if pyenv is installed on the system
if su "$LOGNAME" -c "command -v pyenv &>/dev/null"; then
  PYSHIMS=$(su "$LOGNAME" -c "pyenv root")/shims
  addToZshrcPath "$PYSHIMS"
  logSuccess "Pyenv shims successfully registered in PATH!"
else
  logWarning "pyenv is not installed. Skipping Pyenv configuration..."
fi
