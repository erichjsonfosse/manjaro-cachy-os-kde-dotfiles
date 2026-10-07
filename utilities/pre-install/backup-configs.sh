#!/usr/bin/env bash

# This script creates backups of existing configurations before the installer modifies them.
# It is designed to work both sourced (inside init.sh) and as a standalone script.
#
# Features:
# - Categorizes backup files into domain directories (git, zsh, ssh, kde, herdr, nano, paru, etc.)
# - Dereferences symlinks to preserve the real file contents as immutable snapshots
# - Generates a machine-readable manifest.json for automated restoration
# - Generates a human-readable manifest.md summary table

# Fallback definitions for standalone execution
if [ -z "$HOMEDIR" ]; then
  HOMEDIR="$HOME"
fi

if [ -z "$LOGNAME" ]; then
  LOGNAME="${USER:-$(id -un)}"
fi

if ! command -v logHeader &>/dev/null; then
  logHeader() { echo "=== $1 ==="; }
  logInfo() { echo "  [i] $1"; }
  logSuccess() { echo "  [✔] $1"; }
  logWarning() { echo "  [!] $1"; }
fi

logHeader "Creating Configuration Backups"

timestamp=$(date +"%Y-%m-%d-%H-%M-%S")
iso_timestamp=$(date -Iseconds 2>/dev/null || date +"%Y-%m-%dT%H:%M:%S%z")
backup_dir="$HOMEDIR/.manjaro-cachy-os-kde-dotfiles-backup/$timestamp"

# Format: category|relative_source_path|backup_subpath|description
config_targets=(
  "git|.gitconfig|git/.gitconfig|Git global configuration"
  "git|.gitconfig.local|git/.gitconfig.local|Git local configuration overrides"
  "git|.gitignore.global|git/.gitignore.global|Git global ignore rules"
  "zsh|.zshrc|zsh/.zshrc|Zsh shell configuration"
  "zsh|.zshrc.local|zsh/.zshrc.local|Zsh local configuration overrides"
  "zsh|.p10k.zsh|zsh/.p10k.zsh|Powerlevel10k theme configuration"
  "ssh|.ssh/config|ssh/config|SSH client configuration"
  "ssh|.config/environment.d/ssh-askpass.conf|ssh/environment.d/ssh-askpass.conf|SSH askpass environment configuration"
  "kde|.config/kwinrc|kde/kwinrc|KWin window manager configuration"
  "kde|.config/kwinrulesrc|kde/kwinrulesrc|KWin window rules"
  "kde|.config/kglobalshortcutsrc|kde/kglobalshortcutsrc|KDE global shortcut definitions"
  "kde|.config/autostart/yakuake.desktop|kde/autostart/yakuake.desktop|Yakuake autostart desktop entry"
  "herdr|.config/herdr/config.toml|herdr/config.toml|Herdr workspace configuration"
  "herdr|.config/herdr/config.local.toml|herdr/config.local.toml|Herdr local workspace overrides"
  "nano|.nanorc|nano/.nanorc|Nano editor configuration"
  "paru|.config/paru/paru.conf|paru/paru.conf|Paru AUR helper configuration"
  "vivaldi|.config/vivaldi/Default/Preferences|vivaldi/Preferences|Vivaldi browser preferences"
  "agents|.gemini/settings.json|agents/settings.json|AI agent settings configuration"
)

total_found=0
regular_files=0
symlinks_dereferenced=0
broken_symlinks=0

# Arrays to collect manifest entries
manifest_categories=()
manifest_rel_paths=()
manifest_backup_paths=()
manifest_was_symlinks=()
manifest_targets=()
manifest_statuses=()
manifest_sizes=()

