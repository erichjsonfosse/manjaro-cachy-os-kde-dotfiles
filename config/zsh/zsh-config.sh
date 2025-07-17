#!/usr/bin/env bash

echo "Configuring Zsh with Oh My Zsh..."
ZSH="$HOMEDIR/.oh-my-zsh"
export ZSH

# Oh My Zsh
curl -fsSL -o install-ohmyzsh.sh https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh
chmod +x install-ohmyzsh.sh
# Oh My Zsh install options
su "$LOGNAME" -c "./install-ohmyzsh.sh --unattended"
rm -f ./install-ohmyzsh.sh

# Oh My Zsh Plugins
git clone https://github.com/zsh-users/zsh-autosuggestions "$ZSH/custom/plugins/zsh-autosuggestions"
git clone https://github.com/zsh-users/zsh-syntax-highlighting.git "$ZSH/custom/plugins/zsh-syntax-highlighting"

# Oh My Zsh Theme (Powerlevel10k)
git clone --depth=1 https://github.com/romkatv/powerlevel10k.git "$ZSH/custom/themes/powerlevel10k"

# Activate theme
sed -i "s/^ZSH_THEME=\(.*\)/\# ZSH_THEME=\1/g" "$ZSHRC_FILE"
sed -i "/^\# ZSH_THEME=\(.*\)/a ZSH_THEME=\"powerlevel10k/powerlevel10k\"" "$ZSHRC_FILE"

# Activate plugins
sed -i "s/^plugins=\(.*\)/\# plugins=\1/g" "$ZSHRC_FILE"
sed -i "/^\# plugins=\(.*\)/a plugins=\(\n  docker\n  docker-compose\n  dotnet\n  git\n  helm\n jsontools\n  kubectl\n  manjaro-dotfiles\n  nvm\n  zsh-autosuggestions\n  zsh-syntax-highlighting\n\)\n\n\# End plugins" "$ZSHRC_FILE"

# Add aliases
mkdir "$OHMYZSH_FOLDER/custom/plugins/manjaro-dotfiles"
cp -rf "$ZSHPLUGINDIR/"* "$OHMYZSH_FOLDER/custom/plugins/manjaro-dotfiles/"

# Edit date format for history command output
sed -i "/^\# HIST_STAMPS=\(.*\)/a HIST_STAMPS=yyyy-mm-dd" "$ZSHRC_FILE"

# Preparing PATH config
uncommentZshrcPath

# Setting Zsh as shell for root and user
chsh -s /bin/zsh
chsh -s /bin/zsh "$LOGNAME"
