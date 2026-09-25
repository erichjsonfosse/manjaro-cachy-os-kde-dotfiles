# User-Mode Execution & Sudo Keepalive Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Transition dotfiles from requiring root execution (`sudo ./init.sh`) to running as regular user (`./init.sh`), prompting for sudo on-demand for privileged tasks while maintaining a background keepalive to avoid timeouts.

**Architecture:** A centralized `startSudoKeepalive()` background worker in `utilities.sh` refreshes `sudo -n true` every 45s while tracking parent process PID and traps cleanup on exit. `init.sh` enforces non-root execution (`EUID != 0`), bootstraps missing `gum` via keepalive upfront, and UI menus selectively elevate only when root tasks are queued. Codebase scripts strip obsolete `sudo -H -u "$LOGNAME"` and `su "$LOGNAME"` privilege drops, executing user tasks natively and prefixing system commands with `sudo`.

**Tech Stack:** Bash, Sudo, Pacman, Paru, Gum, Systemd user services, KDE Plasma 6 tools (`kwriteconfig6`, `qdbus6`).

## Global Constraints

- Never run the main dotfiles installer as `root` directly (`EUID != 0`).
- No persistent or temporary `/etc/sudoers.d/` drop-in files.
- All background keepalive processes must self-terminate if parent PID exits and be explicitly killed on `EXIT INT TERM`.
- Unprivileged modular steps (e.g. Git, Zsh, Nano) must execute with zero sudo prompts.

---

### Task 1: Sudo Keepalive & Privilege Utilities

**Files:**
- Modify: `utilities/during-install/utilities.sh`
- Test: `tests/test-keepalive-utils.sh`

**Interfaces:**
- Produces:
  - `startSudoKeepalive()`: Prompts for sudo if needed, spawns background 45s keepalive loop, registers exit cleanup trap.
  - `stopSudoKeepalive()`: Terminates background keepalive PID.
  - `stepRequiresRoot(func_name)`: Returns 0 if step requires root, 1 otherwise.

- [ ] **Step 1: Write test script for keepalive utilities**

Create `tests/test-keepalive-utils.sh`:
```bash
#!/usr/bin/env bash
set -eo pipefail

# Source utilities
source "./utilities/during-install/utilities.sh"

echo "Testing stepRequiresRoot..."
stepRequiresRoot "installPacmanPackages" || { echo "FAIL: installPacmanPackages should require root"; exit 1; }
stepRequiresRoot "configureDocker" || { echo "FAIL: configureDocker should require root"; exit 1; }
stepRequiresRoot "configureGit" && { echo "FAIL: configureGit should not require root"; exit 1; }
stepRequiresRoot "configureZsh" && { echo "FAIL: configureZsh should not require root"; exit 1; }
echo "stepRequiresRoot passed!"

echo "Testing keepalive life-cycle functions exist..."
type startSudoKeepalive &>/dev/null || { echo "FAIL: startSudoKeepalive not found"; exit 1; }
type stopSudoKeepalive &>/dev/null || { echo "FAIL: stopSudoKeepalive not found"; exit 1; }
echo "Keepalive functions defined successfully!"
```

- [ ] **Step 2: Run test to verify it fails**

Run: `bash tests/test-keepalive-utils.sh`
Expected: FAIL with "startSudoKeepalive not found"

- [ ] **Step 3: Implement keepalive functions in `utilities/during-install/utilities.sh`**

