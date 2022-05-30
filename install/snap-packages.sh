#!/bin/bash

echo "Installing Snap packages..."

ln -s /var/lib/snapd/snap /snap

snap install code --classic
snap install datagrip --classic
snap install intellij-idea-ultimate --classic
snap install pycharm-professional --classic
snap install rider --classic
snap install storage-explorer


echo "Snap packages installed"
