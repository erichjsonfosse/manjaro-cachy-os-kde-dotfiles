#!/bin/bash

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
sed -i "s/^ZSH_THEME=\(.*\)/\# ZSH_THEME=\1/g" "$ZSHRCFILE"
sed -i "/^\# ZSH_THEME=\(.*\)/a ZSH_THEME=\"powerlevel10k/powerlevel10k\"" "$ZSHRCFILE"

# Activate plugins
sed -i "s/^plugins=\(.*\)/\# plugins=\1/g" "$ZSHRCFILE"
sed -i "/^\# plugins=\(.*\)/a plugins=\(\n  docker\n  docker-compose\n  dotnet\n  fd\n  git\n  helm\n  kubectl\n  manjaro-dotfiles\n  nvm\n  ufw\n  zsh-autosuggestions\n  zsh-syntax-highlighting\n\)" "$ZSHRCFILE"

# Add aliases
mkdir "$OHMYZSHFOLDER/custom/plugins/manjaro-dotfiles"
cp -rf "$ZSHPLUGINDIR/"* "$OHMYZSHFOLDER/custom/plugins/manjaro-dotfiles/"

# Preparing PATH config
sed -i "/^\# export PATH=\(.*\)/a export PATH=\1/g" "$ZSHRCFILE"

# Setting Zsh as shell for user
chsh -s /bin/zsh $LOGNAME
