#!/usr/bin/env bash
set -eo pipefail

TEST_TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TEST_TMPDIR"' EXIT

if [ -n "${ZSH_VERSION:-}" ]; then
  # shellcheck disable=SC2296
  SCRIPT_PATH="${(%):-%x}"
else
  SCRIPT_PATH="${BASH_SOURCE[0]}"
fi
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"
SOURCE_SCRIPT="$SCRIPT_DIR/../config/zsh/plugins/manjaro-cachy-os-kde-dotfiles/direnv.zsh"
# shellcheck disable=SC1090
source "$SOURCE_SCRIPT"

echo "=== Test 1: Create new .envrc and .envrc.example when absent ==="
(
  cd "$TEST_TMPDIR"
  _direnv_gcp_upsert_block ".envrc" "test-proj-1" "europe-west1"
  _direnv_gcp_upsert_block ".envrc.example" "your-gcp-project-id" "europe-west1"

  grep -q 'export GOOGLE_CLOUD_PROJECT="test-proj-1"' .envrc || { echo "FAIL: GOOGLE_CLOUD_PROJECT not found in .envrc"; exit 1; }
  grep -q 'export CLOUDSDK_CORE_PROJECT="test-proj-1"' .envrc || { echo "FAIL: CLOUDSDK_CORE_PROJECT not found in .envrc"; exit 1; }
  grep -q 'export GOOGLE_CLOUD_QUOTA_PROJECT="test-proj-1"' .envrc || { echo "FAIL: GOOGLE_CLOUD_QUOTA_PROJECT not found in .envrc"; exit 1; }
  grep -q 'export GOOGLE_VERTEX_LOCATION="europe-west1"' .envrc || { echo "FAIL: GOOGLE_VERTEX_LOCATION not found in .envrc"; exit 1; }
  grep -q 'export GEMINI_LOCATION="europe-west1"' .envrc || { echo "FAIL: GEMINI_LOCATION not found in .envrc"; exit 1; }

  grep -q 'export GOOGLE_CLOUD_PROJECT="your-gcp-project-id"' .envrc.example || { echo "FAIL: GOOGLE_CLOUD_PROJECT not found in .envrc.example"; exit 1; }
  echo "PASS: New files created with expected variables."
)

echo "=== Test 2: In-place update of managed block preserves surrounding content ==="
(
  cd "$TEST_TMPDIR"
  cat << 'EOF' > .envrc
# Pre-existing header
export CUSTOM_VAR="keep_me"

# --- BEGIN GCP DIRENV CONFIG ---
export GOOGLE_CLOUD_PROJECT="old-proj"
# --- END GCP DIRENV CONFIG ---

# Post-existing footer
export ANOTHER_VAR="keep_me_too"
EOF

  _direnv_gcp_upsert_block ".envrc" "updated-proj" "us-central1"

  grep -q 'export CUSTOM_VAR="keep_me"' .envrc || { echo "FAIL: Pre-existing header clobbered"; exit 1; }
  grep -q 'export ANOTHER_VAR="keep_me_too"' .envrc || { echo "FAIL: Post-existing footer clobbered"; exit 1; }
  grep -q 'export GOOGLE_CLOUD_PROJECT="updated-proj"' .envrc || { echo "FAIL: Did not update project ID in .envrc"; exit 1; }
  grep -q 'export GOOGLE_VERTEX_LOCATION="us-central1"' .envrc || { echo "FAIL: Did not update location in .envrc"; exit 1; }
  ! grep -q 'old-proj' .envrc || { echo "FAIL: Old project still present in .envrc"; exit 1; }
  echo "PASS: Preserved surrounding content and cleanly replaced block."
)

echo "All Task 1 tests passed!"

echo "=== Test 3: setupDirenvForGoogleCloudProject updates gitignore in git repo ==="
(
  cd "$TEST_TMPDIR"
  git init -q
  setupDirenvForGoogleCloudProject "my-test-repo-project" "europe-west1"

  grep -q '^\.envrc$' .gitignore || { echo "FAIL: .envrc not added to .gitignore"; exit 1; }
  git check-ignore -q .envrc || { echo "FAIL: .envrc is not ignored by git"; exit 1; }
  ! git check-ignore -q .envrc.example || { echo "FAIL: .envrc.example should not be ignored"; exit 1; }
  echo "PASS: Gitignore properly configured."
)

echo "=== Test 4: Aliases setup-gcp-direnv and direnv-gcp invoke setupDirenvForGoogleCloudProject ==="
(
  shopt -s expand_aliases 2>/dev/null || true
  alias setup-gcp-direnv &>/dev/null || type setup-gcp-direnv &>/dev/null || { echo "FAIL: setup-gcp-direnv alias missing"; exit 1; }
  alias direnv-gcp &>/dev/null || type direnv-gcp &>/dev/null || { echo "FAIL: direnv-gcp alias missing"; exit 1; }
  echo "PASS: Aliases exist."
)

echo "All Task 2 tests passed!"
