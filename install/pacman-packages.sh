#!/usr/bin/env bash


logInfo "Optimizing pacman settings..."
# Enable ParallelDownloads (default to 5)
if grep -q "^#ParallelDownloads" /etc/pacman.conf; then
  sed -i "s/^#ParallelDownloads.*/ParallelDownloads = 5/" /etc/pacman.conf
elif ! grep -q "^ParallelDownloads" /etc/pacman.conf; then
  sed -i "/\[options\]/a ParallelDownloads = 5" /etc/pacman.conf
fi

# Enable Color
if grep -q "^#Color" /etc/pacman.conf; then
  sed -i "s/^#Color/Color/" /etc/pacman.conf
fi

# Enable ILoveCandy progress bar (Pacman eating dots)
if ! grep -q "ILoveCandy" /etc/pacman.conf; then
  sed -i "/^Color/a ILoveCandy" /etc/pacman.conf
fi

if [ "$OS_ID" = "manjaro" ]; then
  logInfo "Updating pacman mirrors..."
  pacman-mirrors --country Austria,Canada,Denmark,France,Germany,Greece,Italy,Japan,Netherlands,Sweden,Switzerland,United_Kingdom
fi

# Enable Multi-Core Compilation for AUR packages
total_cores=$(nproc)
if [ "$total_cores" -gt 2 ]; then
  cores_to_use=$((total_cores - 2))
else
  cores_to_use=1
fi

logInfo "Configuring AUR builds to use parallel compilation ($cores_to_use/$total_cores cores)..."
if grep -q "^#MAKEFLAGS=" /etc/makepkg.conf; then
  sed -i "s/^#MAKEFLAGS=.*/MAKEFLAGS=\"-j$cores_to_use\"/" /etc/makepkg.conf
elif grep -q "^MAKEFLAGS=" /etc/makepkg.conf; then
  sed -i "s/^MAKEFLAGS=.*/MAKEFLAGS=\"-j$cores_to_use\"/" /etc/makepkg.conf
else
  echo "MAKEFLAGS=\"-j$cores_to_use\"" >> /etc/makepkg.conf
fi

logHeader "Upgrading pacman packages"
pacman -Syu
logSuccess "Pacman packages upgraded"

declare -a packages=(
# Browsers
"vivaldi"
# Development
"aspnet-runtime"
"azure-cli"
"code"
"docker"
"docker-buildx"
"docker-compose"
"dotnet-host"
"dotnet-runtime"
"dotnet-sdk"
"dotnet-targeting-pack"
"nvm"
"openjdk-src"
"pyenv"
# Fonts
"noto-fonts-emoji"
"powerline-fonts"
"ttf-fira-code"
# Office
"libreoffice-fresh"
"libreoffice-fresh-nb"
"obsidian"
"xournalpp"
# Utilities
"curl"
"filezilla"
"gum"
"helm"
"inkscape"
"jq"
"kde-cli-tools"
"kdeconnect"
"kubectl"
"make"
"mkcert"
"onefetch"
"pkgfile"
"qbittorrent"
"shellcheck"
"squashfuse"
"unzip"
"wl-clipboard"
"xclip"
"yakuake"
"zellij"
"zsh"
"zsh-autosuggestions"
"zsh-syntax-highlighting"
)

if [ "$OS_ID" = "manjaro" ]; then
  packages+=(
    "libpamac-flatpak-plugin"
    "libpamac-snap-plugin"
    "pamac"
  )
elif [ "$OS_ID" = "cachyos" ]; then
  echo "Removing CachyOS Zsh defaults..."
  pacman -Rns cachyos-zsh-config || true
  packages+=(
    "paru"
  )
fi

logHeader "Installing pacman packages"
pacman -S --needed "${packages[@]}"


logSuccess "Pacman packages installed"
