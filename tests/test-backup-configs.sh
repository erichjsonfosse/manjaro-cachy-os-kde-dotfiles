#!/usr/bin/env bash
set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASEDIR="$(cd "$SCRIPT_DIR/.." && pwd)"

TEST_TEMP_DIR=$(mktemp -d /tmp/test-dotfiles-backup-XXXXXX)
trap 'rm -rf "$TEST_TEMP_DIR"' EXIT

export HOMEDIR="$TEST_TEMP_DIR/home/testuser"
export LOGNAME="testuser"
mkdir -p "$HOMEDIR"

# Mock logger functions
logHeader() { echo "=== $1 ==="; }
logInfo() { echo "  [i] $1"; }
logSuccess() { echo "  [✔] $1"; }
logWarning() { echo "  [!] $1"; }
export -f logHeader logInfo logSuccess logWarning

echo "--- Test 1: No existing configs to backup ---"
output=$(bash "$BASEDIR/utilities/pre-install/backup-configs.sh" 2>&1)
if ! echo "$output" | grep -q "No existing configurations found to backup"; then
  echo "FAIL: Expected 'No existing configurations found to backup', got: $output"
  exit 1
fi
if [ -d "$HOMEDIR/.manjaro-cachy-os-kde-dotfiles-backup" ]; then
  echo "FAIL: Backup directory should not be created when no files exist"
  exit 1
fi
echo "PASS: Empty config scenario handled correctly"

echo "--- Test 2: Backup regular files, symlinks, and nested configs ---"
# Setup mock environment
mkdir -p "$HOMEDIR/.config/herdr"
mkdir -p "$HOMEDIR/.config/environment.d"
mkdir -p "$HOMEDIR/.config/autostart"
mkdir -p "$HOMEDIR/.config/paru"
mkdir -p "$HOMEDIR/.ssh"
mkdir -p "$HOMEDIR/.gemini"
mkdir -p "$TEST_TEMP_DIR/external_repo"

echo "gitconfig-content" > "$HOMEDIR/.gitconfig"
echo "gitconfig-local-content" > "$HOMEDIR/.gitconfig.local"
echo "zshrc-content" > "$HOMEDIR/.zshrc"
echo "herdr-content" > "$HOMEDIR/.config/herdr/config.toml"
echo "ssh-askpass-content" > "$HOMEDIR/.config/environment.d/ssh-askpass.conf"
echo "gemini-settings-content" > "$HOMEDIR/.gemini/settings.json"
echo "yakuake-autostart-content" > "$HOMEDIR/.config/autostart/yakuake.desktop"

# Create valid symlink
echo "real-kwinrc-content" > "$TEST_TEMP_DIR/external_repo/kwinrc"
ln -s "$TEST_TEMP_DIR/external_repo/kwinrc" "$HOMEDIR/.config/kwinrc"

# Create broken symlink with quotes and backslash to verify JSON escaping
ln -s "$TEST_TEMP_DIR/external_repo/nonexistent_\"target\"_with_\\backslash.nanorc" "$HOMEDIR/.nanorc"

# Run backup script
bash "$BASEDIR/utilities/pre-install/backup-configs.sh"

BACKUP_ROOT="$HOMEDIR/.manjaro-cachy-os-kde-dotfiles-backup"
if [ ! -d "$BACKUP_ROOT" ]; then
  echo "FAIL: Backup root directory was not created"
  exit 1
fi

LATEST_BACKUP=$(find "$BACKUP_ROOT" -mindepth 1 -maxdepth 1 -type d | sort | tail -n 1)
if [ -z "$LATEST_BACKUP" ]; then
  echo "FAIL: No timestamped backup directory found"
  exit 1
fi

echo "Verifying backup directory: $LATEST_BACKUP"

# 1. Categorization check
if [ ! -f "$LATEST_BACKUP/git/.gitconfig" ]; then
  echo "FAIL: git/.gitconfig not found in categorized backup"
  exit 1
fi
if [ ! -f "$LATEST_BACKUP/git/.gitconfig.local" ]; then
  echo "FAIL: git/.gitconfig.local not found in categorized backup"
  exit 1
fi
if [ ! -f "$LATEST_BACKUP/zsh/.zshrc" ]; then
  echo "FAIL: zsh/.zshrc not found in categorized backup"
  exit 1
fi
if [ ! -f "$LATEST_BACKUP/herdr/config.toml" ]; then
  echo "FAIL: herdr/config.toml not found in categorized backup"
  exit 1
