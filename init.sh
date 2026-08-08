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
[0]="chmodScripts|Making installer and config scripts executable"
[1]="checkPacmanLock|Verifying pacman database lock safety"
[2]="requestInput|Collecting custom Git credentials"

# --- 2. Installation ---
[3]="installPacmanPackages|Upgrading system and installing pacman packages"
[4]="installAurPackages|Compiling and installing AUR packages (via paru)"

# --- 3. Configuration ---
[5]="configureGit|Linking global and local Git configurations"
[6]="configureZsh|Configuring Zsh shell, plugins, and custom local overrides"
[7]="configureDocker|Configuring Docker socket permissions and user groups"
[8]="configurePyenv|Registering Python pyenv shims"
[9]="configureOnefetch|Setting up native Onefetch Zsh repository greeters"
[10]="configureNano|Setting up Nano editor options & 2-space tab layouts"
[11]="configureParu|Syncing optimized paru AUR-helper configurations"
[12]="configureSsh|Enabling and linking systemd ssh-agent"
[13]="configureVivaldi|Setting default browser and applying sanitized Vivaldi preferences"
[14]="configureKwin|Configuring KWin rules and Fcitx5 input methods"

# --- 4. Post-Configuration ---
[15]="postInstallGitConfig|Applying final Git signing key templates"
[16]="postInstallZshConfig|Compiling Oh My Zsh theme assets"

# --- 5. Permissions & Cleanup ---
[17]="ensureUserOwnershipOfHomeFolder|Verifying user file ownership and permissions"
[18]="bumpVersion|Tagging dotfiles installation version"
[19]="removeTemporaryFiles|Cleaning up installer temporary files"
[20]="promptForReboot|Requesting system restart to apply all changes"
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
  local entry="${steps[$1]}"
  local func="${entry%%|*}"
  local desc="${entry#*|}"

  local styled_step=$(gum style --foreground 99 --bold "➜ Step $1: $func")
  local styled_desc=$(gum style --foreground 245 --italic " — $desc")

  echo ""
  echo "${styled_step}${styled_desc}"

  case "$func" in
    "checkPacmanLock" | "requestInput" | "promptForReboot" | "installPacmanPackages" | "installAurPackages")
      bash -c "set -eo pipefail; $(declare -f includeUtilities setVariables \"$func\"); includeUtilities; setVariables; $func"
      ;;
    *)
      gum spin --show-output --spinner dot --title "Executing task..." -- bash -c "set -eo pipefail; $(declare -f includeUtilities setVariables \"$func\"); includeUtilities; setVariables; $func"
      ;;
  esac

  gum style --foreground 82 "✔ Finished: $desc"

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

configureParu()
{
  source "$CONFIGDIR/paru/paru-config.sh"
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
  logHeader "Ensuring correct user file ownership"
  logInfo "Applying permissions to dotfiles and user configurations..."

  # Target only directories and files we actually touch to be fast and safe
  local targets=(
    "$HOMEDIR/.config"
    "$HOMEDIR/.oh-my-zsh"
    "$HOMEDIR/.zshrc"
    "$HOMEDIR/.zshrc.local"
    "$HOMEDIR/.nanorc"
    "$HOMEDIR/.ssh"
    "$HOMEDIR/.gitconfig"
    "$HOMEDIR/.gitconfig.local"
  )

  for target in "${targets[@]}"; do
    if [ -e "$target" ]; then
      chown -R "$LOGNAME:$LOGNAME" "$target"
    fi
  done

  logSuccess "User file ownership successfully verified!"
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
