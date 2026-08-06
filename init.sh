#!/usr/bin/env bash

set -eo pipefail

trap "echo -e '\nInstallation aborted by user.'; exit 1" SIGINT

if [ "$EUID" -ne 0 ]
  then
    echo "Script must be run as root"
    exit
fi

if ! command -v gum &> /dev/null; then
    echo "gum could not be found, installing it..."
    pacman -S --needed --noconfirm gum
fi

steps=(
# --- 1. Setup ---
[0]="chmodScripts"
[1]="requestInput"

# --- 2. Installation ---
[2]="installPacmanPackages"
[3]="installAurPackages"

# --- 3. Configuration ---
[4]="configureGit"
[5]="configureZsh"
[6]="configureDocker"
[7]="configurePyenv"
[8]="configureOnefetch"
[9]="configureNano"
[10]="configureSsh"
[11]="configureVivaldi"

# --- 4. Post-Configuration ---
[12]="postInstallGitConfig"
[13]="postInstallZshConfig"

# --- 5. Permissions & Cleanup ---
[14]="ensureUserOwnershipOfHomeFolder"
[15]="bumpVersion"
[16]="removeTemporaryFiles"
[17]="promptForReboot"
)

includeUtilities()
{
  source ./utilities/during-install/utilities.sh
}

setVariables()
{
  source ./set-variables.sh
}

doRun()
{
  includeUtilities;
  setVariables;

  if [ ! -f "$RESUME_FILE_NAME" ]; then
    step=0;
    setStep "$step";
  else
    step=$(head -n 1 "$RESUME_FILE_NAME");
  fi

  if [ -f "$TEMPORARY_CONFIG_FILE_NAME" ]; then
    source "$TEMPORARY_CONFIG_FILE_NAME"
  fi

  while true; do
    runStep "$step";

    maxKey=$(getMaxKey "${steps[@]}")

    if [ $(("$step")) -gt $(("$maxKey")) ]; then
      break;
    fi

    step=$(head -n 1 "$RESUME_FILE_NAME");
  done
}

runStep()
{
  setStep $(($1 + 1))
  
  case "${steps[$1]}" in
    "requestInput" | "promptForReboot" | "installPacmanPackages" | "installAurPackages")
      echo -e "\nRunning step $1 (${steps[$1]})..."
      bash -c "set -eo pipefail; $(declare -f includeUtilities setVariables "${steps[$1]}"); includeUtilities; setVariables; ${steps[$1]}"
      ;;
    *)
      gum spin --show-output --spinner dot --title "Running step $1 (${steps[$1]})..." -- bash -c "set -eo pipefail; $(declare -f includeUtilities setVariables "${steps[$1]}"); includeUtilities; setVariables; ${steps[$1]}"
      ;;
  esac
}

setStep()
{
  rm -f "$RESUME_FILE_NAME";
  touch "$RESUME_FILE_NAME";
  echo "$1" > "$RESUME_FILE_NAME";
}

chmodScripts()
{
  find . -type f -name "*.sh" -exec chmod +x {} +
}

requestInput()
{
  source ./request-input.sh
}

configureGit()
{
  source "$CONFIGDIR/git/git-config.sh"
}

installPacmanPackages()
{
  source "$INSTALLDIR/pacman-packages.sh"
}

installAurPackages()
{
  source "$INSTALLDIR/aur-packages.sh"
}

configureDocker()
{
  source "$CONFIGDIR/docker/docker-config.sh"
}

configureZsh()
{
  source "$CONFIGDIR/zsh/zsh-config.sh"
}

configurePyenv()
{
  source "$CONFIGDIR/pyenv/pyenv-config.sh"
}

configureOnefetch()
{
  source "$CONFIGDIR/onefetch/onefetch-config.sh"
}

configureNano()
{
  source "$CONFIGDIR/nano/nano-config.sh"
}

configureSsh()
{
  source "$CONFIGDIR/ssh/ssh-config.sh"
}

bumpVersion()
{
  source ./bump-version.sh
}

postInstallGitConfig()
{
  source "$CONFIGDIR/git/git-post-install.sh"
}

postInstallZshConfig()
{
  source "$CONFIGDIR/zsh/zsh-post-install.sh"
}

configureVivaldi()
{
  source "$CONFIGDIR/vivaldi/vivaldi-config.sh"
}

ensureUserOwnershipOfHomeFolder()
{
  # Change ownership of home folder files recursively
  echo "Changing ownership of home folder..."
  chown -R "$LOGNAME:$LOGNAME" "$HOMEDIR"
}

removeTemporaryFiles()
{
  rm -f "$RESUME_FILE_NAME";
  rm -f "$TEMPORARY_CONFIG_FILE_NAME";
}

promptForReboot()
{
  askForReboot
}

setVariables

VERSION_FILE="$HOMEDIR/.config/manjaro-cachy-os-kde-dotfiles/version"
CURRENT_VERSION=""
if [ -f "$VERSION_FILE" ]; then
  CURRENT_VERSION=$(cat "$VERSION_FILE")
fi

LATEST_VERSION=$(git rev-parse HEAD 2>/dev/null || echo "unknown")

if [ -n "$CURRENT_VERSION" ] && [ "$CURRENT_VERSION" == "$LATEST_VERSION" ]; then
  if gum confirm "You are already on the latest version of the dotfiles. Continue with installation anyway?"; then
    doRun
  else
    exit
  fi
else
  if gum confirm "Continue with installation?"; then
    doRun
  else
    exit
  fi
fi
