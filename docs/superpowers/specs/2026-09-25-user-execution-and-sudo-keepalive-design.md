# Design Spec: User-Mode Execution & Sudo Keepalive

## Context & Problem Statement
Currently, the dotfiles installer requires root execution (`sudo ./init.sh`). When run as root:
- It creates a temporary `/etc/sudoers.d/99-dotfiles-installer` drop-in granting `NOPASSWD` to the user.
- Tasks that manage user files must explicitly drop privileges using `sudo -H -u "$LOGNAME"` or `su "$LOGNAME"`.
- Desktop tools requiring the user D-Bus session bus (e.g. `kwriteconfig6`, `qdbus6`, `yakuake`) encounter environment and authorization friction.
- Home directory files risk being owned by `root`, necessitating a cleanup sweep at the end.
- Arch AUR helpers (like `paru` and `makepkg`) prohibit execution as root and require awkward wrappers.

## Goals
- Allow `init.sh` to run directly as an unprivileged user (`./init.sh`).
- Prevent executing the script as `root` directly (`sudo ./init.sh` will exit with a helpful error).
- Elevate privileges via `sudo` on-demand only when a workflow or step requiring root is executed (e.g. full installation, system package installation, systemd service configuration).
- Maintain an active `sudo` keepalive background process during privileged execution so the user only authenticates once and does not time out during long builds or operations.
- Ensure that if `gum` is missing and must be bootstrapped via `sudo pacman`, the keepalive loop starts immediately so that the initial password prompt covers the rest of the installation without re-prompting.
- In modular mode, allow pure user-space configuration tasks (Git, Zsh, Nano, Vivaldi, Herdr, Agents, etc.) to run with zero root requests or password prompts.
- Clean up inverted privilege drops (`sudo -H -u "$LOGNAME"`, `su "$LOGNAME"`) across the codebase.

## Non-Goals
- Eliminating `sudo` from tasks that genuinely require system administrative privileges (e.g. `/etc/pacman.conf`, system package management, `docker` group creation, `/root/.zshrc`).
- Retaining temporary `/etc/sudoers.d/` drop-in files.

---

## Architecture & Detailed Design

