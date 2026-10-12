#!/usr/bin/env bash

logHeader "Configuring Zsh Shell"
HOMEDIR="${HOMEDIR:-$HOME}"
ZSH="$HOMEDIR/.oh-my-zsh"
export ZSH

# Ensure the .zshrc file exists before running grep/sed on it
if [ ! -f "$ZSHRC_FILE" ]; then
  touch "$ZSHRC_FILE"
fi

# Copy Powerlevel10k configuration file (.p10k.zsh)
P10K_TEMPLATE="$CONFIGDIR/zsh/.p10k.zsh"
if [ -f "$P10K_TEMPLATE" ]; then
  logInfo "Copying Powerlevel10k theme configuration (.p10k.zsh)..."
  cp "$P10K_TEMPLATE" "$HOMEDIR/.p10k.zsh"
fi

# Add Powerlevel10k Instant Prompt to top of .zshrc if not present
if ! grep -q 'p10k-instant-prompt' "$ZSHRC_FILE"; then
  sed -i '1i # Enable Powerlevel10k instant prompt.\nif [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then\n  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"\nfi\n' "$ZSHRC_FILE"
fi

# Oh My Zsh Installation (only if not already installed)
if [ ! -d "$ZSH" ]; then
  logInfo "Oh My Zsh not found. Downloading and installing..."
  curl -fsSL -o install-ohmyzsh.sh https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
  chmod +x install-ohmyzsh.sh
  env RUNZSH="no" ./install-ohmyzsh.sh --unattended
  rm -f ./install-ohmyzsh.sh
else
  logInfo "Oh My Zsh already installed. Skipping base installation..."
fi

# Oh My Zsh Theme (Powerlevel10k)
if [ ! -d "$ZSH/custom/themes/powerlevel10k" ]; then
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH/custom/themes/powerlevel10k"
fi

# Activate theme
if ! grep -q '^ZSH_THEME="powerlevel10k/powerlevel10k"' "$ZSHRC_FILE"; then
  sed -i "s/^ZSH_THEME=\(.*\)/\# ZSH_THEME=\1/g" "$ZSHRC_FILE"
  sed -i '/^\# ZSH_THEME=\(.*\)/a ZSH_THEME="powerlevel10k/powerlevel10k"' "$ZSHRC_FILE"
fi
# Initialize NVM directory and symlinks for Arch Linux pacman package
ARCH_NVM_DIR="${ARCH_NVM_DIR:-/usr/share/nvm}"
if [ -f "$ARCH_NVM_DIR/nvm.sh" ]; then
  mkdir -p "$HOMEDIR/.nvm"
  [ ! -e "$HOMEDIR/.nvm/nvm.sh" ] && ln -sf "$ARCH_NVM_DIR/nvm.sh" "$HOMEDIR/.nvm/nvm.sh"
  [ ! -e "$HOMEDIR/.nvm/nvm-exec" ] && ln -sf "$ARCH_NVM_DIR/nvm-exec" "$HOMEDIR/.nvm/nvm-exec"
  if [ -f "$ARCH_NVM_DIR/bash_completion" ] && [ ! -e "$HOMEDIR/.nvm/bash_completion" ]; then
    ln -sf "$ARCH_NVM_DIR/bash_completion" "$HOMEDIR/.nvm/bash_completion"
  fi
fi

# Configure Oh My Zsh NVM plugin settings
if ! grep -q ":omz:plugins:nvm" "$ZSHRC_FILE"; then
  if grep -q '^# Which plugins would you like to load?' "$ZSHRC_FILE"; then
    sed -i '/^# Which plugins would you like to load?/i # NVM Plugin Settings\nzstyle ":omz:plugins:nvm" lazy yes\nzstyle ":omz:plugins:nvm" autoload yes\nzstyle ":omz:plugins:nvm" lazy-cmd ng\n' "$ZSHRC_FILE"
  elif grep -q '^plugins=' "$ZSHRC_FILE"; then
    sed -i '/^plugins=/i # NVM Plugin Settings\nzstyle ":omz:plugins:nvm" lazy yes\nzstyle ":omz:plugins:nvm" autoload yes\nzstyle ":omz:plugins:nvm" lazy-cmd ng\n' "$ZSHRC_FILE"
  else
    printf '# NVM Plugin Settings\nzstyle ":omz:plugins:nvm" lazy yes\nzstyle ":omz:plugins:nvm" autoload yes\nzstyle ":omz:plugins:nvm" lazy-cmd ng\n\n' >> "$ZSHRC_FILE"
  fi
