#!/bin/bash

if [ "$EUID" -ne 0 ]
  then
    echo "Script must be run as root"
    exit
fi

resumeFilename="RESUME.tmp"
configFolder="./config"
installFolder="./install"

steps=(
[0]="chmodScripts"
[1]="setVariables"
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
[69]="doot"
)

doRun()
{
  if [ ! -f "$resumeFilename" ]; then
    setStep 0;
  fi
  
  if [ -f "tmpConfigFile.tmp" ]; then
    source ./tmpConfigFile.tmp
  fi
  
  step=$(head -n 1 $resumeFilename);

  runStep "$step"
}

runStep()
{
  setStep $(($1 + 1))
  eval "${steps[$1]}"
}

doot()
{
  echo "bloop"
}

setStep()
{
  rm -f $resumeFilename;
  echo $1 > $resumeFilename;
}

chmodScripts()
{
  chmod +x ./**/*.sh
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
  source "$installFolder/pacman-packages.sh"
}

enableSnapService()
{
  source "$installFolder/enable-snap-service.sh"
}

installSnapPackages()
{
  source "$installFolder/snap-packages.sh"
}

installAurPackages()
{
  source "$installFolder/aur-packages.sh"
}

installAppImages()
{
  source "$installFolder/app-images.sh"
}

installNvm()
{
  source "$installFolder/nvm.sh"
}

configureUfw()
{
  source "$configFolder/ufw-config.sh"
}

configureZsh()
{
  source "$configFolder/zsh-config.sh"
}

configureGit()
{
  source "$configFolder/git-config.sh"
}

configureSsh()
{
  source "$configFolder/ssh-config.sh"
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

runStep 69

#while true; do
#  read -rp "Continue with installation? (y/n)" yn
#  case $yn in
#    [Yy]* ) doRun; break;;
#    [Nn]* ) exit;;
#    * ) echo "Please answer yes or no.";;
#  esac
#done
