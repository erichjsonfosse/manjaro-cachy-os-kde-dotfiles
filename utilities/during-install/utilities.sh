#!/usr/bin/env bash

askForReboot()
{
  if gum confirm "Reboot (recommended)?"; then
    reboot
    exit
  fi
}

# Takes two arguments
# First is name of service to wait for
# Second is period to wait after attempting to wait for service (not all services properly report)
startServiceAndWaitUntilItIsRunning()
{
  systemctl enable --now "$1"

  while ! systemctl is-active --quiet "$1"; do
    echo "Waiting for $1 to become active"
    sleep 3
  done

  if [ -n "$2" ]; then
    sleep $(("$2"))
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
  if grep -Eqs "^export PATH=(.*)" "$ZSHRC_FILE"
  then
    echo ".zshrc PATH already uncommented. skipping...";
  else
    sed -i '/^\# export PATH=\(.*\)/{p;s//export PATH=\1/;}' "$ZSHRC_FILE"
  fi
}

addToZshrcPath()
{
  uncommentZshrcPath;
  if grep -Fqs "$1" "$ZSHRC_FILE"
  then
    echo ".zshrc PATH already contains '$1'. skipping...";
  else
    sed -i "s@^\(export PATH=\)\(.*\)\(:\$PATH\)@\1\2:$1\3@g" "$ZSHRC_FILE";
  fi
}

getlatesttag()
{
  git -c 'versionsort.suffix=-' \
    ls-remote --exit-code --refs --sort='version:refname' --tags "$1" '*.*.*' |
    tail --lines=1 |
    cut --delimiter='/' --fields=3
}

verifyPacmanLock()
{
  if [ -f "/var/lib/pacman/db.lck" ]; then
    echo "⚠️  Pacman database lock file exists at /var/lib/pacman/db.lck"
    
    local lock_pid
    lock_pid=$(cat /var/lib/pacman/db.lck 2>/dev/null || true)
    
    if [ -n "$lock_pid" ] && ps -p "$lock_pid" &>/dev/null; then
      local proc_name
      proc_name=$(ps -p "$lock_pid" -o comm= 2>/dev/null || echo "unknown")
      echo "It is currently locked by an active process: $proc_name (PID: $lock_pid)."
      echo "Please wait for that process to finish, or terminate it before continuing."
      exit 1
    else
      echo "The lock file appears to be stale (no active process with PID $lock_pid was found)."
      if gum confirm "Would you like the installer to remove the stale lock file and continue?"; then
        rm -f /var/lib/pacman/db.lck
        echo "Stale lock file removed. Continuing..."
      else
        echo "Installation aborted. Please resolve the lock file manually."
        exit 1
      fi
    fi
  fi
}

waitForPacmanLock()
{
  local lock_file="/var/lib/pacman/db.lck"
  if [ -f "$lock_file" ]; then
    local lock_pid
    lock_pid=$(cat "$lock_file" 2>/dev/null || true)
    
    if [ -n "$lock_pid" ] && ps -p "$lock_pid" &>/dev/null; then
      local proc_name
      proc_name=$(ps -p "$lock_pid" -o comm= 2>/dev/null || echo "unknown")
      logWarning "Pacman database is currently locked by active process: $proc_name (PID: $lock_pid)."
      
      # Wait with a gorgeous Gum spinner
      gum spin --spinner dot --title "Waiting for background process '$proc_name' to release database lock..." -- bash -c "
        while [ -f '$lock_file' ] && ps -p '$lock_pid' &>/dev/null; do
          sleep 1
        done
      "
      logSuccess "Pacman lock released! Continuing..."
    else
      logWarning "Stale pacman lock file found (/var/lib/pacman/db.lck). Automatically removing..."
      rm -f "$lock_file"
    fi
  fi
}


logInfo()
{
  if command -v gum &>/dev/null; then
    gum style --foreground 99 "➜ $1"
  else
    echo "➜ $1"
  fi
}

logSuccess()
{
  if command -v gum &>/dev/null; then
    gum style --foreground 82 "✔ $1"
  else
    echo "✔ $1"
  fi
}

logWarning()
{
  if command -v gum &>/dev/null; then
    gum style --foreground 214 "⚠ $1"
  else
    echo "⚠ $1"
  fi
}

logError()
{
  if command -v gum &>/dev/null; then
    gum style --foreground 196 "✖ $1"
  else
    echo "✖ $1"
  fi
}

logHeader()
{
  echo ""
  if command -v gum &>/dev/null; then
    gum style --foreground 99 --bold "━━━ $1 ━━━"
  else
    echo "━━━ $1 ━━━"
  fi
}
