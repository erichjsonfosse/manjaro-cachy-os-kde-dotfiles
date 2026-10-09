#!/usr/bin/env bash
set -eo pipefail

TEST_TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TEST_TMPDIR"' EXIT

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_AGY="$SCRIPT_DIR/../bin/agy"

# Source bin/agy for function testing
# shellcheck source=../bin/agy disable=SC1091
source "$BIN_AGY"

MOCK_ORIG_HOME="$TEST_TMPDIR/orig_home"
MOCK_PROFILE_DIR="$TEST_TMPDIR/profile_dir"
mkdir -p "$MOCK_ORIG_HOME/.gemini/antigravity-cli" \
         "$MOCK_ORIG_HOME/.config/gcloud" \
         "$MOCK_PROFILE_DIR/.gemini/antigravity-cli" \
         "$MOCK_PROFILE_DIR/.config"

GLOBAL_SETTINGS="$MOCK_ORIG_HOME/.gemini/antigravity-cli/settings.json"
PROF_SETTINGS="$MOCK_PROFILE_DIR/.gemini/antigravity-cli/settings.json"

cat << 'EOF' > "$GLOBAL_SETTINGS"
{
  "colorScheme": "tokyo night",
  "editor": "nano",
  "gcp": {
    "project": "global-project-123",
    "location": "us-central1"
  },
  "permissions": {
    "allow": [
      "command(cat)",
      "command(git)",
      "command(ls)"
    ]
  }
}
EOF

echo "=== Test 1: Symlink breaking & independent profile settings ==="
(
  # Initially create a symlink pointing to global
  ln -sf "$GLOBAL_SETTINGS" "$PROF_SETTINGS"
  [[ -L "$PROF_SETTINGS" ]] || { echo "FAIL: Setup symlink not created"; exit 1; }

  ensure_profile_settings "$GLOBAL_SETTINGS" "$PROF_SETTINGS"

  [[ -f "$PROF_SETTINGS" ]] || { echo "FAIL: Profile settings is not a file"; exit 1; }
  [[ ! -L "$PROF_SETTINGS" ]] || { echo "FAIL: Profile settings is still a symlink"; exit 1; }
  echo "PASS: Successfully converted symlink to independent regular file."
)

echo "=== Test 2: Startup sync merges permissions without clobbering profile GCP project ==="
(
  cat << 'EOF' > "$PROF_SETTINGS"
{
  "gcp": {
    "project": "profile-custom-project",
    "location": "europe-west1"
  },
  "permissions": {
    "allow": [
      "command(grep)"
    ]
  }
}
EOF

  sync_permissions_to_profile "$GLOBAL_SETTINGS" "$PROF_SETTINGS"

  # Check permissions merged:
  grep -q '"command(cat)"' "$PROF_SETTINGS" || { echo "FAIL: command(cat) not synced from global"; exit 1; }
  grep -q '"command(git)"' "$PROF_SETTINGS" || { echo "FAIL: command(git) not synced from global"; exit 1; }
  grep -q '"command(grep)"' "$PROF_SETTINGS" || { echo "FAIL: command(grep) lost in profile"; exit 1; }

  # Check GCP project NOT clobbered:
  grep -q '"project": "profile-custom-project"' "$PROF_SETTINGS" || { echo "FAIL: Profile GCP project was clobbered by global"; exit 1; }
  grep -q '"location": "europe-west1"' "$PROF_SETTINGS" || { echo "FAIL: Profile GCP location was clobbered by global"; exit 1; }
  echo "PASS: Permissions merged while preserving profile GCP project and location."
)

echo "=== Test 3: Exit sync merges new profile permissions back to global ==="
(
  # Add new command to profile
  cat << 'EOF' > "$PROF_SETTINGS"
{
  "gcp": {
    "project": "profile-custom-project",
    "location": "europe-west1"
  },
  "permissions": {
    "allow": [
      "command(cat)",
      "command(git)",
      "command(grep)",
      "command(ls)",
      "command(make)"
    ]
  }
}
EOF

  sync_permissions_to_global "$GLOBAL_SETTINGS" "$PROF_SETTINGS"

  grep -q '"command(make)"' "$GLOBAL_SETTINGS" || { echo "FAIL: command(make) not synced back to global"; exit 1; }
  grep -q '"project": "global-project-123"' "$GLOBAL_SETTINGS" || { echo "FAIL: Global project clobbered by profile exit sync"; exit 1; }
  echo "PASS: Newly approved permissions written back to global without touching global GCP project."
)

