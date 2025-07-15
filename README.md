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
- Starship instead of OMZ and Powerlevel10k?
  - Not until transient prompt is supported for zsh
- Gum (https://github.com/charmbracelet/gum)
- Ask which types of ssh keys to add
- Separate user specific config and setup from the rest, and make it available as a final optional step
- Enable full pre-config support to enable unattended setup
  - Add support for providing config files for which packages to install
- Add full documentation of the whole process
- Colored output for better readability during installation process
- Move the Oh My Zsh plugin to separate repository?
- Configure git commit signing
  - Add allowed_signers to the .ssh folder
- Password protected ssh keys?
- Use ZSH plugins gpg-agent and ssh-agent
  - zstyle :omz:plugins:ssh-agent quiet yes
  - zstyle :omz:plugins:ssh-agent lazy yes
  - Add ssh config file (chmod 600) `Host *\n  AddKeysToAgent yes`