Add the following to [utilities/during-install/utilities.sh](file:///home/erichjsonfosse/projects/manjaro-cachy-os-kde-dotfiles/main/utilities/during-install/utilities.sh):
```bash
SUDO_KEEPALIVE_PID=""

startSudoKeepalive()
{
  # If already active and verified, do not re-prompt
  if sudo -n true 2>/dev/null && [ -n "$SUDO_KEEPALIVE_PID" ] && kill -0 "$SUDO_KEEPALIVE_PID" 2>/dev/null; then
    return 0
  fi

  logInfo "Administrative privileges (sudo) required for this task."
  if ! sudo -v; then
    logError "Sudo authentication failed. Aborting."
    exit 1
  fi

  # Launch background keepalive loop
  (
    while true; do
      sudo -n true 2>/dev/null
      sleep 45
      kill -0 "$$" 2>/dev/null || exit
    done
  ) 2>/dev/null &
  SUDO_KEEPALIVE_PID=$!

  # Ensure cleanup on exit
  trap stopSudoKeepalive EXIT INT TERM
}

stopSudoKeepalive()
{
  if [ -n "$SUDO_KEEPALIVE_PID" ]; then
    kill "$SUDO_KEEPALIVE_PID" 2>/dev/null || true
    wait "$SUDO_KEEPALIVE_PID" 2>/dev/null || true
    SUDO_KEEPALIVE_PID=""
  fi
}

stepRequiresRoot()
{
  local func="$1"
  case "$func" in
    checkPacmanLock | installPacmanPackages | installAurPackages | \
    configureDocker | configureKwin | postInstallZshConfig | \
    ensureUserOwnershipOfHomeFolder | promptForReboot)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `bash tests/test-keepalive-utils.sh`
Expected: PASS with "stepRequiresRoot passed!" and "Keepalive functions defined successfully!"

- [ ] **Step 5: Commit**

```bash
git add utilities/during-install/utilities.sh tests/test-keepalive-utils.sh
git commit -m "feat: add sudo keepalive and root step detection utilities"
```

---

### Task 2: Root Execution Guard & Installer Initialization in `init.sh`

**Files:**
- Modify: `init.sh`
- Modify: `utilities/during-install/utilities.sh`

**Interfaces:**
- Consumes: `startSudoKeepalive()`, `stopSudoKeepalive()` from `utilities.sh`
- Produces: Guarded entry point enforcing non-root execution, bootstrapping `gum` via keepalive upfront, and invoking keepalive in `doRun`.

- [ ] **Step 1: Update entry point guard in `init.sh`**

In [init.sh](file:///home/erichjsonfosse/projects/manjaro-cachy-os-kde-dotfiles/main/init.sh), replace:
```bash
if [ "$EUID" -ne 0 ]
  then
    echo "Script must be run as root"
    exit
fi
```
with:
```bash
if [ "$EUID" -eq 0 ]; then
  echo "Error: Dotfiles installer should NOT be run as root."
  echo "Please run as your regular user: ./init.sh"
  exit 1
fi
```

- [ ] **Step 2: Update `gum` bootstrap in `init.sh`**

Replace:
```bash
if ! command -v gum &> /dev/null; then
    echo "gum could not be found, updating package database and installing it..."
    pacman -Sy --needed --noconfirm gum
fi
```
with:
```bash
includeUtilities
setVariables

if ! command -v gum &> /dev/null; then
    echo "gum could not be found, installing it..."
    startSudoKeepalive
    sudo pacman -Sy --needed --noconfirm gum
fi
```

- [ ] **Step 3: Refactor `doRun()` in `init.sh` to use `startSudoKeepalive`**

Remove:
```bash
  cleanup_installer() {
    rm -f /etc/sudoers.d/99-dotfiles-installer
  }
  trap cleanup_installer EXIT

  if [ -n "$LOGNAME" ] && [ "$LOGNAME" != "root" ]; then
    echo "$LOGNAME ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/99-dotfiles-installer
    chmod 440 /etc/sudoers.d/99-dotfiles-installer
  fi
```
and replace with:
```bash
  startSudoKeepalive
```

- [ ] **Step 4: Update `ensureUserOwnershipOfHomeFolder` and `promptForReboot`**

In `ensureUserOwnershipOfHomeFolder`:
```bash
  logInfo "Installing 'kde-dotfiles-doctor' utility globally to /usr/local/bin..."
  sudo mkdir -p /usr/local/bin
  sudo ln -sf "$BASEDIR/utilities/post-install/kde-dotfiles-doctor.sh" "/usr/local/bin/kde-dotfiles-doctor"
  sudo chmod +x "$BASEDIR/utilities/post-install/kde-dotfiles-doctor.sh"
  sudo chmod +x "/usr/local/bin/kde-dotfiles-doctor"
```
In `utilities/during-install/utilities.sh`:
In `askForReboot()`: replace `reboot` with `sudo reboot`.
In `verifyPacmanLock()` and `waitForPacmanLock()`: replace `rm -f /var/lib/pacman/db.lck` with `sudo rm -f /var/lib/pacman/db.lck`.

- [ ] **Step 5: Verify syntax and root guard**

Run: `bash -n init.sh`
Run: `sudo bash -c 'exit 0'` (test sudo access), then verify root guard fails:
```bash
sudo ./init.sh || true
```
Expected: "Error: Dotfiles installer should NOT be run as root."

- [ ] **Step 6: Commit**

```bash
git add init.sh utilities/during-install/utilities.sh
git commit -m "feat: enforce non-root execution and remove temporary sudoers file"
```

---

### Task 3: Selective Elevation in Welcome Screen UI

**Files:**
- Modify: `utilities/pre-install/welcome-screen.sh`

**Interfaces:**
- Consumes: `stepRequiresRoot()` and `startSudoKeepalive()` from `utilities.sh`

- [ ] **Step 1: Check selected options in Advanced Modular Mode**

In [utilities/pre-install/welcome-screen.sh](file:///home/erichjsonfosse/projects/manjaro-cachy-os-kde-dotfiles/main/utilities/pre-install/welcome-screen.sh), before the loop executing `$selected_options`, inspect if any selected task requires root:
```bash
      # Check if any selected option requires root privileges
      local needs_root=false
      while IFS= read -r opt; do
        [ -z "$opt" ] && continue
        local idx
        idx=$(echo "$opt" | cut -d':' -f1)
        local entry="${steps[$idx]}"
        local func="${entry%%|*}"
        if stepRequiresRoot "$func"; then
          needs_root=true
          break
        fi
      done <<< "$selected_options"

      if [ "$needs_root" = true ]; then
        startSudoKeepalive
      fi
```

- [ ] **Step 2: Simplify SSH Key Generator menu option**

In `welcome-screen.sh`, replace:
```bash
    *"Generate"*)
      echo "Launching SSH Key Generator..."
      su "$LOGNAME" -c "./utilities/post-install/generate-ssh-key.sh" || true
      ;;