echo "=== Test 4: Export profile GCP environment variables ==="
(
  export_profile_gcp_env "$PROF_SETTINGS"

  [[ "$CLOUDSDK_CORE_PROJECT" == "profile-custom-project" ]] || { echo "FAIL: CLOUDSDK_CORE_PROJECT mismatch: $CLOUDSDK_CORE_PROJECT"; exit 1; }
  [[ "$GOOGLE_CLOUD_PROJECT" == "profile-custom-project" ]] || { echo "FAIL: GOOGLE_CLOUD_PROJECT mismatch: $GOOGLE_CLOUD_PROJECT"; exit 1; }
  [[ "$GOOGLE_CLOUD_LOCATION" == "europe-west1" ]] || { echo "FAIL: GOOGLE_CLOUD_LOCATION mismatch: $GOOGLE_CLOUD_LOCATION"; exit 1; }
  echo "PASS: GCP environment variables correctly exported."
)

echo "=== Test 5: Shared ADC credentials symlink ==="
(
  echo '{"type": "authorized_user", "client_id": "test"}' > "$MOCK_ORIG_HOME/.config/gcloud/application_default_credentials.json"

  link_adc_credentials "$MOCK_ORIG_HOME" "$MOCK_PROFILE_DIR"

  PROF_ADC="$MOCK_PROFILE_DIR/.config/gcloud/application_default_credentials.json"
  [[ -L "$PROF_ADC" ]] || { echo "FAIL: Profile ADC is not a symlink"; exit 1; }
  [[ "$(readlink -f "$PROF_ADC")" == "$(readlink -f "$MOCK_ORIG_HOME/.config/gcloud/application_default_credentials.json")" ]] || { echo "FAIL: Profile ADC symlink target mismatch"; exit 1; }
  echo "PASS: ADC credentials symlinked successfully."
)

echo "=== Test 6: Atomic write preserves symlink target ==="
(
  REAL_FILE="$MOCK_ORIG_HOME/real_settings.json"
  SYMLINK_FILE="$MOCK_ORIG_HOME/symlink_settings.json"
  echo '{"colorScheme": "tokyo"}' > "$REAL_FILE"
  ln -sf "$REAL_FILE" "$SYMLINK_FILE"

  atomic_write_json "$SYMLINK_FILE" '{"colorScheme": "dracula"}'

  [[ -L "$SYMLINK_FILE" ]] || { echo "FAIL: Symlink was broken"; exit 1; }
  grep -q '"colorScheme": "dracula"' "$REAL_FILE" || { echo "FAIL: Target was not updated"; exit 1; }
  echo "PASS: atomic_write_json preserves symlink target."
)

