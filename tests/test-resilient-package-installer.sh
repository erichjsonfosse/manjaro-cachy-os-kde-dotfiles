#!/usr/bin/env bash
set -eo pipefail

TEST_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BASEDIR="$(cd "$TEST_DIR/.." && pwd)"

# Set up test environment
export BASEDIR
export FAILED_PACKAGES_LOG="$BASEDIR/scratch-test-failed-packages.log"
rm -f "$FAILED_PACKAGES_LOG"

# Source utilities
source "$BASEDIR/utilities/during-install/utilities.sh"

echo "=== Testing installPackagesResiliently ==="

# Mock state
declare -a MOCK_FAIL_PKGS=()
declare -a MOCK_CALLED_ARGS=()

waitForPacmanLock() {
  # Mock no-op during unit test
  return 0
}

mock_pacman() {
  local mock_target arg
  MOCK_CALLED_ARGS+=("pacman: $*")
  for mock_target in "${MOCK_FAIL_PKGS[@]}"; do
    for arg in "$@"; do
      if [ "$arg" = "$mock_target" ]; then
        return 1
      fi
    done
  done
  return 0
}

mock_paru() {
  local mock_target arg
  MOCK_CALLED_ARGS+=("paru: $*")
  for mock_target in "${MOCK_FAIL_PKGS[@]}"; do
    for arg in "$@"; do
      if [ "$arg" = "$mock_target" ]; then
        return 1
      fi
    done
  done
  return 0
}

sudo() {
  if [ "$1" = "pacman" ]; then
    shift
    mock_pacman "$@"
  else
    command sudo "$@"
  fi
}

paru() {
  mock_paru "$@"
}

# Test 1: Empty package list
echo "Test 1: Empty package list..."
installPackagesResiliently "pacman" || { echo "FAIL: Test 1 failed"; exit 1; }
[ ! -f "$FAILED_PACKAGES_LOG" ] || { echo "FAIL: Log should not exist for empty list"; exit 1; }
echo "  ✔ Test 1 passed"

# Test 2: Batch success
echo "Test 2: Batch success..."
MOCK_FAIL_PKGS=()
MOCK_CALLED_ARGS=()
installPackagesResiliently "pacman" "pkg1" "pkg2" "pkg3" || { echo "FAIL: Test 2 failed"; exit 1; }
[ ! -f "$FAILED_PACKAGES_LOG" ] || { echo "FAIL: Log should not exist on batch success"; exit 1; }
[ "${#MOCK_CALLED_ARGS[@]}" -eq 1 ] || { echo "FAIL: Expected exactly 1 batch call, got ${#MOCK_CALLED_ARGS[@]}"; exit 1; }
echo "  ✔ Test 2 passed"

# Test 3: Pacman batch failure with individual fallback
echo "Test 3: Pacman batch failure with fallback..."
MOCK_FAIL_PKGS=("broken-pkg")
MOCK_CALLED_ARGS=()
rm -f "$FAILED_PACKAGES_LOG"
installPackagesResiliently "pacman" "good-pkg-1" "broken-pkg" "good-pkg-2" || { echo "FAIL: Test 3 should return exit code 0"; exit 1; }

[ -f "$FAILED_PACKAGES_LOG" ] || { echo "FAIL: Failed packages log was not created"; exit 1; }
grep -q "\[pacman\] broken-pkg" "$FAILED_PACKAGES_LOG" || { echo "FAIL: broken-pkg not found in log"; exit 1; }
! grep -q "good-pkg" "$FAILED_PACKAGES_LOG" || { echo "FAIL: good packages should not be in failure log"; exit 1; }
# Total calls should be 1 batch + 3 individual = 4
[ "${#MOCK_CALLED_ARGS[@]}" -eq 4 ] || { echo "FAIL: Expected 4 calls (1 batch + 3 individual), got ${#MOCK_CALLED_ARGS[@]}"; exit 1; }
echo "  ✔ Test 3 passed"

# Test 4: Paru batch failure with fallback
echo "Test 4: Paru batch failure with fallback..."
MOCK_FAIL_PKGS=("aur-broken")
MOCK_CALLED_ARGS=()
installPackagesResiliently "paru" "aur-good" "aur-broken" || { echo "FAIL: Test 4 should return exit code 0"; exit 1; }

grep -q "\[paru\] aur-broken" "$FAILED_PACKAGES_LOG" || { echo "FAIL: aur-broken not found in log"; exit 1; }
# Total calls: 1 batch + 2 individual = 3
[ "${#MOCK_CALLED_ARGS[@]}" -eq 3 ] || { echo "FAIL: Expected 3 calls (1 batch + 2 individual), got ${#MOCK_CALLED_ARGS[@]}"; exit 1; }
echo "  ✔ Test 4 passed"

# Cleanup
rm -f "$FAILED_PACKAGES_LOG"
echo "All installPackagesResiliently tests passed successfully!"
