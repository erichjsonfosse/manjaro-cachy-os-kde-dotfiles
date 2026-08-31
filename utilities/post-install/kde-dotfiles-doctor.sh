#!/usr/bin/env bash

# This script diagnoses and automatically repairs common dotfile issues (permissions, shell, services).

if [ "$EUID" -eq 0 ]; then
  echo "Please do not run this script as root. Run it as your normal user. It will ask for sudo when needed."
  exit 1
fi

# Locate gum
if ! command -v gum &>/dev/null; then
  echo "gum could not be found, installing it..."
  sudo pacman -Sy --needed --noconfirm gum
fi

clear
gum style \
  --border double \
  --border-foreground 99 \
  --foreground 99 \
  --padding "1 2" \
  --margin "1 2" \
  --align center \
  "🩺 Dotfiles Doctor 🩺" \
  "Self-Healing Desktop Diagnosis & Repair Utility"

echo -e "Starting diagnosis of your Manjaro/CachyOS KDE environment...\n"

# Helper for formatted reporting
log_status() {
  local status="$1"
  local component="$2"
  local message="$3"
  
  if [ "$status" = "OK" ]; then
    gum style --foreground 82 "  ✔  [OK] $component: $message"
  elif [ "$status" = "WARN" ]; then
    gum style --foreground 208 "  ⚠  [WARN] $component: $message"
  else
    gum style --foreground 196 "  ✘  [FAIL] $component: $message"
  fi
}

issues_found=0
fix_ownership=false
fix_shell=false
fix_docker_group=false
fix_services=false

# ================= 1. File Ownership and Permissions =================
gum style --bold --foreground 99 "1. Auditing User File Ownership..."
root_owned_files=()

# Paths to scan for root ownership
scan_paths=(
  "$HOME/.config"
  "$HOME/.oh-my-zsh"
  "$HOME/.ssh"
  "$HOME/.zshrc"
  "$HOME/.zshrc.local"
  "$HOME/.nanorc"
)

for path in "${scan_paths[@]}"; do
  if [ -e "$path" ]; then
    # Find files or directories owned by root
    while IFS= read -r file; do
      if [ -n "$file" ]; then
        root_owned_files+=("$file")
      fi
    done < <(find "$path" -user root 2>/dev/null)
  fi
done

if [ "${#root_owned_files[@]}" -eq 0 ]; then
  log_status "OK" "Permissions" "All home configurations are correctly owned by $USER."
else
  log_status "FAIL" "Permissions" "Found ${#root_owned_files[@]} files owned by root!"
  issues_found=$((issues_found + 1))
  fix_ownership=true
fi
echo ""

# ================= 2. Default Shell Audit =================
gum style --bold --foreground 99 "2. Auditing Default Shell..."
current_shell=$SHELL
user_db_shell=$(getent passwd "$USER" | cut -d: -f7)

if [[ "$user_db_shell" == *"/zsh" ]]; then
  log_status "OK" "Shell" "Zsh is set as your default system shell (currently running $(basename "$current_shell"))."
else
  log_status "FAIL" "Shell" "Your default shell is currently $user_db_shell, but your active terminal is running $(basename "$current_shell") (Zsh expected)."
  issues_found=$((issues_found + 1))
  fix_shell=true
fi
echo ""

# ================= 3. Docker Service & Groups =================
gum style --bold --foreground 99 "3. Auditing Docker Setup..."
if command -v docker &>/dev/null; then
  # Check if user is in docker group
  if groups | grep -q "\bdocker\b"; then
    log_status "OK" "Docker" "Your user is in the 'docker' permission group."
  else
    log_status "FAIL" "Docker" "Your user is NOT in the 'docker' group."
    issues_found=$((issues_found + 1))
    fix_docker_group=true
  fi
else
  log_status "WARN" "Docker" "Docker engine is not installed on this system."
fi
echo ""

# ================= 4. Systemd User Services =================
gum style --bold --foreground 99 "4. Auditing Systemd SSH-Agent Service..."
ssh_agent_active=$(systemctl --user is-active ssh-agent.service 2>/dev/null || echo "inactive")

if [ "$ssh_agent_active" = "active" ]; then
  log_status "OK" "SSH-Agent" "User ssh-agent.service is running cleanly."
else
  log_status "FAIL" "SSH-Agent" "User ssh-agent.service is NOT running."
  issues_found=$((issues_found + 1))
  fix_services=true
fi
echo ""

# ================= Repair Executions =================
if [ "$issues_found" -eq 0 ]; then
  gum style --foreground 82 --bold "🎉 Everything is in perfect order! No issues found."
  exit 0
fi

gum style --foreground 208 --bold "Found $issues_found issue(s) that need correction."
if ! gum confirm "Would you like Doctor to automatically repair them now?"; then
  echo "Repairs skipped."
  exit 0
fi

# Fix 1: Ownership
if [ "$fix_ownership" = true ]; then
  gum spin --spinner dot --title "Fixing home folder root-ownership..." -- sudo chown -R "$USER:$USER" "${scan_paths[@]}" 2>/dev/null || true
  log_status "OK" "Permissions" "Ownership successfully restored to $USER!"
fi

# Fix 2: Default Shell
if [ "$fix_shell" = true ]; then
  gum spin --spinner dot --title "Setting default shell to Zsh..." -- sudo chsh -s /bin/zsh "$USER"
  log_status "OK" "Shell" "Zsh successfully set as your default shell!"
fi

# Fix 3: Docker Group
if [ "$fix_docker_group" = true ]; then
  gum spin --spinner dot --title "Adding $USER to the docker group..." -- sudo usermod -aG docker "$USER"
  log_status "OK" "Docker" "User added to docker group. Please log out and back in to apply group changes."
fi

# Fix 4: Services
if [ "$fix_services" = true ]; then
  gum spin --spinner dot --title "Starting and enabling user ssh-agent..." -- systemctl --user enable --now ssh-agent.service
  log_status "OK" "SSH-Agent" "User ssh-agent service successfully activated!"
fi

echo ""
gum style --foreground 82 --bold "🎉 All selected repairs completed successfully!"
