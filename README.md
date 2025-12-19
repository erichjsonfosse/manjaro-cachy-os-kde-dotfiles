# Manjaro Dotfiles

Dotfiles for Manjaro installations


## Utility functions

| Name                            | Description                                    | Usage                                            |
|---------------------------------|------------------------------------------------|--------------------------------------------------|
| getlatesttag                    | Returns latest git tag for a given repositotry | getlatesttag https://github.com/nvm-sh/nvm       |
| hextouuid                       | Converts hexadecimal string into a uuid string | `hextouuid 9CE4F1095C05422CB261AAAAE2F04476`     |
| uuidtohex                       | Converts uuid string into hexadecimal string   | `uuidtohex ade75aee-69ce-41e3-88ea-048124776ca1` |


## Aliases
- glt => getlatesttag

## Git Aliases
- last - shows last log entry
- tl - shows list of tags


# TODO
- Git Credentials Manager
- Starship instead of OMZ and Powerlevel10k?
  - Not until transient prompt is supported for zsh
- Gum for dotfile scripts? (https://github.com/charmbracelet/gum)
  - Colored output for better readability during installation process 
- Separate user specific config and setup from the rest, and make it available as a final optional step
- Add full pre-config support to enable unattended setup
  - Add support for providing config files for which packages to install
- Add full documentation of the whole process
- Log errors, and give summary at end of installation
  - Support for debug logging?