echo "=== Test 7: Three-way merge deltas and deny > ask > allow precedence ==="
(
  TARGET_F="$TEST_TMPDIR/t7_target.json"
  CURRENT_F="$TEST_TMPDIR/t7_current.json"
  BASE_F="$TEST_TMPDIR/t7_base.json"

  # Base state:
  # allow: [cat, rm, curl, wget]
  # deny: []
  # ask: []
  cat << 'EOF' > "$BASE_F"
{
  "permissions": {
    "allow": ["command(cat)", "command(rm)", "command(curl)", "command(wget)"]
  }
}
EOF

  # Current state (provides deltas vs Base):
  # - added to allow: command(ls)
  # - removed from allow: command(rm)
  # - moved command(wget) from allow to ask
  # - added command(curl) to deny
  cat << 'EOF' > "$CURRENT_F"
{
  "permissions": {
    "allow": ["command(cat)", "command(ls)"],
    "ask": ["command(wget)"],
    "deny": ["command(curl)"]
  }
}
EOF

  # Target state:
  # has gcp, and allow: [cat, rm, git, curl, wget]
  cat << 'EOF' > "$TARGET_F"
{
  "gcp": {"project": "keep-me"},
  "permissions": {
    "allow": ["command(cat)", "command(rm)", "command(git)", "command(curl)", "command(wget)"]
  }
}
EOF

  merge_permissions_3way "$TARGET_F" "$CURRENT_F" "$BASE_F"

  # Verify target preserves gcp
  grep -q '"project": "keep-me"' "$TARGET_F" || { echo "FAIL: GCP project clobbered"; exit 1; }

  # Verify allow contains: cat, git, ls
  grep -q '"command(cat)"' "$TARGET_F" || { echo "FAIL: cat missing from allow"; exit 1; }
  grep -q '"command(git)"' "$TARGET_F" || { echo "FAIL: git missing from allow"; exit 1; }
  grep -q '"command(ls)"' "$TARGET_F" || { echo "FAIL: ls missing from allow"; exit 1; }

  # Verify rm is removed
  grep -q '"command(rm)"' "$TARGET_F" && { echo "FAIL: rm was not removed"; exit 1; }

  # Verify wget moved to ask and NOT in allow
  jq -e '.permissions.ask | index("command(wget)") != null' "$TARGET_F" >/dev/null || { echo "FAIL: wget not in ask"; exit 1; }
  jq -e '((.permissions.allow // []) | index("command(wget)")) == null' "$TARGET_F" >/dev/null || { echo "FAIL: wget still in allow"; exit 1; }

  # Verify curl is in deny and purged from allow (deny > allow precedence)
  jq -e '.permissions.deny | index("command(curl)") != null' "$TARGET_F" >/dev/null || { echo "FAIL: curl not in deny"; exit 1; }
  jq -e '((.permissions.allow // []) | index("command(curl)")) == null' "$TARGET_F" >/dev/null || { echo "FAIL: curl still in allow"; exit 1; }

  # Test tie-breaker: deny > ask
  cat << 'EOF' > "$CURRENT_F"
{
  "permissions": {
    "ask": ["command(conflict)"],
    "deny": ["command(conflict)"]
  }
}
EOF
  cat << 'EOF' > "$TARGET_F"
{
  "permissions": {
    "allow": ["command(conflict)"]
  }
}
EOF
  merge_permissions_3way "$TARGET_F" "$CURRENT_F" "/dev/null"
  jq -e '.permissions.deny | index("command(conflict)") != null' "$TARGET_F" >/dev/null || { echo "FAIL: conflict not in deny"; exit 1; }
  jq -e '((.permissions.ask // []) | index("command(conflict)")) == null' "$TARGET_F" >/dev/null || { echo "FAIL: conflict should not be in ask when deny present"; exit 1; }
  jq -e '((.permissions.allow // []) | index("command(conflict)")) == null' "$TARGET_F" >/dev/null || { echo "FAIL: conflict should not be in allow when deny present"; exit 1; }

  echo "PASS: merge_permissions_3way correctly computes deltas and enforces deny > ask > allow precedence."
)

echo "=== Test 8: sync_permissions_to_profile propagates global revocations and moves ==="
(
  GLOBAL_F="$TEST_TMPDIR/t8_global.json"
  PROF_F="$TEST_TMPDIR/t8_profile/settings.json"
  BASE_F="$TEST_TMPDIR/t8_profile/.permissions-baseline.json"
  mkdir -p "$TEST_TMPDIR/t8_profile"

  # Initial global settings
  cat << 'EOF' > "$GLOBAL_F"
{
  "permissions": {
    "allow": ["command(cat)", "command(ls)", "command(rm)"]
  }
}
EOF

  # Initial profile settings
  cat << 'EOF' > "$PROF_F"
{
  "gcp": {"project": "prof-p1"},
  "permissions": {
    "allow": ["command(cat)", "command(ls)", "command(rm)"]
  }
}
EOF

  # 1. First run: baseline does not exist yet. Running startup sync should initialize baseline.
  sync_permissions_to_profile "$GLOBAL_F" "$PROF_F"
  [[ -f "$BASE_F" ]] || { echo "FAIL: Baseline file not created on initial run"; exit 1; }
  jq -e '.permissions.allow | index("command(rm)") != null' "$BASE_F" >/dev/null || { echo "FAIL: Baseline missing rm"; exit 1; }

  # 2. User revokes command(rm) globally and moves command(ls) from allow to ask
  cat << 'EOF' > "$GLOBAL_F"
{
  "permissions": {
    "allow": ["command(cat)"],
    "ask": ["command(ls)"]
  }
}
EOF

  # Run startup sync again
  sync_permissions_to_profile "$GLOBAL_F" "$PROF_F"

  # Verify rm is removed from profile
  jq -e '((.permissions.allow // []) | index("command(rm)")) == null' "$PROF_F" >/dev/null || { echo "FAIL: rm was not revoked from profile"; exit 1; }

  # Verify ls moved to ask in profile
  jq -e '.permissions.ask | index("command(ls)") != null' "$PROF_F" >/dev/null || { echo "FAIL: ls not moved to ask in profile"; exit 1; }
  jq -e '((.permissions.allow // []) | index("command(ls)")) == null' "$PROF_F" >/dev/null || { echo "FAIL: ls still in allow in profile"; exit 1; }

  # Verify GCP project is preserved
  grep -q '"project": "prof-p1"' "$PROF_F" || { echo "FAIL: Profile GCP project was clobbered"; exit 1; }

  # Verify baseline was updated
  jq -e '((.permissions.allow // []) | index("command(rm)")) == null' "$BASE_F" >/dev/null || { echo "FAIL: rm still in baseline"; exit 1; }
  jq -e '.permissions.ask | index("command(ls)") != null' "$BASE_F" >/dev/null || { echo "FAIL: ls not in ask in baseline"; exit 1; }

  echo "PASS: sync_permissions_to_profile successfully propagates global revocations and moves."
)

