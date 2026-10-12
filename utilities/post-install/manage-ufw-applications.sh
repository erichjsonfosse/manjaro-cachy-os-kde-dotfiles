#!/usr/bin/env bash
# Manage UFW firewall application profiles for dotfiles applications.
set -eo pipefail

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

ensure_privileged_access() {
  if [[ "$EUID" -eq 0 ]]; then
    return 0
  fi

  local privileged_wrapper="${UFW_PRIVILEGED_WRAPPER-sudo}"
  if [[ "$privileged_wrapper" == "sudo" ]]; then
    if ! sudo -n true 2>/dev/null; then
      echo "Administrative privileges are required to manage UFW firewall profiles."
      sudo -v || {
        echo "Error: Failed to obtain sudo privileges." >&2
        return 1
      }
    fi
  fi
  return 0
}

run_privileged_command() {
  if [[ "$EUID" -eq 0 || -z "${UFW_PRIVILEGED_WRAPPER-sudo}" ]]; then
    "$@"
  else
    "${UFW_PRIVILEGED_WRAPPER-sudo}" "$@"
  fi
}

get_application_status() {
  local input_query="$1"
  local output_status_variable_name="$2"
  local cached_status_output="${3-}"

  local resolved_profile_name=""
  local resolved_filename=""
  if ! resolve_profile_name "$input_query" resolved_profile_name resolved_filename; then
    return 1
  fi

  local system_directory="${UFW_SYSTEM_DIRECTORY:-${SYSTEM_CONFIG_DIRECTORY:-/etc/ufw/applications.d}}"
  local installed_profile_path="$system_directory/$resolved_filename"
  local ufw_binary="${UFW_COMMAND:-ufw}"

  local inspected_status="unconfigured"
  if [[ -f "$installed_profile_path" ]]; then
    local status_output="$cached_status_output"
    if [[ -z "$status_output" ]]; then
      status_output="$(run_privileged_command "$ufw_binary" status 2>/dev/null || true)"
    fi
    if echo "$status_output" | grep -q "Status: active" && echo "$status_output" | grep -q -E "^${resolved_profile_name}([[:space:]]|$)"; then
      inspected_status="active"
    else
      inspected_status="inactive_installed"
    fi
  fi

  if [[ -n "$output_status_variable_name" ]]; then
    printf -v "$output_status_variable_name" '%s' "$inspected_status"
  else
    echo "$inspected_status"
  fi
  return 0
}

enable_application() {
  local input_query="$1"

  local resolved_profile_name=""
  local resolved_filename=""
  if ! resolve_profile_name "$input_query" resolved_profile_name resolved_filename; then
    echo "Error: Application profile '$input_query' not found." >&2
    return 1
  fi

  local source_profile_path="$SOURCE_CONFIG_DIRECTORY/$resolved_filename"
  if [[ ! -f "$source_profile_path" ]]; then
    echo "Error: Source configuration file not found at $source_profile_path" >&2
    return 1
  fi

  local system_directory="${UFW_SYSTEM_DIRECTORY:-${SYSTEM_CONFIG_DIRECTORY:-/etc/ufw/applications.d}}"
  local installed_profile_path="$system_directory/$resolved_filename"
  local ufw_binary="${UFW_COMMAND:-ufw}"

  run_privileged_command mkdir -p "$system_directory"
  run_privileged_command cp -f "$source_profile_path" "$installed_profile_path"
  run_privileged_command chmod 0644 "$installed_profile_path"

  if [[ -n "${UFW_PRIVILEGED_WRAPPER-sudo}" ]]; then
    run_privileged_command chown root:root "$installed_profile_path" 2>/dev/null || true
  fi

  run_privileged_command "$ufw_binary" app update "$resolved_profile_name"
  run_privileged_command "$ufw_binary" allow "$resolved_profile_name"
  echo "Enabled and allowed firewall profile: $resolved_profile_name"
}

disable_application() {
  local input_query="$1"

  local resolved_profile_name=""
  local resolved_filename=""
  if ! resolve_profile_name "$input_query" resolved_profile_name resolved_filename; then
    echo "Error: Application profile '$input_query' not found." >&2
    return 1
  fi

  local system_directory="${UFW_SYSTEM_DIRECTORY:-${SYSTEM_CONFIG_DIRECTORY:-/etc/ufw/applications.d}}"
  local installed_profile_path="$system_directory/$resolved_filename"
  local ufw_binary="${UFW_COMMAND:-ufw}"

  run_privileged_command "$ufw_binary" delete allow "$resolved_profile_name" 2>/dev/null || true

  if [[ -f "$installed_profile_path" ]]; then
    run_privileged_command rm -f "$installed_profile_path"
  fi

  run_privileged_command "$ufw_binary" app update "$resolved_profile_name" 2>/dev/null || true
  echo "Disabled and removed firewall profile: $resolved_profile_name"
}

display_usage() {
  cat << 'EOF'
Usage: manage-ufw-applications.sh [OPTIONS]

Manage UFW firewall application profiles for dotfiles applications.
When executed without arguments in an interactive terminal, launches an interactive TUI.

Options:
  --enable <application|all>    Install profile definition and allow firewall traffic for <application> or all profiles
  --disable <application|all>   Delete allow rule and remove profile definition for <application> or all profiles
  --status              Display current installation and firewall status of all profiles
  --list                List all available application profile names
  -h, --help            Display this help message and exit
EOF
}

