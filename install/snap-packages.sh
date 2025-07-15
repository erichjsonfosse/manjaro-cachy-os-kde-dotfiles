#!/bin/bash

echo "Installing Snap packages..."

ln -s /var/lib/snapd/snap /snap

declare -a packages=(
"storage-explorer"
)

declare -a classicPackages=(
"code"
"datagrip"
"intellij-idea-ultimate"
"pycharm-professional"
"rider"
)

for p in "${packages[@]}"
do
  snap install "$p"
done

for p in "${classicPackages[@]}"
do
  snap install "$p" --classic
done

echo "Snap packages installed"