```
with:
```bash
    *"Generate"*)
      echo "Launching SSH Key Generator..."
      ./utilities/post-install/generate-ssh-key.sh || true
      ;;
```

- [ ] **Step 3: Syntax check**

Run: `bash -n utilities/pre-install/welcome-screen.sh`
Expected: Exit code 0

- [ ] **Step 4: Commit**

```bash
git add utilities/pre-install/welcome-screen.sh
git commit -m "feat: selectively elevate privileges in advanced welcome menu"
```

---

### Task 4: Environment Variables & Package Installation Scripts Refactoring

**Files:**
- Modify: `set-variables.sh`
- Modify: `install/pacman-packages.sh`
- Modify: `install/aur-packages.sh`

**Interfaces:**
- Standardizes user variables without sudo inversion.
- Updates package managers to invoke `sudo` for system changes and run user builders natively.

- [ ] **Step 1: Update `set-variables.sh`**

In [set-variables.sh](file:///home/erichjsonfosse/projects/manjaro-cachy-os-kde-dotfiles/main/set-variables.sh), replace:
```bash
if [ -n "$SUDO_USER" ]; then
  LOGNAME="$SUDO_USER"
else
  LOGNAME=$(logname 2>/dev/null || echo "$USER")
fi
export LOGNAME
HOMEDIR=$(eval echo ~"$LOGNAME")
export HOMEDIR
```
with:
```bash
LOGNAME="${USER:-$(id -un)}"
export LOGNAME
HOMEDIR="${HOME:-$(eval echo ~"$LOGNAME")}"
export HOMEDIR
```

- [ ] **Step 2: Add `sudo` to `install/pacman-packages.sh`**

Prefix all system file edits and pacman commands with `sudo`:
- Lines 7, 9, 14, 19: `sudo sed -i ... /etc/pacman.conf`
- Line 24: `sudo pacman-mirrors ...`
- Line 30: `sudo reflector ... --save /etc/pacman.d/mirrorlist`
- Line 36, 45: `sudo awk ... > /tmp/cachyos-mirrorlist.tmp && sudo mv /tmp/cachyos-mirrorlist.tmp /etc/pacman.d/cachyos-mirrorlist`
- Line 41: `sudo cachyos-rate-mirrors`
- Line 60, 62, 64: `sudo sed -i ... /etc/makepkg.conf` / `sudo tee -a /etc/makepkg.conf`
- Line 69: `sudo pacman -Syu --noconfirm`
- Line 140: `sudo pacman -Rns --noconfirm cachyos-zsh-config || true`
- Line 149: `sudo pacman -S --needed --noconfirm "${packages[@]}"`

- [ ] **Step 3: Refactor `install/aur-packages.sh`**

In [install/aur-packages.sh](file:///home/erichjsonfosse/projects/manjaro-cachy-os-kde-dotfiles/main/install/aur-packages.sh):
Replace:
```bash
    sudo pacman -S --needed --noconfirm base-devel git cargo
    rm -rf /tmp/paru-bootstrap
    su "$LOGNAME" -c "git clone https://aur.archlinux.org/paru.git /tmp/paru-bootstrap"
    su "$LOGNAME" -c "cd /tmp/paru-bootstrap && makepkg -s"
    waitForPacmanLock
    pacman -U --noconfirm /tmp/paru-bootstrap/paru-*.pkg.tar.zst
    rm -rf /tmp/paru-bootstrap
