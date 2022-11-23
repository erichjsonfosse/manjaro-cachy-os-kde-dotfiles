latestNvmVersion=$(getlatesttag https://github.com/nvm-sh/nvm)
curl -o- "https://raw.githubusercontent.com/nvm-sh/nvm/$latestNvmVersion/install.sh" | bash