fi
if [ ! -f "$LATEST_BACKUP/ssh/environment.d/ssh-askpass.conf" ]; then
  echo "FAIL: ssh/environment.d/ssh-askpass.conf not found in categorized backup"
  exit 1
fi
if [ ! -f "$LATEST_BACKUP/kde/autostart/yakuake.desktop" ]; then
  echo "FAIL: kde/autostart/yakuake.desktop not found in categorized backup"
  exit 1
fi
if [ ! -f "$LATEST_BACKUP/agents/settings.json" ]; then
  echo "FAIL: agents/settings.json not found in categorized backup"
  exit 1
fi

# 2. Symlink dereferencing check
if [ -L "$LATEST_BACKUP/kde/kwinrc" ]; then
  echo "FAIL: kde/kwinrc should be a dereferenced regular file, not a symlink"
  exit 1
fi
if [ ! -f "$LATEST_BACKUP/kde/kwinrc" ]; then
  echo "FAIL: kde/kwinrc regular file does not exist"
  exit 1
fi
content=$(cat "$LATEST_BACKUP/kde/kwinrc")
if [ "$content" != "real-kwinrc-content" ]; then
  echo "FAIL: kde/kwinrc content mismatch, got: $content"
  exit 1
fi

# 3. Manifest checks
if [ ! -f "$LATEST_BACKUP/manifest.json" ]; then
  echo "FAIL: manifest.json not found"
  exit 1
fi
if [ ! -f "$LATEST_BACKUP/manifest.md" ]; then
  echo "FAIL: manifest.md not found"
  exit 1
fi

# Validate manifest.json is valid JSON with expected properties
python3 -c "
import json
with open('$LATEST_BACKUP/manifest.json') as f:
    data = json.load(f)

assert data.get('version') == '1.0.0', 'Invalid manifest version'
assert data['stats']['total_found'] >= 7, f'Unexpected total_found: {data[\"stats\"][\"total_found\"]}'
assert data['stats']['symlinks_dereferenced'] == 1, f'Unexpected symlinks_dereferenced: {data[\"stats\"][\"symlinks_dereferenced\"]}'
assert data['stats']['broken_symlinks'] == 1, f'Unexpected broken_symlinks: {data[\"stats\"][\"broken_symlinks\"]}'
assert len(data['entries']) >= 7, f'Unexpected entries length: {len(data[\"entries\"])}'

# Check entries for symlink and broken symlink details
symlink_entry = next((e for e in data['entries'] if e['relative_path'] == '.config/kwinrc'), None)
assert symlink_entry is not None, '.config/kwinrc entry missing'
assert symlink_entry['was_symlink'] is True, '.config/kwinrc was_symlink should be True'
assert symlink_entry['status'] == 'dereferenced', f'Expected dereferenced status, got {symlink_entry[\"status\"]}'
assert 'kwinrc' in symlink_entry['symlink_target'], 'symlink_target mismatch'

broken_entry = next((e for e in data['entries'] if e['relative_path'] == '.nanorc'), None)
assert broken_entry is not None, '.nanorc entry missing'
assert broken_entry['was_symlink'] is True, '.nanorc was_symlink should be True'
assert '\"target\"' in broken_entry['symlink_target'], 'symlink_target quote escaping mismatch'
assert r'\\backslash' in broken_entry['symlink_target'], 'symlink_target backslash escaping mismatch'
"
echo "PASS: manifest.json schema and data validation passed"

# Validate manifest.md contains table and summary
if ! grep -q "| Category | Original Path | Backup Path | Type | Symlink Target | Status |" "$LATEST_BACKUP/manifest.md"; then
  echo "FAIL: manifest.md missing markdown table headers"
  exit 1
fi
if ! grep -q "Total Configurations Backed Up" "$LATEST_BACKUP/manifest.md"; then
  echo "FAIL: manifest.md missing summary header"
  exit 1
fi
echo "PASS: manifest.md structure validation passed"

echo "--- Test 3: Sourced execution test ---"
# Test when sourced from another script (like init.sh)
sourced_output=$(bash -c "
  export HOMEDIR='$HOMEDIR'
  export LOGNAME='$LOGNAME'
  source '$BASEDIR/utilities/pre-install/backup-configs.sh'
" 2>&1)

if ! echo "$sourced_output" | grep -q "Backups successfully saved to"; then
  echo "FAIL: Sourced execution failed, output: $sourced_output"
  exit 1
fi
echo "PASS: Sourced execution succeeded"

echo "=========================================="
echo "ALL STRUCTURED BACKUP TESTS PASSED!"
echo "=========================================="
