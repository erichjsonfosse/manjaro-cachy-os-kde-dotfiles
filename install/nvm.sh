latestNvmVersion=$(getlatesttag https://github.com/nvm-sh/nvm)
curl -fsSL -o install-nvm.sh "https://raw.githubusercontent.com/nvm-sh/nvm/$latestNvmVersion/install.sh"
su "$LOGNAME" -c './install-nvm.sh'
