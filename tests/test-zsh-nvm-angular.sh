#!/usr/bin/env bash
set -eo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASEDIR="$(cd "$SCRIPT_DIR/.." && pwd)"

TEST_TEMP_DIR=$(mktemp -d /tmp/test-zsh-nvm-angular-XXXXXX)
trap 'rm -rf "$TEST_TEMP_DIR"' EXIT

export HOMEDIR="$TEST_TEMP_DIR/home/testuser"
export LOGNAME="testuser"
mkdir -p "$HOMEDIR"

echo "=== Running Zsh NVM & Angular Autocompletion Test Suite ==="

echo "--- Test 1: Arch NVM symlinks creation in \$HOMEDIR/.nvm ---"
ARCH_DIR="$TEST_TEMP_DIR/usr/share/nvm"
mkdir -p "$ARCH_DIR"
touch "$ARCH_DIR/nvm.sh" "$ARCH_DIR/nvm-exec" "$ARCH_DIR/bash_completion"
export ARCH_NVM_DIR="$ARCH_DIR"

# Run the symlink logic snippet
if [ -f "$ARCH_NVM_DIR/nvm.sh" ]; then
  mkdir -p "$HOMEDIR/.nvm"
  [ ! -e "$HOMEDIR/.nvm/nvm.sh" ] && ln -sf "$ARCH_NVM_DIR/nvm.sh" "$HOMEDIR/.nvm/nvm.sh"
  [ ! -e "$HOMEDIR/.nvm/nvm-exec" ] && ln -sf "$ARCH_NVM_DIR/nvm-exec" "$HOMEDIR/.nvm/nvm-exec"
  if [ -f "$ARCH_NVM_DIR/bash_completion" ] && [ ! -e "$HOMEDIR/.nvm/bash_completion" ]; then
    ln -sf "$ARCH_NVM_DIR/bash_completion" "$HOMEDIR/.nvm/bash_completion"
  fi
fi

# Verify symlinks
if [ ! -L "$HOMEDIR/.nvm/nvm.sh" ] || [ "$(readlink "$HOMEDIR/.nvm/nvm.sh")" != "$ARCH_DIR/nvm.sh" ]; then
  echo "FAIL: nvm.sh symlink incorrect or missing"
  exit 1
fi
if [ ! -L "$HOMEDIR/.nvm/nvm-exec" ] || [ "$(readlink "$HOMEDIR/.nvm/nvm-exec")" != "$ARCH_DIR/nvm-exec" ]; then
  echo "FAIL: nvm-exec symlink incorrect or missing"
  exit 1
fi
if [ ! -L "$HOMEDIR/.nvm/bash_completion" ] || [ "$(readlink "$HOMEDIR/.nvm/bash_completion")" != "$ARCH_DIR/bash_completion" ]; then
  echo "FAIL: bash_completion symlink incorrect or missing"
  exit 1
fi

# Idempotency check: run again and ensure no errors or broken links
if [ -f "$ARCH_NVM_DIR/nvm.sh" ]; then
  mkdir -p "$HOMEDIR/.nvm"
  [ ! -e "$HOMEDIR/.nvm/nvm.sh" ] && ln -sf "$ARCH_NVM_DIR/nvm.sh" "$HOMEDIR/.nvm/nvm.sh"
  [ ! -e "$HOMEDIR/.nvm/nvm-exec" ] && ln -sf "$ARCH_NVM_DIR/nvm-exec" "$HOMEDIR/.nvm/nvm-exec"
  if [ -f "$ARCH_NVM_DIR/bash_completion" ] && [ ! -e "$HOMEDIR/.nvm/bash_completion" ]; then
    ln -sf "$ARCH_NVM_DIR/bash_completion" "$HOMEDIR/.nvm/bash_completion"
  fi
fi
if [ ! -L "$HOMEDIR/.nvm/nvm.sh" ]; then
  echo "FAIL: Idempotency check failed for nvm.sh"
  exit 1