### 1. Root Execution Guard
In [init.sh](file:///home/erichjsonfosse/projects/manjaro-cachy-os-kde-dotfiles/main/init.sh), invert the root check at the entry point:
```bash
if [ "$EUID" -eq 0 ]; then
  echo "Error: Dotfiles installer should NOT be run as root."
  echo "Please run as your regular user: ./init.sh"
  exit 1
fi
```

### 2. Sudo Keepalive Lifecycle
Add functions to [utilities/during-install/utilities.sh](file:///home/erichjsonfosse/projects/manjaro-cachy-os-kde-dotfiles/main/utilities/during-install/utilities.sh):

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
      # Exit if parent process is no longer running
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
```

Remove the `/etc/sudoers.d/99-dotfiles-installer` generation and cleanup trap from `init.sh`.

### 3. Early Gum Bootstrap
In `init.sh`, if `gum` is not found, start keepalive first so that the user authenticates once, installs `gum`, and keeps the authenticated session for subsequent steps:
```bash
if ! command -v gum &> /dev/null; then
  echo "gum could not be found, installing it..."
  startSudoKeepalive
  sudo pacman -Sy --needed --noconfirm gum
fi
```

### 4. Privilege Classification & UI Selection
Define a helper function in `utilities.sh`:
```bash
stepRequiresRoot()
{
  local func="$1"
  case "$func" in
    checkPacmanLock|installPacmanPackages|installAurPackages|configureDocker|configureKwin|postInstallZshConfig|ensureUserOwnershipOfHomeFolder|promptForReboot)
      return 0
      ;;
    *)
      return 1
      ;;
  esac
}
```

- **Full Run (`doRun`)**:
  Calls `startSudoKeepalive` at the beginning of `doRun`.
- **Advanced Modular Menu (`welcome-screen.sh`)**:
  Scans all selected configurations. If `stepRequiresRoot` returns 0 for any selected task, calls `startSudoKeepalive` once upfront before running the task queue. If none require root, runs completely unprivileged.
- **SSH Key Generator**:
  Executes `./utilities/post-install/generate-ssh-key.sh` directly as user (without `su "$LOGNAME"`).
- **Unattended Mode**:
  Calls `startSudoKeepalive` upfront before `doRun`.

---

## File Refactoring Specifications

### 1. [set-variables.sh](file:///home/erichjsonfosse/projects/manjaro-cachy-os-kde-dotfiles/main/set-variables.sh)
- Set `LOGNAME="${USER:-$(id -un)}"`
- Set `HOMEDIR="$HOME"`

### 2. [install/pacman-packages.sh](file:///home/erichjsonfosse/projects/manjaro-cachy-os-kde-dotfiles/main/install/pacman-packages.sh)
- Prefix system file edits and commands with `sudo`:
  - `sudo sed -i ... /etc/pacman.conf`
  - `sudo pacman-mirrors ...` (Manjaro)
  - `sudo reflector ...` (CachyOS)
  - `sudo awk ... > /tmp/cachyos-mirrorlist.tmp && sudo mv /tmp/cachyos-mirrorlist.tmp /etc/pacman.d/cachyos-mirrorlist`
  - `sudo cachyos-rate-mirrors`
  - `sudo sed -i ... /etc/makepkg.conf`
  - `sudo pacman -Syu --noconfirm`
  - `sudo pacman -Rns --noconfirm cachyos-zsh-config`
  - `sudo pacman -S --needed --noconfirm "${packages[@]}"`

### 3. [install/aur-packages.sh](file:///home/erichjsonfosse/projects/manjaro-cachy-os-kde-dotfiles/main/install/aur-packages.sh)
- If paru bootstrap is needed (Manjaro):
  - `sudo pacman -S --needed --noconfirm base-devel git cargo`
  - Clone directly: `git clone https://aur.archlinux.org/paru.git /tmp/paru-bootstrap`
  - Build directly: `(cd /tmp/paru-bootstrap && makepkg -s --noconfirm)`
  - Install with sudo: `sudo pacman -U --noconfirm /tmp/paru-bootstrap/paru-*.pkg.tar.zst`
- AUR package installation:
  - Run directly: `paru -Syu --needed --noconfirm "${packages[@]}"` (remove `sudo -u "$LOGNAME"`). Paru calls `sudo` internally as needed.

### 4. [config/zsh/zsh-config.sh](file:///home/erichjsonfosse/projects/manjaro-cachy-os-kde-dotfiles/main/config/zsh/zsh-config.sh)
- Remove `sudo -H -u "$LOGNAME"` from `touch "$ZSHRC_FILE"`
- Remove `sudo -H -u "$LOGNAME"` from `install-ohmyzsh.sh`
- Remove `sudo -H -u "$LOGNAME"` from `git clone ... powerlevel10k`
- Remove `sudo -H -u "$LOGNAME"` from `mkdir -p "$OHMYZSH_FOLDER/custom/plugins"`

### 5. [config/zsh/zsh-post-install.sh](file:///home/erichjsonfosse/projects/manjaro-cachy-os-kde-dotfiles/main/config/zsh/zsh-post-install.sh)
- Change `cp "$HOMEDIR/.zshrc" /root/.zshrc` to `sudo cp "$HOMEDIR/.zshrc" /root/.zshrc`.

### 6. [config/docker/docker-config.sh](file:///home/erichjsonfosse/projects/manjaro-cachy-os-kde-dotfiles/main/config/docker/docker-config.sh)
- Change `groupadd docker` to `sudo groupadd docker`
- Change `usermod -aG docker "$LOGNAME"` to `sudo usermod -aG docker "$LOGNAME"`
- Change `systemctl enable docker` to `sudo systemctl enable docker`

### 7. [config/ssh/ssh-config.sh](file:///home/erichjsonfosse/projects/manjaro-cachy-os-kde-dotfiles/main/config/ssh/ssh-config.sh)
- Change `su "$LOGNAME" -c "..."` to `systemctl --user enable --now ssh-agent.service`
- Remove redundant `chown -R "$LOGNAME:$LOGNAME" "$HOMEDIR/.ssh"`

