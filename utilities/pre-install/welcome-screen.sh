#!/usr/bin/env bash

# Disable SC2154 because variables (HOMEDIR, steps, LOGNAME, etc.) are sourced from init.sh
# shellcheck disable=SC2154

showWelcomeScreen()
{
  clear
  # Premium banner
  gum style \
    --border double \
    --border-foreground 99 \
    --foreground 99 \
    --padding "1 2" \
    --margin "1 2" \
    --align center \
    "Manjaro & CachyOS KDE Dotfiles" \
    "Automated Desktop Installation & Configuration"

  echo -e "Welcome! This installer will configure packages, custom shell configurations, theme settings, and window layouts.\n"
  
  local choice
  choice=$(gum choose \
    "🚀 Start / Resume Dotfiles Installation" \
    "🛠️  Advanced: Run Specific Configurations" \
    "🔑 Generate SSH Key (Post-Install Utility)" \
    "❌ Exit" \
    --cursor.foreground 99)

  case "$choice" in
    *"Start"*)
      local VERSION_FILE="$HOMEDIR/.config/manjaro-cachy-os-kde-dotfiles/version"
      local CURRENT_VERSION=""
      if [ -f "$VERSION_FILE" ]; then
        CURRENT_VERSION=$(cat "$VERSION_FILE")
      fi
      local LATEST_VERSION
      LATEST_VERSION=$(git rev-parse HEAD 2>/dev/null || echo "unknown")

      if [ -n "$CURRENT_VERSION" ] && [ "$CURRENT_VERSION" == "$LATEST_VERSION" ]; then
        if ! gum confirm "You are already on the latest version of the dotfiles. Continue with installation anyway?"; then
          echo "Installation cancelled."
          exit 0
        fi
      else
        if ! gum confirm "Continue with installation?"; then
          echo "Installation cancelled."
          exit 0
        fi
      fi
      
      doRun
      ;;
    *"Advanced"*)
      clear
      gum style --foreground 99 --bold "🛠️ Advanced Modular Mode 🛠️"
      echo -e "\n⚠️  WARNING: Running individual configurations assumes that all required dependencies are already installed on your system!\n"

      local options=(
        "configureGit — Linking global and local Git configurations"
        "configureZsh — Configuring Zsh shell, plugins, and custom local overrides"
        "configureDocker — Configuring Docker socket permissions and user groups"
        "configurePyenv — Registering Python pyenv shims"
        "configureOnefetch — Setting up native Onefetch Zsh repository greeters"
        "configureNano — Setting up Nano editor options & 2-space tab layouts"
        "configureParu — Syncing optimized paru AUR-helper configurations"
        "configureSsh — Enabling and linking systemd ssh-agent"
        "configureVivaldi — Setting default browser and applying sanitized Vivaldi preferences"
        "configureKwin — Configuring KWin rules and Fcitx5 input methods"
        "postInstallGitConfig — Applying final Git signing key templates"
        "postInstallZshConfig — Compiling Oh My Zsh theme assets"
        "ensureUserOwnershipOfHomeFolder — Safely verifying user file ownership and permissions"
      )

      local selected_options
      selected_options=$(printf "%s\n" "${options[@]}" | gum choose --no-limit --cursor.foreground 99 --header "Select configurations to execute (Space to select, Enter to confirm):")

      if [ -z "$selected_options" ]; then
        echo "No configurations selected. Returning to main menu..."
        sleep 1.5
        showWelcomeScreen
        return 0
      fi

      if ! gum confirm "Are you sure you want to run the selected configurations?"; then
        echo "Cancelled. Returning to main menu..."
        sleep 1.5
        showWelcomeScreen
        return 0
      fi

      includeUtilities
      setVariables

      # Check if any selected option is a Git configuration
      if echo "$selected_options" | grep -Eq "configureGit|postInstallGitConfig"; then
        if [ -z "$MANJARO_DOTFILES_GIT_CONFIG_NAME" ] && [ -z "$MANJARO_DOTFILES_GIT_CONFIG_EMAIL_ADDRESS" ]; then
          echo ""
          gum style --foreground 208 "⚠️ Git configurations selected, but no credentials were found in the environment."
          if gum confirm "Would you like to collect Git credentials now?"; then
            source ./request-input.sh
          fi
        fi
      fi

      while IFS= read -r opt; do
        [ -z "$opt" ] && continue
        local idx
        idx=$(echo "$opt" | cut -d':' -f1)
        
        local entry="${steps[$idx]}"
        local func="${entry%%|*}"
        local desc="${entry#*|}"

        local styled_step
        styled_step=$(gum style --foreground 99 --bold "➜ Step $idx: $func")
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
      done <<< "$selected_options"

      echo ""
      gum style --foreground 82 --bold "🎉 All selected configurations successfully completed!"
      ;;
    *"Generate"*)
      echo "Launching SSH Key Generator..."
      su "$LOGNAME" -c "./utilities/post-install/generate-ssh-key.sh" || true
      ;;
    *"Exit"*)
      echo "Goodbye!"
      exit 0
      ;;
  esac
}
