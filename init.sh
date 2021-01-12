#!/bin/bash

if [ "$EUID" -ne 0 ]
  then
    echo "Script must be run as root"
    exit
fi

doRun()
{
  filename="RESUME.tmp"
  if [ -f "$filename" ]; then
    step=$(head -n 1 $filename);
  else
    step=0;
  fi
  
  chmodScripts;
  
  if [ $step lt 2 ]; then
    setVariables;
  fi
  
  if [ $step lt 3 ]; then
    requestInput;
  fi
  
  if [ $step lt 4 ]; then
    installPackmanPackages;
  fi
  
  if [ $step lt 5 ]; then
    enableSnapService;
  fi
  
  if [ $step lt 6 ]; then
    installSnapPackages;
  fi
  
  if [ $step lt 7 ]; then
    installAurPackages;
  fi
  
  if [ $step lt 8 ]; then
    installAppImages;
  fi
  
  if [ $step lt 9 ]; then
    configureUfw;
  fi
  
  if [ $step lt 10 ]; then
    configureZsh;
  fi
  
  if [ $step lt 11 ]; then
    configureGit;
  fi
  
  if [ $step lt 12 ]; then
    configureSsh;
  fi
  
  if [ $step lt 13 ]; then
    bumpVersion;
  fi
  
  if [ $step lt 14 ]; then
    configureSsh;
  fi
}

setStep()
{
  filename="RESUME.tmp";
  rm $filename;
  echo $1 > $filename;
}

chmodScripts()
{
  setStep 1;
  chmod +x ./*.sh
  chmod +x ./install/*.sh
  chmod +x ./config/*.sh
}

setVariables()
{
  setStep 2;
  source ./set-variables.sh
}

requestInput()
{
  setStep 3;
  source ./request-input.sh
}

installPackmanPackages()
{
  setStep 4;
  source ./install/pacman-packages.sh
}

enableSnapService()
{
  setStep 5;
  source ./install/enable-snap-service.sh
}

installSnapPackages()
{
  setStep 6;
  source ./install/snap-packages.sh
}

installAurPackages()
{
  setStep 7;
#  source ./install/aur-packages.sh
}

installAppImages()
{
  setStep 8;
  source ./install/app-images.sh
}

configureUfw()
{
  setStep 9;
  source ./config/ufw-config.sh
}

configureZsh()
{
  setStep 10;
  source ./config/zsh-config.sh
}

configureGit()
{
  setStep 11;
  source ./config/git-config.sh
}

configureSsh()
{
  setStep 12;
  source ./config/ssh-config.sh
}

bumpVersion()
{
  setStep 13;
  source ./bump-version.sh
}

configureSsh()
{
  setStep 14;
  # Change ownership of home folder files recursively
  echo "Changing ownership of home folder..."
  chown -R "$LOGNAME:$LOGNAME" "$HOMEDIR"
}

while true; do
  read -rp "Continue with installation? (y/n)" yn
  case $yn in
    [Yy]* ) doRun; break;;
    [Nn]* ) exit;;
    * ) echo "Please answer yes or no.";;
  esac
done