```
with:
```bash
    waitForPacmanLock
    sudo pacman -S --needed --noconfirm base-devel git cargo
    rm -rf /tmp/paru-bootstrap
    git clone https://aur.archlinux.org/paru.git /tmp/paru-bootstrap
    (cd /tmp/paru-bootstrap && makepkg -s --noconfirm)
    waitForPacmanLock
    sudo pacman -U --noconfirm /tmp/paru-bootstrap/paru-*.pkg.tar.zst
    rm -rf /tmp/paru-bootstrap
```
And replace line 39:
```bash
sudo -u "$LOGNAME" paru -Syu --needed --noconfirm "${packages[@]}"
```
with:
```bash
paru -Syu --needed --noconfirm "${packages[@]}"
```

- [ ] **Step 4: Verify syntax of modified scripts**

Run: `bash -n set-variables.sh install/pacman-packages.sh install/aur-packages.sh`
Expected: Exit code 0

- [ ] **Step 5: Commit**

```bash
git add set-variables.sh install/pacman-packages.sh install/aur-packages.sh
git commit -m "refactor: update package installers to run as user with targeted sudo"
```

---

### Task 5: Desktop & User Shell Configurations Refactoring

**Files:**
- Modify: `config/zsh/zsh-config.sh`
- Modify: `config/zsh/zsh-post-install.sh`
- Modify: `config/docker/docker-config.sh`
- Modify: `config/ssh/ssh-config.sh`
- Modify: `config/vivaldi/vivaldi-config.sh`
- Modify: `config/kde/kde-config.sh`
- Modify: `config/kde/kde-helpers.sh`
- Modify: `config/kde/kwin-config.sh`
- Modify: `config/herdr/herdr-config.sh`

- [ ] **Step 1: Clean up `config/zsh/zsh-config.sh` & `zsh-post-install.sh`**

In [config/zsh/zsh-config.sh](file:///home/erichjsonfosse/projects/manjaro-cachy-os-kde-dotfiles/main/config/zsh/zsh-config.sh):
- Remove `sudo -H -u "$LOGNAME"` from line 9 (`touch "$ZSHRC_FILE"`).
- Remove `sudo -H -u "$LOGNAME"` from line 30 (`env RUNZSH="no" ./install-ohmyzsh.sh --unattended`).
- Remove `sudo -H -u "$LOGNAME"` from line 38 (`git clone ...`).
- Remove `sudo -H -u "$LOGNAME"` from line 54 (`mkdir -p ...`).

In [config/zsh/zsh-post-install.sh](file:///home/erichjsonfosse/projects/manjaro-cachy-os-kde-dotfiles/main/config/zsh/zsh-post-install.sh):
- Change `cp "$HOMEDIR/.zshrc" /root/.zshrc` to `sudo cp "$HOMEDIR/.zshrc" /root/.zshrc`.

- [ ] **Step 2: Clean up `config/docker/docker-config.sh`**

In [config/docker/docker-config.sh](file:///home/erichjsonfosse/projects/manjaro-cachy-os-kde-dotfiles/main/config/docker/docker-config.sh):
- `sudo groupadd docker`
- `sudo usermod -aG docker "$LOGNAME"`
- `sudo systemctl enable docker`

- [ ] **Step 3: Clean up `config/ssh/ssh-config.sh`**

In [config/ssh/ssh-config.sh](file:///home/erichjsonfosse/projects/manjaro-cachy-os-kde-dotfiles/main/config/ssh/ssh-config.sh):
- Replace `su "$LOGNAME" -c "..."` with `systemctl --user enable --now ssh-agent.service`.
- Remove redundant `chown -R "$LOGNAME:$LOGNAME" "$HOMEDIR/.ssh"`.

- [ ] **Step 4: Clean up `config/vivaldi/vivaldi-config.sh`**

In [config/vivaldi/vivaldi-config.sh](file:///home/erichjsonfosse/projects/manjaro-cachy-os-kde-dotfiles/main/config/vivaldi/vivaldi-config.sh):
- Remove `sudo -H -u "$LOGNAME"` from `kwriteconfig6`, `kwriteconfig5`, `xdg-mime`, and `xdg-settings`.

- [ ] **Step 5: Clean up `config/kde/kde-config.sh`, `kde-helpers.sh`, and `kwin-config.sh`**

- In `kde-config.sh`: remove `sudo -H -u "$LOGNAME"` from `qdbus6`, `systemctl --user`, and `yakuake`. Keep `sudo sed -i` on `/etc/environment`.
- In `kde-helpers.sh`: remove `sudo -H -u "$LOGNAME"` from `kwriteconfig6`, `qdbus6`, and `dbus-send`.
- In `kwin-config.sh`: remove `sudo -H -u "$LOGNAME"` from `kreadconfig6`.

- [ ] **Step 6: Clean up `config/herdr/herdr-config.sh`**

In [config/herdr/herdr-config.sh](file:///home/erichjsonfosse/projects/manjaro-cachy-os-kde-dotfiles/main/config/herdr/herdr-config.sh):
- Remove `sudo -H -u "$LOGNAME"` from `herdr plugin` commands.

- [ ] **Step 7: Run syntax check across all config scripts**

Run: `bash -n config/**/*.sh`
Expected: Exit code 0

- [ ] **Step 8: Commit**

```bash
git add config/
git commit -m "refactor: eliminate inverted privilege drops across config scripts"
```

---

### Task 6: Documentation & Example Configuration Updates

**Files:**
- Modify: `README.md`
- Modify: `.dotfiles.unattended.example`

- [ ] **Step 1: Update README.md**

Replace all occurrences of `sudo ./init.sh` with `./init.sh` in [README.md](file:///home/erichjsonfosse/projects/manjaro-cachy-os-kde-dotfiles/main/README.md).

- [ ] **Step 2: Update `.dotfiles.unattended.example`**

Replace `sudo ./init.sh` with `./init.sh` in [.dotfiles.unattended.example](file:///home/erichjsonfosse/projects/manjaro-cachy-os-kde-dotfiles/main/.dotfiles.unattended.example).

- [ ] **Step 3: Commit**

```bash
git add README.md .dotfiles.unattended.example
git commit -m "docs: update execution command to ./init.sh"
```

---

### Task 7: Full End-to-End Verification

**Files:**
- Test: All scripts

- [ ] **Step 1: Run Shellcheck on all shell scripts**

Run: `find . -name "*.sh" -not -path "./.git/*" -exec shellcheck -x {} +`
Verify zero critical errors.

- [ ] **Step 2: Verify root prevention**

Run: `sudo ./init.sh || true`
Expected: Exits with non-zero status and prints "Error: Dotfiles installer should NOT be run as root."

- [ ] **Step 3: Verify unprivileged modular execution**

Run `./init.sh` in a test run with an unprivileged step (e.g. `checkPacmanLock` or `configureNano`) and verify no sudo password prompt appears.

- [ ] **Step 4: Clean up test files**

Remove `tests/test-keepalive-utils.sh` if no longer needed or keep in `tests/`.
```bash
git commit -m "test: verify end-to-end user-mode execution and sudo keepalive"
```