echo "=== Test 9: sync_permissions_to_global propagates profile deletions/moves and preserves global ask ==="
(
  GLOBAL_F="$TEST_TMPDIR/t9_orig/settings.json"
  PROF_F="$TEST_TMPDIR/t9_profile/settings.json"
  BASE_F="$TEST_TMPDIR/t9_profile/.permissions-baseline.json"
  mkdir -p "$TEST_TMPDIR/t9_orig" "$TEST_TMPDIR/t9_profile"

  # Initial baseline and global state:
  # global has ask: [command(sudo)] and allow: [command(cat), command(git), command(rm)]
  cat << 'EOF' > "$GLOBAL_F"
{
  "gcp": {"project": "global-p0"},
  "permissions": {
    "allow": ["command(cat)", "command(git)", "command(rm)"],
    "ask": ["command(sudo)"]
  }
}
EOF

  cat << 'EOF' > "$BASE_F"
{
  "permissions": {
    "allow": ["command(cat)", "command(git)", "command(rm)"],
    "ask": ["command(sudo)"]
  }
}
EOF

  # In profile during session:
  # - user deleted command(rm)
  # - user moved command(git) to ask
  # - user added command(docker) to allow
  # (Note: command(sudo) remains in ask or profile didn't touch it)
  cat << 'EOF' > "$PROF_F"
{
  "gcp": {"project": "prof-p2"},
  "permissions": {
    "allow": ["command(cat)", "command(docker)"],
    "ask": ["command(git)", "command(sudo)"]
  }
}
EOF

  sync_permissions_to_global "$GLOBAL_F" "$PROF_F"

  # 1. Verify global GCP project is preserved
  grep -q '"project": "global-p0"' "$GLOBAL_F" || { echo "FAIL: Global GCP project clobbered"; exit 1; }

  # 2. Verify command(docker) added to global allow
  jq -e '.permissions.allow | index("command(docker)") != null' "$GLOBAL_F" >/dev/null || { echo "FAIL: docker not added to global allow"; exit 1; }

  # 3. Verify command(rm) was deleted from global allow
  jq -e '((.permissions.allow // []) | index("command(rm)")) == null' "$GLOBAL_F" >/dev/null || { echo "FAIL: rm was not deleted from global"; exit 1; }

  # 4. Verify command(git) was moved to ask in global and removed from allow
  jq -e '.permissions.ask | index("command(git)") != null' "$GLOBAL_F" >/dev/null || { echo "FAIL: git not in global ask"; exit 1; }
  jq -e '((.permissions.allow // []) | index("command(git)")) == null' "$GLOBAL_F" >/dev/null || { echo "FAIL: git still in global allow"; exit 1; }

  # 5. Verify command(sudo) is preserved in global ask (regression test for line 143 bug)
  jq -e '.permissions.ask | index("command(sudo)") != null' "$GLOBAL_F" >/dev/null || { echo "FAIL: sudo missing from global ask (line 143 bug)"; exit 1; }

  # 6. Verify baseline is updated
  jq -e '.permissions.allow | index("command(docker)") != null' "$BASE_F" >/dev/null || { echo "FAIL: baseline missing docker"; exit 1; }
  jq -e '((.permissions.allow // []) | index("command(rm)")) == null' "$BASE_F" >/dev/null || { echo "FAIL: rm still in baseline"; exit 1; }

  echo "PASS: sync_permissions_to_global propagates deletions and moves and preserves global ask rules."
)