fi

# Activate plugins
if ! grep -q '^plugins=.*manjaro-cachy-os-kde-dotfiles' "$ZSHRC_FILE" && ! awk '/^plugins=\(/,/^\)/' "$ZSHRC_FILE" | grep -q 'manjaro-cachy-os-kde-dotfiles'; then
  sed -i "s/^plugins=\(.*\)/\# plugins=\1/g" "$ZSHRC_FILE"
  sed -i '/^\# plugins=\(.*\)/a plugins=\(\n  command-not-found\n  docker\n  docker-compose\n  dotnet\n  git\n  helm\n  isodate\n  jsontools\n  kubectl\n  manjaro-cachy-os-kde-dotfiles\n  nvm\n  qrcode\n  sudo\n\)\n\n\# End plugins' "$ZSHRC_FILE"
fi

# Add aliases (using symlinks - ensure directory exists first)
mkdir -p "$OHMYZSH_FOLDER/custom/plugins"
ln -sfn "$ZSHPLUGINDIR/"* "$OHMYZSH_FOLDER/custom/plugins/"

# Edit date format for history command output
if ! grep -q '^HIST_STAMPS="yyyy-mm-dd"' "$ZSHRC_FILE" && ! grep -q "^HIST_STAMPS=yyyy-mm-dd" "$ZSHRC_FILE"; then
  sed -i "s/^HIST_STAMPS=\(.*\)/\# HIST_STAMPS=\1/g" "$ZSHRC_FILE"
  sed -i '/^\# HIST_STAMPS=\(.*\)/a HIST_STAMPS="yyyy-mm-dd"' "$ZSHRC_FILE"
fi

# Source Arch system packages for zsh plugins (safeguard paths)
if ! grep -q "source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" "$ZSHRC_FILE"; then
  echo "" >> "$ZSHRC_FILE"
  echo "source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" >> "$ZSHRC_FILE"
fi
if ! grep -q "source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" "$ZSHRC_FILE"; then
  echo "source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> "$ZSHRC_FILE"
fi

# Source ~/.p10k.zsh at the end of .zshrc if not present
if ! grep -q 'source ~/.p10k.zsh' "$ZSHRC_FILE" && ! grep -q 'source "$HOME/.p10k.zsh"' "$ZSHRC_FILE"; then
  {
    echo ""
    echo "# To customize prompt, run \`p10k configure\` or edit ~/.p10k.zsh."
    echo "[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh"
  } >> "$ZSHRC_FILE"
fi

# Sourcing local overrides if they exist
if ! grep -q "source \$HOME/.zshrc.local" "$ZSHRC_FILE" && ! grep -q "source ~/.zshrc.local" "$ZSHRC_FILE"; then
  {
    echo ""
    echo "# User-specific overrides"
    echo "if [ -f \"\$HOME/.zshrc.local\" ]; then"
    echo "  source \"\$HOME/.zshrc.local\""
    echo "fi"
  } >> "$ZSHRC_FILE"
fi

# Create a template .zshrc.local if it doesn't exist
if [ ! -f "$HOMEDIR/.zshrc.local" ]; then
  {
    echo "# =========================================================="
    echo "#                ZSH Local Overrides (Untracked)            "
    echo "# =========================================================="
    echo "# Put your custom environment variables, aliases, and functions here."
    echo "# These will persist across dotfile installations/updates."
    echo ""
    echo "# Example alias:"
    echo "# alias ll='ls -lah'"
    echo ""
  } > "$HOMEDIR/.zshrc.local"
  chown "$LOGNAME":"$LOGNAME" "$HOMEDIR/.zshrc.local"
fi

# Preparing PATH config
uncommentZshrcPath
addToZshrcPath '$HOME/.local/bin'

# Setting Zsh as shell for user if needed
if [ "$SHELL" != "/bin/zsh" ] && [ "$SHELL" != "/usr/bin/zsh" ]; then
  if command -v sudo &>/dev/null && sudo -n true 2>/dev/null; then
    sudo chsh -s /bin/zsh "$LOGNAME"
  else
    chsh -s /bin/zsh "$LOGNAME" || logWarning "Could not change shell to /bin/zsh automatically. You can run 'chsh -s /bin/zsh' manually."
  fi
fi

logSuccess "Zsh configuration applied successfully!"