for target in "${config_targets[@]}"; do
  IFS='|' read -r category rel_path backup_subpath desc <<< "$target"
  src="$HOMEDIR/$rel_path"
  dest="$backup_dir/$backup_subpath"

  if [ -f "$src" ] || [ -L "$src" ]; then
    if [ "$total_found" -eq 0 ]; then
      mkdir -p "$backup_dir"
    fi

    mkdir -p "$(dirname "$dest")"

    if [ -L "$src" ]; then
      symlink_target=$(readlink "$src" || echo "")
      if [ -e "$src" ]; then
        # Valid symlink - dereference content
        cp -L "$src" "$dest"
        was_symlink="true"
        status="dereferenced"
        symlinks_dereferenced=$((symlinks_dereferenced + 1))
        file_size=$(wc -c < "$dest" 2>/dev/null || echo 0)
        file_size=${file_size// /}
        logInfo "Backed up (dereferenced symlink): $rel_path -> $backup_subpath"
      else
        # Broken symlink - preserve pointer or record broken status
        cp -P "$src" "$dest" 2>/dev/null || true
        was_symlink="true"
        status="broken_symlink"
        broken_symlinks=$((broken_symlinks + 1))
        file_size=0
        logWarning "Backed up (broken symlink): $rel_path -> $symlink_target (target missing)"
      fi
    else
      # Regular file
      cp "$src" "$dest"
      was_symlink="false"
      symlink_target=""
      status="copied"
      regular_files=$((regular_files + 1))
      file_size=$(wc -c < "$dest" 2>/dev/null || echo 0)
      file_size=${file_size// /}
      logInfo "Backed up: $rel_path -> $backup_subpath"
    fi

    manifest_categories+=("$category")
    manifest_rel_paths+=("$rel_path")
    manifest_backup_paths+=("$backup_subpath")
    manifest_was_symlinks+=("$was_symlink")
    manifest_targets+=("$symlink_target")
    manifest_statuses+=("$status")
    manifest_sizes+=("$file_size")

    total_found=$((total_found + 1))
  fi
done

if [ "$total_found" -gt 0 ]; then
  # 1. Generate manifest.json
  {
    echo "{"
    echo "  \"version\": \"1.0.0\","
    echo "  \"timestamp\": \"$iso_timestamp\","
    echo "  \"user\": \"$LOGNAME\","
    echo "  \"home\": \"$HOMEDIR\","
    echo "  \"backup_dir\": \"$backup_dir\","
    echo "  \"stats\": {"
    echo "    \"total_found\": $total_found,"
    echo "    \"regular_files\": $regular_files,"
    echo "    \"symlinks_dereferenced\": $symlinks_dereferenced,"
    echo "    \"broken_symlinks\": $broken_symlinks"
    echo "  },"
    echo "  \"entries\": ["
    for ((i=0; i<total_found; i++)); do
      cat_val="${manifest_categories[i]}"
      rel_val="${manifest_rel_paths[i]}"
      bak_val="${manifest_backup_paths[i]}"
      sym_val="${manifest_was_symlinks[i]}"
      tgt_val="${manifest_targets[i]}"
      sta_val="${manifest_statuses[i]}"
      siz_val="${manifest_sizes[i]}"

      comma=","
      if [ "$i" -eq "$((total_found - 1))" ]; then
        comma=""
      fi

      echo "    {"
      echo "      \"category\": \"$cat_val\","
      echo "      \"original_path\": \"$HOMEDIR/$rel_val\","
      echo "      \"relative_path\": \"$rel_val\","
      echo "      \"backup_subpath\": \"$bak_val\","
      echo "      \"was_symlink\": $sym_val,"
      echo "      \"symlink_target\": \"$tgt_val\","
      echo "      \"status\": \"$sta_val\","
      echo "      \"size_bytes\": $siz_val"
      echo "    }$comma"
    done
    echo "  ]"
    echo "}"
  } > "$backup_dir/manifest.json"

  # 2. Generate manifest.md
  {
    echo "# Dotfiles Backup Summary"
    echo ""
    echo "- **Timestamp**: $timestamp"
    echo "- **User**: \`$LOGNAME\`"
    echo "- **Backup Directory**: \`$backup_dir\`"
    echo "- **Total Configurations Backed Up**: $total_found"
    echo "- **Regular Files**: $regular_files"
    echo "- **Symlinks Dereferenced**: $symlinks_dereferenced"
    echo "- **Broken Symlinks**: $broken_symlinks"
    echo ""
    echo "## Backup Inventory"
    echo ""
    echo "| Category | Original Path | Backup Path | Type | Symlink Target | Status |"
    echo "| :--- | :--- | :--- | :--- | :--- | :--- |"
    for ((i=0; i<total_found; i++)); do
      cat_val="${manifest_categories[i]}"
      rel_val="${manifest_rel_paths[i]}"
      bak_val="${manifest_backup_paths[i]}"
      sym_val="${manifest_was_symlinks[i]}"
      tgt_val="${manifest_targets[i]}"
      sta_val="${manifest_statuses[i]}"

      type_str="Regular File"
      target_str="-"
      if [ "$sym_val" = "true" ]; then
        type_str="Symlink"
        target_str="\`$tgt_val\`"
      fi

      status_display="Copied"
      if [ "$sta_val" = "dereferenced" ]; then
        status_display="Dereferenced"
      elif [ "$sta_val" = "broken_symlink" ]; then
        status_display="Broken Symlink"
      fi

      echo "| \`$cat_val\` | \`~/$rel_val\` | \`$bak_val\` | $type_str | $target_str | $status_display |"
    done
  } > "$backup_dir/manifest.md"

  # Maintain correct ownership of backup folder if user exists
  if id "$LOGNAME" &>/dev/null; then
    chown -R "$LOGNAME:$LOGNAME" "$HOMEDIR/.manjaro-cachy-os-kde-dotfiles-backup" 2>/dev/null || true
  fi

  logSuccess "Backups successfully saved to: ${backup_dir#$HOMEDIR/}"
else
  logInfo "No existing configurations found to backup."
fi
