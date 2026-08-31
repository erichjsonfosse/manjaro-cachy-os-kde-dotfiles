# Manjaro & CachyOS KDE Plasma 6 Dotfiles

Modern, streamlined, and automated dotfiles and system configurations tailored for **Manjaro Linux** and **CachyOS** running **KDE Plasma 6 (Wayland)**.

---

## 🚀 Quickstart

Clone the repository and run the setup script with administrative privileges:

```bash
git clone https://github.com/erichjsonfosse/manjaro-cachy-os-kde-dotfiles.git
cd manjaro-cachy-os-kde-dotfiles
sudo ./init.sh
```

### 🎛️ Interactive Installation Modes

The installer features a clean, interactive TUI powered by **[Gum](https://github.com/charmbracelet/gum)**:

* **Standard (Full Run):** Automatically runs the complete end-to-end configuration pipeline (system backups, package upgrades, shell environment, and desktop settings).
* **Advanced (Modular Mode):** Allows you to select and run specific configuration steps individually (e.g. selectively re-running only `configureKwin`, `configureZsh`, `installPackages`, or `configureGit`).

---

## ✨ Features & Architecture

### 🖥️ KDE Plasma 6 & KWin (Wayland)
* **Per-Application Keyboard Layouts:** Seamless layout toggling between US and Norwegian (`Meta+Space`) with native OSD feedback and per-application layout persistence.
* **Yakuake Drop-Down Terminal:** Instant `F12` drop-down terminal integration with Keep Above rules and Wayland activation token focus management.
* **Balanced Focus Stealing Prevention:** Configured to Level 2 (Medium)—protects active typing from pop-up interruptions while automatically granting focus to newly launched windows when you are idly waiting.
* **Quick Navigation Shortcuts:** Application Launcher mapped to `Meta+S`, and Plasma Overview mapped to bare `Meta`.

### 🐚 Shell & Terminal Workflow
* **Zsh & Powerlevel10k:** Fast, beautiful prompt powered by Oh My Zsh, Powerlevel10k, syntax highlighting, and auto-suggestions.
* **Zellij Workspace Integration:** Drop-down terminal automatically manages and attaches to persistent Zellij sessions.
* **Node Version Manager (NVM):** Automatic NVM hooks and Angular CLI autocompletion support.

### 📦 Package Management & System Tuning
* **Fast Parallel Downloads:** Automatically enables `ParallelDownloads = 5` and custom pacman progress styling.
* **Secure & Rated Mirrors:** Automated mirror updating and benchmarking via `pacman-mirrors` (Manjaro), `reflector`, and `cachyos-rate-mirrors` (CachyOS), strictly filtered through a curated country whitelist.
* **Multi-Core AUR Compilation:** Automatically configures `makepkg` to compile packages in parallel across available CPU cores.
* **Modern AUR Helper:** Bootstraps `paru` for fast AUR package management.

### 🩺 System Diagnostics
* **KDE Dotfiles Doctor:** Includes `utilities/post-install/kde-dotfiles-doctor.sh` to verify system health, package dependencies, and configuration integrity after installation.

---

## 🛠️ Utility Functions & Aliases

### Helper Functions

| Command        | Description                                                     | Example                                          |
|:---------------|:----------------------------------------------------------------|:-------------------------------------------------|
| `getlatesttag` | Retrieves the latest Git tag for a remote repository            | `getlatesttag https://github.com/nvm-sh/nvm`     |
| `hextouuid`    | Converts a 32-character hexadecimal string into a standard UUID | `hextouuid 9CE4F1095C05422CB261AAAAE2F04476`     |
| `uuidtohex`    | Strips hyphens to convert a UUID into a raw hexadecimal string  | `uuidtohex ade75aee-69ce-41e3-88ea-048124776ca1` |

### Shell Aliases
* `glt` ➔ `getlatesttag`

### Git Aliases
* `git last` ➔ Shows the most recent commit log entry.
* `git tl` ➔ Lists repository tags.

---

## 📋 Roadmap / TODO

- [ ] Git Credentials Manager integration
- [ ] `eza` directory listing utility and aliases
- [ ] `bat` and `fzf` terminal enhancements
- [ ] Starship prompt exploration
- [ ] Unattended setup CLI flags for automated CI/VM deployments
