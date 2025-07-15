#!/usr/bin/env bash

if [ "$EUID" -ne 0 ]
  then
    echo "Script must be run as root"
    exit
fi

steps=(
[0]="chmodScripts"
[1]="requestInput"
[2]="configureZsh"
[3]="configureGit"
[4]="installPacmanPackages"
[5]="configureNvm"
[6]="configurePyenv"
[7]="enableSnapService"
[8]="installSnapPackages"
[9]="installAurPackages"
[10]="installAppImages"
[11]="configureDocker"
[12]="configureOnefetch"
[13]="configureSsh"
[14]="bumpVersion"
[15]="postInstall"
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
  
  if [ -f "tmpConfigFile.tmp" ]; then
    source ./tmpConfigFile.tmp
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
  echo "Running step $1 (${steps[$1]})";
  setStep $(($1 + 1))
  eval "${steps[$1]}"
}

setStep()
{
  rm -f "$RESUME_FILE_NAME";
  touch "$RESUME_FILE_NAME";
  echo $1 > "$RESUME_FILE_NAME";
}

chmodScripts()
{
  chmod +x ./**/*.sh
}

requestInput()
{
  source ./request-input.sh
}

configureZsh()
{
  source "$CONFIGDIR/zsh/zsh-config.sh"
}

configureGit()
{
  source "$CONFIGDIR/git/git-config.sh"
}

installPacmanPackages()
{
  source "$INSTALLDIR/pacman-packages.sh"
}

configureNvm()
{
  source "$CONFIGDIR/nvm/nvm-config.sh"
}

configurePyenv()
{
  source "$CONFIGDIR/pyenv/pyenv-config.sh"
}

enableSnapService()
{
  source "$INSTALLDIR/enable-snap-service.sh"
}

installSnapPackages()
{
  source "$INSTALLDIR/snap-packages.sh"
}

installAurPackages()
{
  source "$INSTALLDIR/aur-packages.sh"
}

installAppImages()
{
  source "$INSTALLDIR/app-images.sh"
}

configureDocker()
{
  source "$CONFIGDIR/docker/docker-config.sh"
}

configureOnefetch()
{
  source "$CONFIGDIR/onefetch/onefetch-config.sh"
}

configureSsh()
{
  source "$CONFIGDIR/ssh/ssh-config.sh"
}

bumpVersion()
{
  source ./bump-version.sh
}

postInstall()
{
  # Order matters
  source "$CONFIGDIR/ssh/ssh-post-install.sh"
  source "$CONFIGDIR/git/git-post-install.sh"
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

while true; do
 read -rp "Continue with installation? (y/n)" yn
 case $yn in
   [Yy]* ) doRun; break;;
   [Nn]* ) exit;;
   * ) echo "Please answer yes or no.";;
 esac
done
