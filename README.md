# Manjaro Dotfiles

Dotfiles for Manjaro installations

Enables AUR.

## Packages

- aspnet-runtime (pacman)
- Atom (pacman)
- Azure Storage Explorer (Snap)
- Datagrip (snap)
- Docker (pacman)
- Docker Compose (pacman)
- dotnet-host (pacman)
- dotnet-runtime (pacman)
- dotnet-sdk (pacman)
- dotnet-targeting-pack (pacman)
- Ferdi (Snap)
- FileZilla (pacman)
- Fira Code Fonts (pacman)
- Flutter (AUR)
- gnome-shell-extension-gsconnect (if GNOME)
- Google Chrome Browser (AUR)
- guake (pacman) (if GNOME)
- Inkscape (pacman)
- Insomnia Designer (AUR)
- Insomnia Core (AUR)
- IntelliJ IDEA Ultimate (Snap)
- Libre Office (pacman)
- Oh My Zsh (shell script)
- Oh My Zsh plugin: autosuggestions (shell script)
- Oh My Zsh plugin: syntaxhighlighting (shell script)
- Oh My Zsh theme: powerlevel10k (shell script)
- Pamac (pacman)
- Postman (AUR)
- Powerline Fonts (pacman)
- PowerShell (AUR)
- PyCharm Professional Edition (snap)
- Snap (pacman)
- UFW (pacman)
- Visual Studio Code (Snap)
- Vivaldi (pacman)
- Xournal Plus Plus (pacman)
- Yakuake (pacman) (if KDE)
- Zsh (pacman) (if KDE (already default in GNOME))


## Utility functions

| Name                            | Description                                    | Usage                                            |
|---------------------------------|------------------------------------------------|--------------------------------------------------|
| getlatesttag                    | Returns latest git tag for a given repositotry | getlatesttag https://github.com/nvm-sh/nvm       |
| gitcanhas (not yet implemented) | Clones given repository into given folder      | gitcanhas https://github.com/nvm-sh/nvm          |
| hextouuid                       | Converts hexadecimal string into a uuid string | `hextouuid 9CE4F1095C05422CB261AAAAE2F04476`     |
| icanhas (not yet implemented)   | Installs package                               | icanhas htop                                     |
| uuidtohex                       | Converts uuid string into hexadecimal string   | `uuidtohex ade75aee-69ce-41e3-88ea-048124776ca1` |


## Aliases
- glt => getlatesttag

## Git Aliases
- last - shows last log entry
- tl - shows list of tags

## Config
- SSH - ServerAliveInterval 60 (not yet implemented)
- SSH - ServerAliveCountMax 2 (not yet implemented)


# TODO
- Ask for which major versions to install for dotnet / aspnet
- Separate user specific config and setup from the rest, and make it available as a final optional step
- Enable full pre-config support to enable unattended setup
- Add full documentation of the whole process
