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
  logInfo "Updating pacman mirrors for Manjaro..."
  pacman-mirrors --country Austria,Canada,Denmark,France,Germany,Greece,Italy,Japan,Netherlands,Sweden,Switzerland,United_Kingdom
elif [ "$OS_ID" = "cachyos" ]; then
  logInfo "Updating and filtering pacman mirrors for Cachy OS..."

  # 1. Update Arch Linux base mirrorlist with explicit countries via reflector if available
  if command -v reflector &>/dev/null; then
    reflector --country Austria,Canada,Denmark,France,Germany,Greece,Italy,Japan,Netherlands,Sweden,Switzerland,United_Kingdom --latest 15 --sort rate --save /etc/pacman.d/mirrorlist || true
  fi

  # 2. Filter CachyOS mirrorlist using strict whitelist (approved countries + official CDN)
  if [ -f "/etc/pacman.d/cachyos-mirrorlist" ]; then
    trusted_pattern="(\.cachyos\.org|\.no\b|\.se\b|\.dk\b|\.de\b|\.at\b|\.nl\b|\.fr\b|\.ch\b|\.uk\b|\.it\b|\.gr\b|\.jp\b|\.ca\b|no\.mirror|se\.mirror|de\.mirror|nl\.mirror|fr\.mirror|uk\.mirror)"
    awk -v pat="$trusted_pattern" '/^Server/ { if ($0 ~ pat) print; next } { print }' /etc/pacman.d/cachyos-mirrorlist > /tmp/cachyos-mirrorlist.tmp && mv /tmp/cachyos-mirrorlist.tmp /etc/pacman.d/cachyos-mirrorlist
  fi

  # 3. Rate remaining whitelisted mirrors
  if command -v cachyos-rate-mirrors &>/dev/null; then
    cachyos-rate-mirrors || true
    # Enforce strict whitelist filter after ranking
    if [ -f "/etc/pacman.d/cachyos-mirrorlist" ]; then
      trusted_pattern="(\.cachyos\.org|\.no\b|\.se\b|\.dk\b|\.de\b|\.at\b|\.nl\b|\.fr\b|\.ch\b|\.uk\b|\.it\b|\.gr\b|\.jp\b|\.ca\b|no\.mirror|se\.mirror|de\.mirror|nl\.mirror|fr\.mirror|uk\.mirror)"
      awk -v pat="$trusted_pattern" '/^Server/ { if ($0 ~ pat) print; next } { print }' /etc/pacman.d/cachyos-mirrorlist > /tmp/cachyos-mirrorlist.tmp && mv /tmp/cachyos-mirrorlist.tmp /etc/pacman.d/cachyos-mirrorlist
    fi
  fi
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
waitForPacmanLock
pacman -Syu --noconfirm
logSuccess "Pacman packages upgraded"

declare -a packages=(
# Browsers
"vivaldi"
# Development
"aspnet-runtime"
"azure-cli"
"code"
"direnv"
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
"bat"
"curl"
"eza"
"filezilla"
"fzf"
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
"zsh-completions"
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
  waitForPacmanLock
  pacman -Rns --noconfirm cachyos-zsh-config || true
  packages+=(
    "paru"
    "reflector"
  )
fi

logHeader "Installing pacman packages"
waitForPacmanLock
pacman -S --needed --noconfirm "${packages[@]}"


logSuccess "Pacman packages installed"
