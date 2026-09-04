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

### 🎛️ Installation Modes

The installer features an interactive TUI powered by **[Gum](https://github.com/charmbracelet/gum)** as well as a fully automated unattended mode:

* **Interactive (Standard):** Automatically runs the complete end-to-end configuration pipeline with interactive prompts for Git credentials and confirmation checks.
* **Interactive (Modular / Advanced):** Allows you to select and run specific configuration steps individually (e.g., selectively re-running only `configureKwin`, `configureZsh`, `installPackages`, or `configureGit`).
* **Unattended Mode:** Place a validated `.dotfiles.unattended` file in the root of the repository (template provided via `.dotfiles.unattended.example`). The installer will validate required settings, skip all interactive prompts, and run end-to-end automatically:
  ```bash
  cp .dotfiles.unattended.example .dotfiles.unattended
  # Edit .dotfiles.unattended with your credentials and reboot preference
  sudo ./init.sh
  ```

---

## ✨ Features & Architecture

### 🖥️ KDE Plasma 6 & KWin (Wayland)
* **Per-Application Keyboard Layouts:** Seamless layout toggling between US and Norwegian (`Meta+Space`) with native OSD feedback and per-application layout persistence.
* **Yakuake Drop-Down Terminal:** Instant `F12` drop-down terminal integration with Keep Above rules and Wayland activation token focus management.
* **Balanced Focus Stealing Prevention:** Configured to Level 2 (Medium)—protects active typing from pop-up interruptions while automatically granting focus to newly launched windows when you are idly waiting.
* **Quick Navigation Shortcuts:** Application Launcher mapped to `Meta+S`, and Plasma Overview mapped to bare `Meta`.

### 🐚 Shell & Terminal Workflow
* **Zsh & Powerlevel10k:** Fast, beautiful prompt powered by Oh My Zsh, Powerlevel10k, syntax highlighting, and auto-suggestions.
* **Eza Modern Directory Listings:** Replaces `ls` with `eza` featuring icons, Git status indicators, and tree hierarchy views.
* **Fzf Interactive Fuzzy Search:** Integrated `Ctrl+R` for history, `Ctrl+T` for file search with live `bat` syntax previews, and `Alt+C` for quick directory navigation with live `eza` tree previews.
* **Bat Syntax Highlighting:** Replaces `cat` with `bat` (unpaged) and provides syntax-highlighted manual pages (`man <command>`).
* **Direnv Integration:** Automatic per-directory environment loading and `.envrc` evaluation.
* **Zellij Workspace Integration:** Drop-down terminal automatically manages and attaches to persistent Zellij sessions.
* **Node Version Manager (NVM):** Automatic NVM hooks and Angular CLI autocompletion support.

### 📦 Package Management & System Tuning
* **Fast Parallel Downloads:** Automatically enables `ParallelDownloads = 5` and custom pacman progress styling.
* **Secure & Rated Mirrors:** Automated mirror updating and benchmarking via `pacman-mirrors` (Manjaro), `reflector`, and `cachyos-rate-mirrors` (CachyOS), strictly filtered through a curated country whitelist.
* **Multi-Core AUR Compilation:** Automatically configures `makepkg` to compile packages in parallel across available CPU cores.
* **Modern AUR Helper:** Bootstraps `paru` for fast AUR package management (including Google Cloud CLI tools).

### 🔧 Git & Secrets Hygiene
* **Global Git Ignore (`~/.gitignore.global`):** Automatically ignores sensitive environment files across all projects (e.g., `.envrc.local` and `.env*.local`).
* **Modular Git Config:** Maintains separation between tracked global `.gitconfig` and machine-local `.gitconfig.local`.

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

### Shell Aliases & Shortcuts
* `ls` ➔ `eza --icons --group-directories-first` (Modern directory listing with icons)
* `ll` ➔ `eza --icons --group-directories-first -l --git` (Long format with Git statuses)
* `la` ➔ `eza --icons --group-directories-first -la --git` (Long format including hidden files)
* `lt` ➔ `eza --icons --group-directories-first --tree` (Tree hierarchy view)
* `lta` ➔ `eza --icons --group-directories-first --tree -la` (Complete tree view with hidden files)
* `cat` ➔ `bat --paging=never` (Syntax-highlighted file viewer)
* `glt` ➔ `getlatesttag`
* `Ctrl+R` ➔ Fuzzy search command history (fzf)
* `Ctrl+T` ➔ Fuzzy search files with live syntax preview (fzf + bat)
* `Alt+C` ➔ Fuzzy search and `cd` into subdirectories with tree preview (fzf + eza)

### Git Aliases
* `git last` ➔ Shows the most recent commit log entry.
* `git tl` ➔ Lists repository tags.

---

## 📋 Roadmap / TODO

- [ ] `herdr` and possibly plugins (possibly replacement for `zellij`)
