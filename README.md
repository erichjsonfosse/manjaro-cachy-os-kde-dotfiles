# Manjaro Dotfiles

Dotfiles for Manjaro installations


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
- Starship instead of Powerlevel10k?
- Gum (https://github.com/charmbracelet/gum)
- Ask which major versions to install for
  - dotnet / aspnet
  - Guake / Yakuake
  - GS Connect / KDE Connect
- Ask which types of ssh keys to add
- Install zsh early in the process if it's not already installed
- Separate user specific config and setup from the rest, and make it available as a final optional step
- Enable full pre-config support to enable unattended setup
  - Add support for providing config files for which packages to install
- Add full documentation of the whole process
- Colored output for better readability during installation process
- Move the Oh My Zsh plugin to separate repository?
- Usermod -> docker group
- One install command per package to avoid failures when packages go missing
- Password protected ssh keys?
- Start ssh-agent
  - Add generated ssh key to agent
