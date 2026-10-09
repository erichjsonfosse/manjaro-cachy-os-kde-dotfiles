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

# Task 2: State Inspection, Enable, Disable, and Idempotency
echo "--- Test 4: Mock environment setup & state inspection ---"
TEST_TEMP_DIRECTORY="$(mktemp -d /tmp/test-ufw-XXXXXX)"
trap 'rm -rf "$TEST_TEMP_DIRECTORY"' EXIT

MOCK_UFW_RULES_FILE="$TEST_TEMP_DIRECTORY/ufw_rules"
touch "$MOCK_UFW_RULES_FILE"
MOCK_UFW_COMMAND="$TEST_TEMP_DIRECTORY/bin/ufw"
mkdir -p "$TEST_TEMP_DIRECTORY/bin" "$TEST_TEMP_DIRECTORY/etc/ufw/applications.d"

cat << 'EOF' > "$MOCK_UFW_COMMAND"
#!/usr/bin/env bash
rules_file="${MOCK_UFW_RULES_FILE}"
case "$1" in
  status*)
    echo "Status: active"
    echo "To                         Action      From"
    echo "--                         ------      ----"
    if [[ -f "$rules_file" ]]; then
      cat "$rules_file"
    fi
    ;;
  app)
    if [[ "$2" == "update" ]]; then
      exit 0
    fi
    ;;
  allow)
    app="$2"
    if [[ -f "$rules_file" ]] && grep -q -F "$app" "$rules_file"; then
      echo "Skipping adding existing rule"
    else
      echo "$app                      ALLOW IN    Anywhere" >> "$rules_file"
      echo "Rule added"
    fi
    ;;
  delete)
    if [[ "$2" == "allow" ]]; then
      app="$3"
      if [[ -f "$rules_file" ]]; then
        grep -v -F "$app" "$rules_file" > "$rules_file.tmp" || true
        mv -f "$rules_file.tmp" "$rules_file"
      fi
      echo "Rule deleted"
    fi
    ;;
  *)
    exit 0
    ;;
esac
EOF
chmod +x "$MOCK_UFW_COMMAND"

export MOCK_UFW_RULES_FILE
export UFW_COMMAND="$MOCK_UFW_COMMAND"
export UFW_PRIVILEGED_WRAPPER=""
export UFW_SYSTEM_DIRECTORY="$TEST_TEMP_DIRECTORY/etc/ufw/applications.d"
export SYSTEM_CONFIG_DIRECTORY="$UFW_SYSTEM_DIRECTORY"

# Test 4.1: Initial status is unconfigured
initial_status=""
get_application_status "KDEConnect" initial_status
if [[ "$initial_status" != "unconfigured" ]]; then
  echo "FAIL: Expected 'unconfigured', got '$initial_status'" >&2
  exit 1
fi
echo "PASS: Unconfigured state verified."

# Test 4.2: Enable application
echo "--- Test 5: Enable application lifecycle ---"
enable_application "kdeconnect"

installed_file="$UFW_SYSTEM_DIRECTORY/kdeconnect"
if [[ ! -f "$installed_file" ]]; then
  echo "FAIL: Expected installed file at $installed_file" >&2
  exit 1
fi

post_enable_status=""
get_application_status "KDEConnect" post_enable_status
if [[ "$post_enable_status" != "active" ]]; then
  echo "FAIL: Expected 'active', got '$post_enable_status'" >&2
  exit 1
fi
echo "PASS: Enable lifecycle and active status verified."

# Test 4.3: Enable idempotency
echo "--- Test 6: Enable idempotency ---"
enable_application "kdeconnect"
get_application_status "KDEConnect" post_enable_status
if [[ "$post_enable_status" != "active" ]]; then
  echo "FAIL: Expected 'active' after re-enabling, got '$post_enable_status'" >&2
  exit 1
fi
echo "PASS: Enable idempotency verified."

# Test 4.4: Disable application lifecycle
echo "--- Test 7: Disable application lifecycle ---"
disable_application "kdeconnect"

if [[ -f "$installed_file" ]]; then
  echo "FAIL: Expected $installed_file to be removed" >&2
  exit 1
fi

post_disable_status=""
get_application_status "KDEConnect" post_disable_status
if [[ "$post_disable_status" != "unconfigured" ]]; then
  echo "FAIL: Expected 'unconfigured' after disable, got '$post_disable_status'" >&2
  exit 1
fi
echo "PASS: Disable lifecycle verified."

# Test 4.5: Disable idempotency
echo "--- Test 8: Disable idempotency ---"
disable_application "kdeconnect"
get_application_status "KDEConnect" post_disable_status
if [[ "$post_disable_status" != "unconfigured" ]]; then
  echo "FAIL: Expected 'unconfigured' after re-disabling, got '$post_disable_status'" >&2
  exit 1
fi
echo "PASS: Disable idempotency verified."

echo "All Task 2 tests passed!"
