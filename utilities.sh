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
