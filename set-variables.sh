#!/usr/bin/env bash

######################### Directories ##########################
BASEDIR=$(realpath "$0" | sed 's|\(.*\)/.*|\1|')
export BASEDIR

CONFIGDIR="$BASEDIR/config"
export CONFIGDIR

ZSHPLUGINDIR="$CONFIGDIR/zsh/zsh-plugin"
export ZSHPLUGINDIR

INSTALLDIR="$BASEDIR/install"
export INSTALLDIR
######################### Directories ##########################

######################### Files ##########################
RESUME_FILE_NAME="RESUME.tmp"
export RESUME_FILE_NAME

TEMPORARY_CONFIG_FILE_NAME="TEMPORARY_CONFIG_FILE.tmp";
export  TEMPORARY_CONFIG_FILE_NAME
######################### Files ##########################

######################### HOMEDIR ##########################
LOGNAME=$(logname)
export LOGNAME
HOMEDIR=$(eval echo ~"$LOGNAME")
export HOMEDIR
######################### HOMEDIR ##########################

APP_IMAGE_DIR="$HOMEDIR/Applications"
export APP_IMAGE_DIR

GIT_CONFIG_FILE="$HOMEDIR/.gitconfig"
export GIT_CONFIG_FILE

OHMYZSH_FOLDER="$HOMEDIR/.oh-my-zsh"
export OHMYZSH_FOLDER
ZSHRC_FILE="$HOMEDIR/.zshrc"
export ZSHRC_FILE
