#!/usr/bin/env bash

PYSHIMS=$(su "$LOGNAME" -c "pyenv root")/shims
addToZshrcPath "$PYSHIMS"
