#!/bin/bash

######################### Directories ##########################
BASEDIR=$(realpath "$0" | sed 's|\(.*\)/.*|\1|')
echo "BASEDIR set to $BASEDIR"
export BASEDIR

CONFIGDIR="$BASEDIR/config"
export CONFIGDIR

ZSHPLUGINDIR="$CONFIGDIR/zsh-plugin"
export ZSHPLUGINDIR

INSTALLDIR="$BASEDIR/install"
export INSTALLDIR
######################### Directories ##########################

######################### Files ##########################
RESUME_FILE_NAME="RESUME.tmp"
export RESUME_FILE_NAME
######################### Files ##########################

######################### HOMEDIR ##########################
LOGNAME=$(logname)
export LOGNAME
HOMEDIR=$(eval echo ~"$LOGNAME")
export HOMEDIR
######################### HOMEDIR ##########################

APP_IMAGE_DIR="$HOMEDIR/Applications"
export APP_IMAGE_DIR

GITCONFIGFILE="$HOMEDIR/.gitconfig"
export GITCONFIGFILE

OHMYZSHFOLDER="$HOMEDIR/.oh-my-zsh"
export OHMYZSHFOLDER
ZSHRCFILE="$HOMEDIR/.zshrc"
export ZSHRCFILE
