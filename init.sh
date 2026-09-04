#!/usr/bin/env bash
# shellcheck disable=SC1090,SC1091,SC2317,SC2329

set -eo pipefail

trap "echo -e '\nInstallation aborted by user.'; exit 1" SIGINT

if [ "$EUID" -ne 0 ]
  then
    echo "Script must be run as root"
    exit
fi

if ! command -v gum &> /dev/null; then
    echo "gum could not be found, updating package database and installing it..."
    pacman -Sy --needed --noconfirm gum
fi

steps=(
# --- 1. Setup ---
[0]="backupExistingConfigs|Backing up existing configurations"
[1]="chmodScripts|Making installer and config scripts executable"
[2]="checkPacmanLock|Verifying pacman database lock safety"
[3]="requestInput|Collecting custom Git credentials"

# --- 2. Installation ---
[4]="installPacmanPackages|Upgrading system and installing pacman packages"
[5]="installAurPackages|Compiling and installing AUR packages (via paru)"

# --- 3. Configuration ---
[6]="configureGit|Linking global and local Git configurations"
[7]="configureZsh|Configuring Zsh shell, plugins, and custom local overrides"
[8]="configureDocker|Configuring Docker socket permissions and user groups"
[9]="configurePyenv|Registering Python pyenv shims"
[10]="configureOnefetch|Setting up native Onefetch Zsh repository greeters"
[11]="configureNano|Setting up Nano editor options & 2-space tab layouts"
[12]="configureParu|Syncing optimized paru AUR-helper configurations"
[13]="configureSsh|Enabling and linking systemd ssh-agent"
[14]="configureVivaldi|Setting default browser and applying sanitized Vivaldi preferences"
[15]="configureKwin|Configuring KWin rules and native keyboard layouts"

# --- 4. Post-Configuration ---
[16]="postInstallGitConfig|Applying final Git signing key templates"
[17]="postInstallZshConfig|Compiling Oh My Zsh theme assets"

# --- 5. Permissions & Cleanup ---
[18]="ensureUserOwnershipOfHomeFolder|Verifying user file ownership and permissions"
[19]="bumpVersion|Tagging dotfiles installation version"
[20]="removeTemporaryFiles|Cleaning up installer temporary files"
[21]="promptForReboot|Requesting system restart to apply all changes"
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

  # Establish a safe, temporary passwordless sudoers rule for the target user during installation.
  # This completely eliminates tty-association issues and credential timeouts on strict OSes.
  cleanup_installer() {
    rm -f /etc/sudoers.d/99-dotfiles-installer
  }
  trap cleanup_installer EXIT

  if [ -n "$LOGNAME" ] && [ "$LOGNAME" != "root" ]; then
    echo "$LOGNAME ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/99-dotfiles-installer
    chmod 440 /etc/sudoers.d/99-dotfiles-installer
  fi

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

  local styled_step
  styled_step=$(gum style --foreground 99 --bold "➜ Step $1: $func")
  local styled_desc
  styled_desc=$(gum style --foreground 245 --italic " — $desc")

  echo ""
  echo "${styled_step}${styled_desc}"

  case "$func" in
    "checkPacmanLock" | "requestInput" | "promptForReboot" | "installPacmanPackages" | "installAurPackages")
      bash -c "set -eo pipefail; $(declare -f includeUtilities setVariables "$func"); includeUtilities; setVariables; $func"
      ;;
    *)
      gum spin --show-output --spinner dot --title "Executing task..." -- bash -c "set -eo pipefail; $(declare -f includeUtilities setVariables "$func"); includeUtilities; setVariables; $func"
      ;;
  esac

  gum style --foreground 82 "✔ Finished: $desc"

  setStep $(($1 + 1))
}

setStep()
{
  local next_step=$1
  local maxKey
  maxKey=$(getMaxKey "${steps[@]}")

  if [ "$next_step" -ge "$maxKey" ]; then
    rm -f "$RESUME_FILE_NAME"
  else
    rm -f "$RESUME_FILE_NAME"
    touch "$RESUME_FILE_NAME"
    echo "$next_step" > "$RESUME_FILE_NAME"
  fi
}

backupExistingConfigs()
{
  source "$BASEDIR/utilities/pre-install/backup-configs.sh"
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
    "$HOMEDIR/.p10k.zsh"
    "$HOMEDIR/.nanorc"
    "$HOMEDIR/.ssh"
    "$HOMEDIR/.gitconfig"
    "$HOMEDIR/.gitconfig.local"
    "$HOMEDIR/.gitignore.global"
  )

  for target in "${targets[@]}"; do
    if [ -e "$target" ]; then
      chown -R "$LOGNAME:$LOGNAME" "$target"
    fi
  done

  logInfo "Installing 'kde-dotfiles-doctor' utility globally to /usr/local/bin..."
  mkdir -p /usr/local/bin
  ln -sf "$BASEDIR/utilities/post-install/kde-dotfiles-doctor.sh" "/usr/local/bin/kde-dotfiles-doctor"
  chmod +x "$BASEDIR/utilities/post-install/kde-dotfiles-doctor.sh"
  chmod +x "/usr/local/bin/kde-dotfiles-doctor"

  logSuccess "User file ownership and global tools successfully verified!"
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
