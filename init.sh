#!/usr/bin/env bash

set -eo pipefail

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
[0]="chmodScripts"
[1]="requestInput"
[2]="configureGit"
[3]="installPacmanPackages"
[4]="installAurPackages"
[5]="configureDocker"
[6]="configureZsh"
[7]="configurePyenv"
[8]="configureOnefetch"
[9]="configureNano"
[10]="configureSsh"
[11]="bumpVersion"
[12]="postInstallSshConfig"
[13]="postInstallGitConfig"
[14]="postInstallZshConfig"
[15]="configureVivaldi"
[16]="ensureUserOwnershipOfHomeFolder"
[17]="removeTemporaryFiles"
)

includeUtilities()
{
  source ./utilities.sh
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

    if [ $(("$step")) -ge $(("$maxKey")) ]; then
      break;
    fi

    step=$(head -n 1 "$RESUME_FILE_NAME");
  done
}

runStep()
{
  setStep $(($1 + 1))
  gum spin --spinner dot --title "Running step $1 (${steps[$1]})..." -- bash -c "$(declare -f includeUtilities setVariables ${steps[$1]}); includeUtilities; setVariables; ${steps[$1]}"
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

postInstallSshConfig()
{
  source "$CONFIGDIR/ssh/ssh-post-install.sh"
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

setVariables

VERSION_FILE="$HOMEDIR/.config/manjaro-dotfiles/version"
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
