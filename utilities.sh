#!/bin/bash

askForReboot()
{
  while true; do
    read -rp "Reboot (recommended)? (y/n)" yn
    case $yn in
      [Yy]* ) reboot; exit;;
      [Nn]* ) break;;
      * ) echo "Please answer yes or no.";;
    esac
  done
}

# Takes two arguments
# First is name of service to wait for
# Second is period to wait after attempting to wait for service (not all services properly report)
waitUntilServiceIsRunning()
{
  echo "Waiting for $1 to become active..."
  isActive=$(systemctl status "$1" | grep "Active: active (running)")

  while [ -z "$isActive" ] ; do
    echo "$isActive"
    isActive=$(systemctl status "$1" | grep "Active: active (running)")
  done

  if [ ! -z "$2" ]; then
    sleep $(($2))
  fi
}

function getMaxKey()
{
  local max=-1
  local array=("$@")
  for key in "${!array[@]}"; do
    if [ $((${key})) -gt $((${max})) ]; then
      max=${key}
    fi
  done

  echo "$max";
}

uncommentZshrcPath()
{
  if grep -exq "^export PATH=(.*)" "$ZSHRCFILE"
  then
    sed -i "s@^\(# export PATH=\)\(.*\)\(:\$PATH\)@export PATH=\2\3@g" "$ZSHRCFILE";
  else
    echo ".zshrc PATH already uncommented. skipping...";
  fi
}

addToZshrcPath()
{
  uncommentZshrcPath;
  sed -i "s@^\(export PATH=\)\(.*\)\(:\$PATH\)@\1\2:$1\3@g" "$ZSHRCFILE";
}