### 8. [config/vivaldi/vivaldi-config.sh](file:///home/erichjsonfosse/projects/manjaro-cachy-os-kde-dotfiles/main/config/vivaldi/vivaldi-config.sh)
- Remove `sudo -H -u "$LOGNAME"` from `kwriteconfig6`, `kwriteconfig5`, `xdg-mime`, and `xdg-settings`.

### 9. [config/kde/kde-config.sh](file:///home/erichjsonfosse/projects/manjaro-cachy-os-kde-dotfiles/main/config/kde/kde-config.sh) & [kde-helpers.sh](file:///home/erichjsonfosse/projects/manjaro-cachy-os-kde-dotfiles/main/config/kde/kde-helpers.sh) & [kwin-config.sh](file:///home/erichjsonfosse/projects/manjaro-cachy-os-kde-dotfiles/main/config/kde/kwin-config.sh)
- Keep `sudo` on `/etc/environment` sed modifications.
- Remove `sudo -H -u "$LOGNAME"` from `qdbus6`, `dbus-send`, `kwriteconfig6`, `kreadconfig6`, `systemctl --user restart plasma-kglobalaccel.service`, and `yakuake`.

### 10. [config/herdr/herdr-config.sh](file:///home/erichjsonfosse/projects/manjaro-cachy-os-kde-dotfiles/main/config/herdr/herdr-config.sh)
- Remove `sudo -H -u "$LOGNAME"` from `herdr plugin` invocations.

### 11. [init.sh](file:///home/erichjsonfosse/projects/manjaro-cachy-os-kde-dotfiles/main/init.sh)
- In `ensureUserOwnershipOfHomeFolder`:
  - `sudo mkdir -p /usr/local/bin`
  - `sudo ln -sf "$BASEDIR/utilities/post-install/kde-dotfiles-doctor.sh" "/usr/local/bin/kde-dotfiles-doctor"`
  - `sudo chmod +x "/usr/local/bin/kde-dotfiles-doctor"`
- In `promptForReboot`:
  - `sudo reboot`
- Remove `/etc/sudoers.d/99-dotfiles-installer` setup and cleanup.

### 12. [utilities/during-install/utilities.sh](file:///home/erichjsonfosse/projects/manjaro-cachy-os-kde-dotfiles/main/utilities/during-install/utilities.sh)
- In `verifyPacmanLock` and `waitForPacmanLock`:
  - `sudo rm -f /var/lib/pacman/db.lck` when removing stale lock.

### 13. [README.md](file:///home/erichjsonfosse/projects/manjaro-cachy-os-kde-dotfiles/main/README.md) & [.dotfiles.unattended.example](file:///home/erichjsonfosse/projects/manjaro-cachy-os-kde-dotfiles/main/.dotfiles.unattended.example)
- Replace all `sudo ./init.sh` references with `./init.sh`.

---

## Edge Cases & Error Handling
1. **Script Interruption (Ctrl+C / SIGINT / SIGTERM):**
   The trap ensures `stopSudoKeepalive` kills `$SUDO_KEEPALIVE_PID`, preventing zombie keepalive processes.
2. **Terminal or Machine Hang:**
   The keepalive subshell monitors `kill -0 "$$"`. If the main shell exits abnormally or gets killed, the subshell detects the parent PID is gone and terminates immediately.
3. **User denies sudo password prompt:**
   `sudo -v` returns non-zero. `startSudoKeepalive` catches this, prints an error message, and exits gracefully instead of crashing halfway through.
4. **Already Authenticated:**
   `startSudoKeepalive` checks if the keepalive is already active before re-prompting or spawning redundant background loops.

---

## Verification Plan
1. **Root guard verification:** Run `sudo ./init.sh` and ensure it exits with code 1 and user guidance message.
2. **Syntax and lint check:** Run `bash -n` and `shellcheck` across all modified scripts.
3. **Unprivileged modular execution:** Run `./init.sh` -> Advanced -> select only Git/Zsh configs -> verify no sudo password prompt occurs.
4. **Privileged modular execution:** Run `./init.sh` -> Advanced -> select a privileged task (e.g. Docker or pacman packages) -> verify password prompt occurs once and keepalive runs.
5. **Keepalive cleanup verification:** Inspect `ps aux | grep "sudo -n true"` after script exits to confirm background process has terminated.