fi
echo "PASS: Arch NVM symlinks created and verified idempotent"

echo "--- Test 2: OMZ NVM lazy-loading zstyle injection and idempotency ---"
ZSHRC_TEST="$TEST_TEMP_DIR/test_zshrc"
cat << 'EOF' > "$ZSHRC_TEST"
# Some top comments
# Which plugins would you like to load?
plugins=(git)
EOF

apply_zstyle() {
  local ZSHRC_FILE="$1"
  if ! grep -q ":omz:plugins:nvm" "$ZSHRC_FILE"; then
    if grep -q '^# Which plugins would you like to load?' "$ZSHRC_FILE"; then
      sed -i '/^# Which plugins would you like to load?/i # NVM Plugin Settings\nzstyle ":omz:plugins:nvm" lazy yes\nzstyle ":omz:plugins:nvm" autoload yes\nzstyle ":omz:plugins:nvm" lazy-cmd ng\n' "$ZSHRC_FILE"
    elif grep -q '^plugins=' "$ZSHRC_FILE"; then
      sed -i '/^plugins=/i # NVM Plugin Settings\nzstyle ":omz:plugins:nvm" lazy yes\nzstyle ":omz:plugins:nvm" autoload yes\nzstyle ":omz:plugins:nvm" lazy-cmd ng\n' "$ZSHRC_FILE"
    else
      printf '# NVM Plugin Settings\nzstyle ":omz:plugins:nvm" lazy yes\nzstyle ":omz:plugins:nvm" autoload yes\nzstyle ":omz:plugins:nvm" lazy-cmd ng\n\n' >> "$ZSHRC_FILE"
    fi
  fi
}

apply_zstyle "$ZSHRC_TEST"

# Verify zstyle directives are before plugins
if ! grep -q 'zstyle ":omz:plugins:nvm" lazy yes' "$ZSHRC_TEST"; then
  echo "FAIL: zstyle lazy yes missing"
  exit 1
fi
if ! grep -q 'zstyle ":omz:plugins:nvm" autoload yes' "$ZSHRC_TEST"; then
  echo "FAIL: zstyle autoload yes missing"
  exit 1
fi
if ! grep -q 'zstyle ":omz:plugins:nvm" lazy-cmd ng' "$ZSHRC_TEST"; then
  echo "FAIL: zstyle lazy-cmd ng missing"
  exit 1
fi

pos_zstyle=$(grep -n 'zstyle ":omz:plugins:nvm"' "$ZSHRC_TEST" | head -n1 | cut -d: -f1)
pos_plugins=$(grep -n 'plugins=' "$ZSHRC_TEST" | head -n1 | cut -d: -f1)
if [ "$pos_zstyle" -ge "$pos_plugins" ]; then
  echo "FAIL: zstyle directives must appear before plugins= line"
  exit 1
fi

# Test idempotency (run second time)
apply_zstyle "$ZSHRC_TEST"
count=$(grep -c 'zstyle ":omz:plugins:nvm" lazy yes' "$ZSHRC_TEST")
if [ "$count" -ne 1 ]; then
  echo "FAIL: Idempotency failed, expected 1 occurrence of zstyle, found $count"
  exit 1
fi

# Test fallback scenario (plugins= without header comment)
ZSHRC_TEST_FALLBACK="$TEST_TEMP_DIR/test_zshrc_fallback"
echo "plugins=(git)" > "$ZSHRC_TEST_FALLBACK"
apply_zstyle "$ZSHRC_TEST_FALLBACK"
pos_zstyle_fb=$(grep -n 'zstyle ":omz:plugins:nvm"' "$ZSHRC_TEST_FALLBACK" | head -n1 | cut -d: -f1)
pos_plugins_fb=$(grep -n 'plugins=' "$ZSHRC_TEST_FALLBACK" | head -n1 | cut -d: -f1)
if [ "$pos_zstyle_fb" -ge "$pos_plugins_fb" ]; then
  echo "FAIL: Fallback zstyle directives must appear before plugins= line"
  exit 1
