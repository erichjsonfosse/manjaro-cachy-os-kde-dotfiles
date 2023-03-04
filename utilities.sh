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
  
  while -z "$isActive" ; do
    isActive=$(systemctl status "$1" | grep "Active: active (running)")
  done
}

getMaxKey()
{
  max=-1
  array=$1
  for key in "${!array[@]}"; do
    ((${key} > max)) && max=$((${key}))
  done
  echo "Max key in $1 is $max"
  
  return $max;
}
