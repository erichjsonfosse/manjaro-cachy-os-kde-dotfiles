#!/usr/bin/env bash

echo "Configuring Zsh with Oh My Zsh..."
ZSH="$HOMEDIR/.oh-my-zsh"
export ZSH

# Oh My Zsh
curl -fsSL -o install-ohmyzsh.sh https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
chmod +x install-ohmyzsh.sh
# Oh My Zsh install options
su "$LOGNAME" -c "RUNZSH=\"no\" ./install-ohmyzsh.sh --unattended"
rm -f ./install-ohmyzsh.sh



# Oh My Zsh Theme (Powerlevel10k)
if [ ! -d "$ZSH/custom/themes/powerlevel10k" ]; then
  git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH/custom/themes/powerlevel10k"
fi

# Activate theme
if ! grep -q '^ZSH_THEME="powerlevel10k/powerlevel10k"' "$ZSHRC_FILE"; then
  sed -i "s/^ZSH_THEME=\(.*\)/\# ZSH_THEME=\1/g" "$ZSHRC_FILE"
  sed -i '/^\# ZSH_THEME=\(.*\)/a ZSH_THEME="powerlevel10k/powerlevel10k"' "$ZSHRC_FILE"
fi

# Activate plugins
if ! grep -q '^plugins=.*manjaro-cachy-os-kde-dotfiles' "$ZSHRC_FILE" && ! awk '/^plugins=\(/,/^\)/' "$ZSHRC_FILE" | grep -q 'manjaro-cachy-os-kde-dotfiles'; then
  sed -i "s/^plugins=\(.*\)/\# plugins=\1/g" "$ZSHRC_FILE"
  sed -i '/^\# plugins=\(.*\)/a plugins=\(\n  command-not-found\n  docker\n  docker-compose\n  dotnet\n  git\n  helm\n  isodate\n  jsontools\n  kubectl\n  manjaro-cachy-os-kde-dotfiles\n  nvm\n  qrcode\n  sudo\n\)\n\n\# End plugins' "$ZSHRC_FILE"
fi

# Add aliases (using symlinks)
ln -sfn "$ZSHPLUGINDIR/"* "$OHMYZSH_FOLDER/custom/plugins/"

# Edit date format for history command output
if ! grep -q '^HIST_STAMPS="yyyy-mm-dd"' "$ZSHRC_FILE" && ! grep -q "^HIST_STAMPS=yyyy-mm-dd" "$ZSHRC_FILE"; then
  sed -i "s/^HIST_STAMPS=\(.*\)/\# HIST_STAMPS=\1/g" "$ZSHRC_FILE"
  sed -i '/^\# HIST_STAMPS=\(.*\)/a HIST_STAMPS="yyyy-mm-dd"' "$ZSHRC_FILE"
fi

# Source Arch system packages for zsh plugins
if ! grep -q "source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" "$ZSHRC_FILE"; then
  echo "" >> "$ZSHRC_FILE"
  echo "source /usr/share/zsh/plugins/zsh-autosuggestions/zsh-autosuggestions.zsh" >> "$ZSHRC_FILE"
fi
if ! grep -q "source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" "$ZSHRC_FILE"; then
  echo "source /usr/share/zsh/plugins/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh" >> "$ZSHRC_FILE"
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

# Setting Zsh as shell for root and user
chsh -s /bin/zsh
chsh -s /bin/zsh "$LOGNAME"