fi
echo "PASS: OMZ NVM lazy-loading zstyle injection and idempotency verified"

echo "--- Test 3: angular.zsh registration and graceful degradation without ng ---"
zsh_output=$(zsh -f -c '
  compdef() {
    compdef_target="$1"
    compdef_cmd="$2"
  }
  source "'"$BASEDIR"'/config/zsh/plugins/manjaro-cachy-os-kde-dotfiles/angular.zsh"
  if [[ "$compdef_target" != "_ng_lazy_complete" || "$compdef_cmd" != "ng" ]]; then
    echo "compdef registration failed: $compdef_target for $compdef_cmd"
    exit 1
  fi
  # Execute lazy completion when ng does not exist
  _ng_lazy_complete
  echo "OK"
')
if [ "$zsh_output" != "OK" ]; then
  echo "FAIL: angular.zsh failed when ng is absent: $zsh_output"
  exit 1
fi
echo "PASS: angular.zsh successfully registered and handles missing ng gracefully"

echo "--- Test 4: angular.zsh triggers _omz_nvm_load and delegates to ng completion ---"
zsh_output=$(zsh -f -c '
  typeset -g nvm_loaded=0
  typeset -g compdef_deleted=""
  typeset -g ng_completion_invoked=0
  typeset -g ng_completion_args=""

  compdef() {
    if [[ "$1" == "-d" ]]; then
      compdef_deleted="$2"
    fi
  }

  _omz_nvm_load() {
    nvm_loaded=1
    # Mock ng command becoming available after NVM load
    ng() {
      if [[ "$1" == "completion" && "$2" == "script" ]]; then
        echo "_ng() { ng_completion_invoked=1; ng_completion_args=\"\$*\"; }"
      fi
    }
  }

  source "'"$BASEDIR"'/config/zsh/plugins/manjaro-cachy-os-kde-dotfiles/angular.zsh"

  # Invoke completion
  _ng_lazy_complete test_arg1 test_arg2

  if [[ "$nvm_loaded" -ne 1 ]]; then
    echo "FAIL: _omz_nvm_load was not called"
    exit 1
  fi

  if [[ "$compdef_deleted" != "ng" ]]; then
    echo "FAIL: compdef -d ng was not called"
    exit 1
  fi

  if [[ "$ng_completion_invoked" -ne 1 ]]; then
    echo "FAIL: official _ng completion function was not invoked"
    exit 1
  fi

  if [[ "$ng_completion_args" != "test_arg1 test_arg2" ]]; then
    echo "FAIL: completion args were not passed correctly: $ng_completion_args"
    exit 1
  fi

  echo "OK"
')
if [ "$zsh_output" != "OK" ]; then
  echo "FAIL: Test 4 failed: $zsh_output"
  exit 1
fi
echo "PASS: angular.zsh successfully loads NVM, swaps compdef, and executes completion"

echo "--- Test 5: Full dotfiles plugin loader integration ---"
zsh_output=$(zsh -f -c '
  compdef() { :; }
  source "'"$BASEDIR"'/config/zsh/plugins/manjaro-cachy-os-kde-dotfiles/manjaro-cachy-os-kde-dotfiles.plugin.zsh"
  if whence -f _ng_lazy_complete >/dev/null; then
    echo "OK"
  else
    echo "FAIL: _ng_lazy_complete not defined after loading plugin"
    exit 1
  fi
')
if [ "$zsh_output" != "OK" ]; then
  echo "FAIL: Dotfiles plugin loader integration failed: $zsh_output"
  exit 1
fi
echo "PASS: Full dotfiles plugin loader sourced angular.zsh cleanly"

echo "=========================================================="
echo "ALL ZSH NVM & ANGULAR AUTOCOMPLETION TESTS PASSED!"
echo "=========================================================="
