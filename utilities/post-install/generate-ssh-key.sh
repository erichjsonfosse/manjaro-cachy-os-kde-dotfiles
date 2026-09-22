#!/usr/bin/env bash

# This script generates a new SSH key and configures Git to use it for commit signing.

if [ "$EUID" -eq 0 ]; then
  echo "Please do not run this script as root. Run it as your normal user."
  exit 1
fi

echo "=========================================================="
echo "          SSH Key Generation & Git Signing Setup          "
echo "=========================================================="
echo ""
echo "This script will generate a new ED25519 SSH key."
echo "You will be prompted to enter a passphrase. If you use a password manager,"
echo "make sure it is available before continuing."
echo ""

while true; do
  read -rp "Generate a new SSH key pair now? (y/n): " yn
  case $yn in
    [Yy]* ) 
      SSH_KEY_FILE="$HOME/.ssh/id_ed25519"
      mkdir -p "$HOME/.ssh"
      ssh-keygen -t ed25519 -C "$USER@$(hostname)" -f "$SSH_KEY_FILE"
      chmod 700 "$HOME/.ssh"
      
      echo ""
      echo "✅ SSH key generated successfully at $SSH_KEY_FILE"
      break
      ;;
    [Nn]* ) 
      echo "Aborting SSH key generation."
      exit 0
      ;;
    * ) 
      echo "Please answer yes (y) or no (n)."
      ;;
  esac
done

echo ""
echo "Configuring Git to use this key for signing commits..."

SSH_PUBLIC_KEY_FILE="$SSH_KEY_FILE.pub"
SSH_PUBLIC_KEY_FILE_CONTENT=$(cat "$SSH_PUBLIC_KEY_FILE")
GIT_LOCAL_CONFIG="$HOME/.gitconfig.local"

# Configure Git commit signing
git config --global gpg.format ssh
git config --global commit.gpgsign true

if [ -f "$GIT_LOCAL_CONFIG" ]; then
  git config --file "$GIT_LOCAL_CONFIG" user.signingkey "$SSH_PUBLIC_KEY_FILE"
else
  git config --global user.signingkey "$SSH_PUBLIC_KEY_FILE"
fi

# Extract the user's Git email to use in allowed_signers
GIT_EMAIL=$(git config --global --includes user.email 2>/dev/null || git config user.email 2>/dev/null)

if [ -z "$GIT_EMAIL" ]; then
  echo "⚠️  Warning: No Git email found. Please enter the email address you use for Git:"
  read -rp "Email: " GIT_EMAIL
  if [ -f "$GIT_LOCAL_CONFIG" ]; then
    git config --file "$GIT_LOCAL_CONFIG" user.email "$GIT_EMAIL"
  else
    git config --global user.email "$GIT_EMAIL"
  fi
fi

# Add the key to allowed_signers
ALLOWED_SIGNERS_FILE="$HOME/.ssh/allowed_signers"
mkdir -p "$HOME/.ssh"
echo "$GIT_EMAIL namespaces=\"git\" $SSH_PUBLIC_KEY_FILE_CONTENT" >> "$ALLOWED_SIGNERS_FILE"
chmod 600 "$ALLOWED_SIGNERS_FILE"

if [ -f "$GIT_LOCAL_CONFIG" ]; then
  git config --file "$GIT_LOCAL_CONFIG" gpg.ssh.allowedSignersFile "$ALLOWED_SIGNERS_FILE"
else
  git config --global gpg.ssh.allowedSignersFile "$ALLOWED_SIGNERS_FILE"
fi

echo "✅ Git commit signing configured successfully!"
echo ""
echo "Your public key is:"
echo "$SSH_PUBLIC_KEY_FILE_CONTENT"
echo ""
echo "Add this public key to your GitHub/GitLab account to verify your commits."
