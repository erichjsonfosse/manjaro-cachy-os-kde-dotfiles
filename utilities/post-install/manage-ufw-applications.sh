#!/usr/bin/env bash
# Manage UFW firewall application profiles for dotfiles applications.
set -eo pipefail

if [ "$EUID" -eq 0 ]; then
  echo "Error: Dotfiles firewall manager should NOT be run directly as root." >&2
  echo "Please run as your regular user: $0" >&2
  exit 1
fi

SCRIPT_DIRECTORY="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPOSITORY_ROOT="$(cd "$SCRIPT_DIRECTORY/../.." && pwd)"
SOURCE_CONFIG_DIRECTORY="${UFW_SOURCE_DIRECTORY:-$REPOSITORY_ROOT/config/ufw/applications.d}"
export SYSTEM_CONFIG_DIRECTORY="${UFW_SYSTEM_DIRECTORY:-/etc/ufw/applications.d}"

# Global arrays populated by discover_profiles
discovered_filenames=()
discovered_profile_names=()
discovered_titles=()
discovered_descriptions=()
discovered_ports=()

discover_profiles() {
  local search_directory="${1:-$SOURCE_CONFIG_DIRECTORY}"

  discovered_filenames=()
  discovered_profile_names=()
  discovered_titles=()
  discovered_descriptions=()
  discovered_ports=()

  if [[ ! -d "$search_directory" ]]; then
    return 1
  fi

  local profile_file
  while IFS= read -r profile_file; do
    [[ -f "$profile_file" ]] || continue

    local filename
    filename="$(basename "$profile_file")"

    local profile_name
    profile_name="$(sed -n 's/^\[\(.*\)\]$/\1/p' "$profile_file" | head -n 1)"
    [[ -n "$profile_name" ]] || profile_name="$filename"

    local title
    title="$(sed -n 's/^title=\(.*$\)/\1/p' "$profile_file" | head -n 1)"

    local description
    description="$(sed -n 's/^description=\(.*$\)/\1/p' "$profile_file" | head -n 1)"

    local ports
    ports="$(sed -n 's/^ports=\(.*$\)/\1/p' "$profile_file" | head -n 1)"

    discovered_filenames+=("$filename")
    discovered_profile_names+=("$profile_name")
    discovered_titles+=("$title")
    discovered_descriptions+=("$description")
    discovered_ports+=("$ports")
  done < <(find "$search_directory" -maxdepth 1 -type f | sort)
}

resolve_profile_name() {
  local input_query="$1"
  local output_profile_variable_name="$2"
  local output_filename_variable_name="$3"

  if [[ "${#discovered_filenames[@]}" -eq 0 ]]; then
    discover_profiles "$SOURCE_CONFIG_DIRECTORY"
  fi

  local lower_query
  lower_query="$(echo "$input_query" | tr '[:upper:]' '[:lower:]')"

  for index in "${!discovered_filenames[@]}"; do
    local current_filename="${discovered_filenames[index]}"
    local current_profile="${discovered_profile_names[index]}"

    local lower_filename
    lower_filename="$(echo "$current_filename" | tr '[:upper:]' '[:lower:]')"
    local lower_profile
    lower_profile="$(echo "$current_profile" | tr '[:upper:]' '[:lower:]')"

    if [[ "$lower_query" == "$lower_filename" || "$lower_query" == "$lower_profile" ]]; then
      if [[ -n "$output_profile_variable_name" ]]; then
        printf -v "$output_profile_variable_name" '%s' "$current_profile"
      fi
      if [[ -n "$output_filename_variable_name" ]]; then
        printf -v "$output_filename_variable_name" '%s' "$current_filename"
      fi
      return 0
    fi
  done

  return 1
}

main() {
  echo "manage-ufw-applications initialized."
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
