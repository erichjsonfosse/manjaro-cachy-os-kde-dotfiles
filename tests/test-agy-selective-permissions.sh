#!/usr/bin/env bash
set -eo pipefail

TEST_TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TEST_TMPDIR"' EXIT

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BIN_AGY="$SCRIPT_DIR/../bin/agy"

# Source bin/agy for function testing
# shellcheck source=../bin/agy
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

echo "All tests passed successfully!"
