latestNvmVersion=$(getlatesttag https://github.com/nvm-sh/nvm)
su "$LOGNAME" -c 'curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/$latestNvmVersion/install.sh" | bash'
