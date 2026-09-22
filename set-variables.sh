#!/usr/bin/env bash

######################### OS Information #########################
if [ -f /etc/os-release ]; then
  . /etc/os-release
  OS_ID=$ID
else
  OS_ID="unknown"
fi
export OS_ID
######################### OS Information #########################

######################### Directories ##########################
BASEDIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
export BASEDIR

CONFIGDIR="$BASEDIR/config"
export CONFIGDIR

ZSHPLUGINDIR="$CONFIGDIR/zsh/plugins"
export ZSHPLUGINDIR

INSTALLDIR="$BASEDIR/install"
export INSTALLDIR
######################### Directories ##########################

######################### Files ##########################
RESUME_FILE_NAME="RESUME.tmp"
export RESUME_FILE_NAME

TEMPORARY_CONFIG_FILE_NAME="$BASEDIR/TEMPORARY_CONFIG_FILE.tmp"
export TEMPORARY_CONFIG_FILE_NAME

if [ -f "$TEMPORARY_CONFIG_FILE_NAME" ]; then
  # shellcheck disable=SC1090
  source "$TEMPORARY_CONFIG_FILE_NAME"
elif [ -f "TEMPORARY_CONFIG_FILE.tmp" ]; then
  # shellcheck disable=SC1090
  source "TEMPORARY_CONFIG_FILE.tmp"
fi
export DOTFILES_GIT_NAME
export DOTFILES_GIT_EMAIL
export DOTFILES_GIT_SIGNING_KEY
######################### Files ##########################

######################### HOMEDIR ##########################
if [ -n "$SUDO_USER" ]; then
  LOGNAME="$SUDO_USER"
else
  LOGNAME=$(logname 2>/dev/null || echo "$USER")
fi
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
