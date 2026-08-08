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
[1]="checkPacmanLock"
[2]="requestInput"

# --- 2. Installation ---
[3]="installPacmanPackages"
[4]="installAurPackages"

# --- 3. Configuration ---
[5]="configureGit"
[6]="configureZsh"
[7]="configureDocker"
[8]="configurePyenv"
[9]="configureOnefetch"
[10]="configureNano"
[11]="configureSsh"
[12]="configureVivaldi"
[13]="configureKwin"

# --- 4. Post-Configuration ---
[14]="postInstallGitConfig"
[15]="postInstallZshConfig"

# --- 5. Permissions & Cleanup ---
[16]="ensureUserOwnershipOfHomeFolder"
[17]="bumpVersion"
[18]="removeTemporaryFiles"
[19]="promptForReboot"
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
    maxKey=$(getMaxKey "${steps[@]}")
    if [ "$step" -gt "$maxKey" ]; then
      break;
    fi

    runStep "$step";

    if [ -f "$RESUME_FILE_NAME" ]; then
      step=$(head -n 1 "$RESUME_FILE_NAME");
    else
      step=$((step + 1));
    fi
  done
}

runStep()
{
  case "${steps[$1]}" in
    "checkPacmanLock" | "requestInput" | "promptForReboot" | "installPacmanPackages" | "installAurPackages")
      echo -e "\nRunning step $1 (${steps[$1]})..."
      bash -c "set -eo pipefail; $(declare -f includeUtilities setVariables "${steps[$1]}"); includeUtilities; setVariables; ${steps[$1]}"
      ;;
    *)
      gum spin --show-output --spinner dot --title "Running step $1 (${steps[$1]})..." -- bash -c "set -eo pipefail; $(declare -f includeUtilities setVariables "${steps[$1]}"); includeUtilities; setVariables; ${steps[$1]}"
      ;;
  esac

  setStep $(($1 + 1))
}

setStep()
{
  local next_step=$1
  local maxKey=$(getMaxKey "${steps[@]}")

  if [ "$next_step" -ge "$maxKey" ]; then
    rm -f "$RESUME_FILE_NAME"
  else
    rm -f "$RESUME_FILE_NAME"
    touch "$RESUME_FILE_NAME"
    echo "$next_step" > "$RESUME_FILE_NAME"
  fi
}

chmodScripts()
{
  find . -type f -name "*.sh" -exec chmod +x {} +
}

checkPacmanLock()
{
  verifyPacmanLock
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

configureKwin()
{
  source "$CONFIGDIR/kde/kde-config.sh"
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
source ./utilities/pre-install/welcome-screen.sh
showWelcomeScreen
