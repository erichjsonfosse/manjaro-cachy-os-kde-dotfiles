#!/bin/bash

if [ "$EUID" -ne 0 ]
  then
    echo "Script must be run as root"
    exit
fi

steps=(
[1]="chmodScripts"
[2]="requestInput"
[3]="configureZsh"
[4]="configureGit"
[5]="installPacmanPackages"
[6]="enableSnapService"
[7]="installSnapPackages"
[8]="installAurPackages"
[9]="installAppImages"
[10]="installNvm"
[11]="configureUfw"
[12]="ensureUserOwnershipOfHomeFolder"
[13]="bumpVersion"
[14]="removeTemporaryFiles"
)

doRun()
{
  includeUtilities;
  setVariables;

  if [ ! -f "$RESUME_FILE_NAME" ]; then
    step=1;
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
    echo "Step: "$(("$step"))
    echo "MaxKey: "$(("$maxKey"))
    
    if [ $(("$step")) -le $(("$maxKey")) ]; then
      break;
    fi
    
    step=$(head -n 1 "$RESUME_FILE_NAME");
  done
}

runStep()
{
  echo "Running step $1";
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

includeUtilities()
{
  source ./utilities.sh
}

setVariables()
{
  source ./set-variables.sh
}

requestInput()
{
  source ./request-input.sh
}

installPacmanPackages()
{
  source "$INSTALLDIR/pacman-packages.sh"
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

installNvm()
{
  source "$INSTALLDIR/nvm.sh"
}

configureUfw()
{
  source "$CONFIGDIR/ufw-config.sh"
}

configureZsh()
{
  source "$CONFIGDIR/zsh-config.sh"
}

configureGit()
{
  source "$CONFIGDIR/git-config.sh"
}

configureSsh()
{
  source "$CONFIGDIR/ssh-config.sh"
}

bumpVersion()
{
  source ./bump-version.sh
}

ensureUserOwnershipOfHomeFolder()
{
  # Change ownership of home folder files recursively
  echo "Changing ownership of home folder..."
  chown -R "$LOGNAME:$LOGNAME" "$HOMEDIR"
}

removeTemporaryFiles()
{
  rm -f "RESUME.tmp";
  rm -f "tmpConfigFile.tmp";
}

while true; do
 read -rp "Continue with installation? (y/n)" yn
 case $yn in
   [Yy]* ) doRun; break;;
   [Nn]* ) exit;;
   * ) echo "Please answer yes or no.";;
 esac
done
