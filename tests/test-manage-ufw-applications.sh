#!/usr/bin/env bash
# Test suite for manage-ufw-applications.sh
set -eo pipefail

TEST_SCRIPT_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPOSITORY_ROOT="$(cd "$TEST_SCRIPT_DIRECTORY/.." && pwd)"
UTILITY_SCRIPT="$REPOSITORY_ROOT/utilities/post-install/manage-ufw-applications.sh"

echo "=== Running Tests for manage-ufw-applications.sh ==="

# Test 1: File existence and non-root execution check
echo "--- Test 1: Script existence and basic execution ---"
if [[ ! -f "$UTILITY_SCRIPT" ]]; then
  echo "FAIL: Utility script does not exist at $UTILITY_SCRIPT" >&2
  exit 1
fi

# Source script in test harness mode
# shellcheck source=/dev/null
source "$UTILITY_SCRIPT"

# Test 2: Profile Discovery and INI Header Extraction
echo "--- Test 2: Profile discovery and header extraction ---"
declare -a discovered_filenames=()
declare -a discovered_profile_names=()
declare -a discovered_titles=()

discover_profiles "$REPOSITORY_ROOT/config/ufw/applications.d"

if [[ "${#discovered_filenames[@]}" -lt 2 ]]; then
  echo "FAIL: Expected at least 2 discovered profiles, got ${#discovered_filenames[@]}" >&2
  exit 1
fi

found_kdeconnect=false
found_noson=false

for i in "${!discovered_filenames[@]}"; do
  filename="${discovered_filenames[i]}"
  profile_name="${discovered_profile_names[i]}"
  if [[ "$filename" == "kdeconnect" && "$profile_name" == "KDEConnect" ]]; then
    found_kdeconnect=true
    if [[ "${discovered_titles[i]}" != "KDE Connect" ]]; then
      echo "FAIL: Expected title 'KDE Connect', got '${discovered_titles[i]}'" >&2
      exit 1
    fi
  fi
  if [[ "$filename" == "noson" && "$profile_name" == "noson" ]]; then
    found_noson=true
    if [[ "${discovered_titles[i]}" != "noson Sonos controller app" ]]; then
      echo "FAIL: Expected title 'noson Sonos controller app', got '${discovered_titles[i]}'" >&2
      exit 1
    fi
  fi
done

if [[ "$found_kdeconnect" != "true" ]]; then
  echo "FAIL: kdeconnect profile with header KDEConnect not discovered" >&2
  exit 1
fi

if [[ "$found_noson" != "true" ]]; then
  echo "FAIL: noson profile with header noson not discovered" >&2
  exit 1
fi
echo "PASS: Profile discovery and INI header extraction verified."

# Test 3: Profile Name Resolution (case-insensitive / filename / profile header)
echo "--- Test 3: Profile name resolution ---"
resolved_profile=""
resolved_filename=""

resolve_profile_name "kdeconnect" resolved_profile resolved_filename
if [[ "$resolved_profile" != "KDEConnect" || "$resolved_filename" != "kdeconnect" ]]; then
  echo "FAIL: resolve_profile_name 'kdeconnect' failed: got '$resolved_profile' / '$resolved_filename'" >&2
  exit 1
fi

resolve_profile_name "KDEConnect" resolved_profile resolved_filename
if [[ "$resolved_profile" != "KDEConnect" || "$resolved_filename" != "kdeconnect" ]]; then
  echo "FAIL: resolve_profile_name 'KDEConnect' failed: got '$resolved_profile' / '$resolved_filename'" >&2
  exit 1
fi

resolve_profile_name "noson" resolved_profile resolved_filename
if [[ "$resolved_profile" != "noson" || "$resolved_filename" != "noson" ]]; then
  echo "FAIL: resolve_profile_name 'noson' failed: got '$resolved_profile' / '$resolved_filename'" >&2
  exit 1
fi

if resolve_profile_name "nonexistent_app" resolved_profile resolved_filename 2>/dev/null; then
  echo "FAIL: resolve_profile_name unexpectedly succeeded for 'nonexistent_app'" >&2
  exit 1
fi
echo "PASS: Profile name resolution verified."

echo "All Task 1 tests passed!"