display_status_table() {
  if [[ "${#discovered_filenames[@]}" -eq 0 ]]; then
    discover_profiles "$SOURCE_CONFIG_DIRECTORY"
  fi

  local ufw_binary="${UFW_COMMAND:-ufw}"
  local current_ufw_status=""
  current_ufw_status="$(run_privileged_command "$ufw_binary" status 2>/dev/null || true)"

  printf "%-18s %-20s %s\n" "Application" "Status" "Ports"
  printf "%-18s %-20s %s\n" "-----------" "------" "-----"

  for index in "${!discovered_filenames[@]}"; do
    local profile_name="${discovered_profile_names[index]}"
    local ports="${discovered_ports[index]}"
    local application_status=""
    get_application_status "$profile_name" application_status "$current_ufw_status"
    printf "%-18s %-20s %s\n" "$profile_name" "$application_status" "$ports"
  done
}

list_applications() {
  if [[ "${#discovered_filenames[@]}" -eq 0 ]]; then
    discover_profiles "$SOURCE_CONFIG_DIRECTORY"
  fi

  for index in "${!discovered_filenames[@]}"; do
    local profile_name="${discovered_profile_names[index]}"
    echo "$profile_name"
  done
}

enable_all_applications() {
  if [[ "${#discovered_filenames[@]}" -eq 0 ]]; then
    discover_profiles "$SOURCE_CONFIG_DIRECTORY"
  fi

  for index in "${!discovered_filenames[@]}"; do
    local profile_name="${discovered_profile_names[index]}"
    enable_application "$profile_name"
  done
}

disable_all_applications() {
  if [[ "${#discovered_filenames[@]}" -eq 0 ]]; then
    discover_profiles "$SOURCE_CONFIG_DIRECTORY"
  fi

  for index in "${!discovered_filenames[@]}"; do
    local profile_name="${discovered_profile_names[index]}"
    disable_application "$profile_name"
  done
}

launch_interactive_tui() {
  if ! command -v gum &>/dev/null; then
    echo "Notice: 'gum' is not installed. Falling back to standard status view."
    display_status_table
    echo ""
    display_usage
    return 0
  fi

  ensure_privileged_access || return 1

  while true; do
    clear
    gum style \
      --border normal \
      --border-foreground 99 \
      --foreground 99 \
      --padding "0 1" \
      --margin "1 0" \
      --bold \
      "🛡️  UFW Dotfiles Application Manager"

    echo ""
    gum style --foreground 245 "Current firewall profile statuses:"
    display_status_table
    echo ""

    local selected_action=""
    selected_action="$(gum choose \
      "1. Enable application(s)" \
      "2. Disable & remove application(s)" \
      "3. View detailed firewall status" \
      "4. Exit" || true)"

    case "$selected_action" in
      "1. Enable application(s)")
        if [[ "${#discovered_filenames[@]}" -eq 0 ]]; then
          discover_profiles "$SOURCE_CONFIG_DIRECTORY"
        fi
        local choices=("All applications" "${discovered_profile_names[@]}" "← Back")
        local chosen_profile=""
        chosen_profile="$(gum choose --header="Select an application to enable:" "${choices[@]}" || true)"
        case "$chosen_profile" in
          "All applications")
            enable_all_applications
            gum input --placeholder "Press Enter to continue..." || true
            ;;
          "← Back"|"")
            ;;
          *)
            enable_application "$chosen_profile"
            gum input --placeholder "Press Enter to continue..." || true
            ;;
        esac
        ;;
      "2. Disable & remove application(s)")
        if [[ "${#discovered_filenames[@]}" -eq 0 ]]; then
          discover_profiles "$SOURCE_CONFIG_DIRECTORY"
        fi
        local choices=("All applications" "${discovered_profile_names[@]}" "← Back")
        local chosen_profile=""
        chosen_profile="$(gum choose --header="Select an application to disable & remove:" "${choices[@]}" || true)"
        case "$chosen_profile" in
          "All applications")
            disable_all_applications
            gum input --placeholder "Press Enter to continue..." || true
            ;;
          "← Back"|"")
            ;;
          *)
            disable_application "$chosen_profile"
            gum input --placeholder "Press Enter to continue..." || true
            ;;
        esac
        ;;
      "3. View detailed firewall status")
        local ufw_binary="${UFW_COMMAND:-ufw}"
        echo ""
        run_privileged_command "$ufw_binary" status verbose || true
        echo ""
        gum input --placeholder "Press Enter to continue..." || true
        ;;
      "4. Exit"|"")
        break
        ;;
    esac
  done
}

parse_command_line_arguments() {
  if [[ $# -eq 0 ]]; then
    if [[ -t 0 ]]; then
      launch_interactive_tui
      return 0
    else
      display_usage
      return 0
    fi
  fi

  while [[ $# -gt 0 ]]; do
    case "$1" in
      --enable)
        if [[ -z "${2-}" || "$2" == --* ]]; then
          echo "Error: --enable requires an application name or 'all'." >&2
          return 1
        fi
        ensure_privileged_access || return 1
        local target_application="$2"
        shift 2
        if [[ "$target_application" == "all" ]]; then
          enable_all_applications
        else
          enable_application "$target_application"
        fi
        ;;
      --disable)
        if [[ -z "${2-}" || "$2" == --* ]]; then
          echo "Error: --disable requires an application name or 'all'." >&2
          return 1
        fi
        ensure_privileged_access || return 1
        local target_application="$2"
        shift 2
        if [[ "$target_application" == "all" ]]; then
          disable_all_applications
        else
          disable_application "$target_application"
        fi
        ;;
      --status)
        shift
        ensure_privileged_access || return 1
        display_status_table
        ;;
      --list)
        shift
        list_applications
        ;;
      -h|--help)
        shift
        display_usage
        return 0
        ;;
      *)
        echo "Error: Unknown option '$1'" >&2
        display_usage >&2
        return 1
        ;;
    esac
  done
}

main() {
  parse_command_line_arguments "$@"
}

if [[ "${BASH_SOURCE[0]}" == "${0}" ]]; then
  main "$@"
fi
