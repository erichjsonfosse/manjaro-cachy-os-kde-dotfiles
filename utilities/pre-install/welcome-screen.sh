#!/usr/bin/env bash

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
      local LATEST_VERSION=$(git rev-parse HEAD 2>/dev/null || echo "unknown")

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