echo "=== Test 10: 0-byte global file resilience does not wipe profile GCP settings ==="
(
  GLOBAL_F="$TEST_TMPDIR/t10_global.json"
  PROF_F="$TEST_TMPDIR/t10_profile/settings.json"
  mkdir -p "$TEST_TMPDIR/t10_profile"

  # Create 0-byte global file
  touch "$GLOBAL_F"

  cat << 'EOF' > "$PROF_F"
{
  "colorScheme": "gruvbox",
  "gcp": {
    "project": "my-important-project",
    "location": "us-east1"
  },
  "permissions": {
    "allow": ["command(node)"]
  }
}
EOF

  sync_permissions_to_profile "$GLOBAL_F" "$PROF_F"

  # Check GCP project NOT wiped
  grep -q '"project": "my-important-project"' "$PROF_F" || { echo "FAIL: Profile GCP project was wiped by 0-byte global file"; exit 1; }
  grep -q '"location": "us-east1"' "$PROF_F" || { echo "FAIL: Profile GCP location was wiped by 0-byte global file"; exit 1; }
  grep -q '"colorScheme": "gruvbox"' "$PROF_F" || { echo "FAIL: Profile colorScheme was wiped by 0-byte global file"; exit 1; }
  echo "PASS: 0-byte global file handled safely without wiping profile configuration."
)

echo "=== Test 11: Move allow -> deny in profile propagates to global with strict precedence ==="
(
  GLOBAL_F="$TEST_TMPDIR/t11_global.json"
  PROF_F="$TEST_TMPDIR/t11_profile/settings.json"
  BASE_F="$TEST_TMPDIR/t11_profile/.permissions-baseline.json"
  mkdir -p "$TEST_TMPDIR/t11_profile"

  cat << 'EOF' > "$GLOBAL_F"
{
  "permissions": {
    "allow": ["command(danger)", "command(safe)"]
  }
}
EOF

  cat << 'EOF' > "$BASE_F"
{
  "permissions": {
    "allow": ["command(danger)", "command(safe)"]
  }
}
EOF

  # Move danger from allow to deny in profile
  cat << 'EOF' > "$PROF_F"
{
  "permissions": {
    "allow": ["command(safe)"],
    "deny": ["command(danger)"]
  }
}
EOF

  sync_permissions_to_global "$GLOBAL_F" "$PROF_F"

  jq -e '.permissions.deny | index("command(danger)") != null' "$GLOBAL_F" >/dev/null || { echo "FAIL: danger not added to global deny"; exit 1; }
  jq -e '((.permissions.allow // []) | index("command(danger)")) == null' "$GLOBAL_F" >/dev/null || { echo "FAIL: danger still in global allow"; exit 1; }
  jq -e '.permissions.allow | index("command(safe)") != null' "$GLOBAL_F" >/dev/null || { echo "FAIL: safe missing from global allow"; exit 1; }
  echo "PASS: allow -> deny propagation enforces strict least-privilege precedence."
)

echo "=== Test 12: sync_permissions_to_global preserves dotfile symlink ==="
(
  DOTFILES_REAL="$TEST_TMPDIR/dotfiles/settings.json"
  GLOBAL_SYMLINK="$TEST_TMPDIR/global_symlink/settings.json"
  PROF_F="$TEST_TMPDIR/t12_profile/settings.json"
  mkdir -p "$TEST_TMPDIR/dotfiles" "$TEST_TMPDIR/global_symlink" "$TEST_TMPDIR/t12_profile"

  cat << 'EOF' > "$DOTFILES_REAL"
{
  "permissions": {
    "allow": ["command(ls)"]
  }
}
EOF
  ln -sf "$DOTFILES_REAL" "$GLOBAL_SYMLINK"
  [[ -L "$GLOBAL_SYMLINK" ]] || { echo "FAIL: Setup symlink failed"; exit 1; }

  cat << 'EOF' > "$PROF_F"
{
  "permissions": {
    "allow": ["command(ls)", "command(pwd)"]
  }
}
EOF

  sync_permissions_to_global "$GLOBAL_SYMLINK" "$PROF_F"

  [[ -L "$GLOBAL_SYMLINK" ]] || { echo "FAIL: Global settings symlink was broken by sync_permissions_to_global"; exit 1; }
  grep -q '"command(pwd)"' "$DOTFILES_REAL" || { echo "FAIL: Real dotfile was not updated"; exit 1; }
  echo "PASS: sync_permissions_to_global successfully preserved dotfile symlink."
)

echo "All tests passed successfully!"
