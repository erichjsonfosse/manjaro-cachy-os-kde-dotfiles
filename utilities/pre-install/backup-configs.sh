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
manifest_relative_paths=()
manifest_backup_paths=()
manifest_was_symlinks=()
manifest_symlink_targets=()
manifest_statuses=()
manifest_size_bytes=()

for target in "${config_targets[@]}"; do
  IFS='|' read -r category relative_path backup_subpath _ <<< "$target"
  source_path="$HOMEDIR/$relative_path"
  destination_path="$backup_dir/$backup_subpath"

  if [ -f "$source_path" ] || [ -L "$source_path" ]; then
    if [ "$total_found" -eq 0 ]; then
      mkdir -p "$backup_dir"
    fi

    mkdir -p "$(dirname "$destination_path")"

    if [ -L "$source_path" ]; then
      symlink_target=$(readlink "$source_path" || echo "")
      if [ -e "$source_path" ]; then
        # Valid symlink - dereference content
        cp -L "$source_path" "$destination_path"
        was_symlink="true"
        status="dereferenced"
        symlinks_dereferenced=$((symlinks_dereferenced + 1))
        file_size=$(wc -c < "$destination_path" 2>/dev/null || echo 0)
        file_size=${file_size// /}
        logInfo "Backed up (dereferenced symlink): $relative_path -> $backup_subpath"
      else
        # Broken symlink - preserve pointer or record broken status
        cp -P "$source_path" "$destination_path" 2>/dev/null || true
        was_symlink="true"
        status="broken_symlink"
        broken_symlinks=$((broken_symlinks + 1))
        file_size=0
        logWarning "Backed up (broken symlink): $relative_path -> $symlink_target (target missing)"
      fi
    else
      # Regular file
      cp "$source_path" "$destination_path"
      was_symlink="false"
      symlink_target=""
      status="copied"
      regular_files=$((regular_files + 1))
      file_size=$(wc -c < "$destination_path" 2>/dev/null || echo 0)
      file_size=${file_size// /}
      logInfo "Backed up: $relative_path -> $backup_subpath"
    fi

    manifest_categories+=("$category")
    manifest_relative_paths+=("$relative_path")
    manifest_backup_paths+=("$backup_subpath")
    manifest_was_symlinks+=("$was_symlink")
    manifest_symlink_targets+=("$symlink_target")
    manifest_statuses+=("$status")
    manifest_size_bytes+=("$file_size")

    total_found=$((total_found + 1))
  fi
done

if [ "$total_found" -gt 0 ]; then
  # 1. Generate manifest.json safely
  if command -v jq >/dev/null 2>&1; then
    entries_json=$(
      for ((i=0; i<total_found; i++)); do
        jq -n -c \
          --arg category "${manifest_categories[i]}" \
          --arg original_path "$HOMEDIR/${manifest_relative_paths[i]}" \
          --arg relative_path "${manifest_relative_paths[i]}" \
          --arg backup_subpath "${manifest_backup_paths[i]}" \
          --argjson was_symlink "${manifest_was_symlinks[i]}" \
          --arg symlink_target "${manifest_symlink_targets[i]}" \
          --arg status "${manifest_statuses[i]}" \
          --argjson size_bytes "${manifest_size_bytes[i]}" \
          '{
            category: $category,
            original_path: $original_path,
            relative_path: $relative_path,
            backup_subpath: $backup_subpath,
            was_symlink: $was_symlink,
            symlink_target: $symlink_target,
            status: $status,
            size_bytes: $size_bytes
          }'
      done | jq -s .
    )

    jq -n \
      --arg version "1.0.0" \
      --arg timestamp "$iso_timestamp" \
      --arg user "$LOGNAME" \
      --arg home "$HOMEDIR" \
      --arg backup_dir "$backup_dir" \
      --argjson total_found "$total_found" \
      --argjson regular_files "$regular_files" \
      --argjson symlinks_dereferenced "$symlinks_dereferenced" \
      --argjson broken_symlinks "$broken_symlinks" \
      --argjson entries "$entries_json" \
      '{
        version: $version,
        timestamp: $timestamp,
        user: $user,
        home: $home,
        backup_dir: $backup_dir,
        stats: {
          total_found: $total_found,
          regular_files: $regular_files,
          symlinks_dereferenced: $symlinks_dereferenced,
          broken_symlinks: $broken_symlinks
        },
        entries: $entries
      }' > "$backup_dir/manifest.json"
  else
    json_escape() {
      local string_input="$1"
      string_input="${string_input//\\/\\\\}"
      string_input="${string_input//\"/\\\"}"
      string_input="${string_input//$'\n'/\\n}"
      string_input="${string_input//$'\r'/\\r}"
      string_input="${string_input//$'\t'/\\t}"
      printf '%s' "$string_input"
    }

    {
      echo "{"
      echo "  \"version\": \"1.0.0\","
      echo "  \"timestamp\": \"$iso_timestamp\","
      echo "  \"user\": \"$(json_escape "$LOGNAME")\","
      echo "  \"home\": \"$(json_escape "$HOMEDIR")\","
      echo "  \"backup_dir\": \"$(json_escape "$backup_dir")\","
      echo "  \"stats\": {"
      echo "    \"total_found\": $total_found,"
      echo "    \"regular_files\": $regular_files,"
      echo "    \"symlinks_dereferenced\": $symlinks_dereferenced,"
      echo "    \"broken_symlinks\": $broken_symlinks"
      echo "  },"
      echo "  \"entries\": ["
      for ((i=0; i<total_found; i++)); do
        category_value="${manifest_categories[i]}"
        relative_path_value="${manifest_relative_paths[i]}"
        backup_subpath_value="${manifest_backup_paths[i]}"
        was_symlink_value="${manifest_was_symlinks[i]}"
        target_value="${manifest_symlink_targets[i]}"
        status_value="${manifest_statuses[i]}"
        size_bytes_value="${manifest_size_bytes[i]}"

        comma=","
        if [ "$i" -eq "$((total_found - 1))" ]; then
          comma=""
        fi

        echo "    {"
        echo "      \"category\": \"$(json_escape "$category_value")\","
        echo "      \"original_path\": \"$(json_escape "$HOMEDIR/$relative_path_value")\","
        echo "      \"relative_path\": \"$(json_escape "$relative_path_value")\","
        echo "      \"backup_subpath\": \"$(json_escape "$backup_subpath_value")\","
        echo "      \"was_symlink\": $was_symlink_value,"
        echo "      \"symlink_target\": \"$(json_escape "$target_value")\","
        echo "      \"status\": \"$(json_escape "$status_value")\","
        echo "      \"size_bytes\": $size_bytes_value"
        echo "    }$comma"
      done
      echo "  ]"
      echo "}"
    } > "$backup_dir/manifest.json"
  fi

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
      category_value="${manifest_categories[i]}"
      relative_path_value="${manifest_relative_paths[i]}"
      backup_path_value="${manifest_backup_paths[i]}"
      was_symlink_value="${manifest_was_symlinks[i]}"
      symlink_target_value="${manifest_symlink_targets[i]}"
      status_value="${manifest_statuses[i]}"

      type_string="Regular File"
      target_string="-"
      if [ "$was_symlink_value" = "true" ]; then
        type_string="Symlink"
        target_string="\`$symlink_target_value\`"
      fi

      status_display="Copied"
      if [ "$status_value" = "dereferenced" ]; then
        status_display="Dereferenced"
      elif [ "$status_value" = "broken_symlink" ]; then
        status_display="Broken Symlink"
      fi

      echo "| \`$category_value\` | \`~/$relative_path_value\` | \`$backup_path_value\` | $type_string | $target_string | $status_display |"
    done
  } > "$backup_dir/manifest.md"

  # Maintain correct ownership of backup folder if user exists
  if id "$LOGNAME" &>/dev/null; then
    chown -R "$LOGNAME:$LOGNAME" "$HOMEDIR/.manjaro-cachy-os-kde-dotfiles-backup" 2>/dev/null || true
  fi

  logSuccess "Backups successfully saved to: ${backup_dir#"$HOMEDIR"/}"
else
  logInfo "No existing configurations found to backup."
fi
