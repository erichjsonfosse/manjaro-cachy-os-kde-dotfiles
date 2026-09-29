if command -v direnv &>/dev/null; then
  eval "$(direnv hook zsh)"
fi

_direnv_gcp_render_block() {
  local project_id="$1"
  local location="$2"

  cat << EOF
# --- BEGIN GCP DIRENV CONFIG ---
export GOOGLE_CLOUD_PROJECT="$project_id"
export CLOUDSDK_CORE_PROJECT="$project_id"
export GOOGLE_CLOUD_QUOTA_PROJECT="$project_id"
export GOOGLE_VERTEX_LOCATION="$location"
export GEMINI_LOCATION="$location"
# --- END GCP DIRENV CONFIG ---
EOF
}

_direnv_gcp_upsert_block() {
  local target_file="$1"
  local project_id="$2"
  local location="$3"
  local start_marker="# --- BEGIN GCP DIRENV CONFIG ---"
  local end_marker="# --- END GCP DIRENV CONFIG ---"
  local block
  block="$(_direnv_gcp_render_block "$project_id" "$location")"

  if [ ! -f "$target_file" ]; then
    printf "%s\n" "$block" > "$target_file"
    return 0
  fi

  if grep -qF "$start_marker" "$target_file" && grep -qF "$end_marker" "$target_file"; then
    awk -v b="$block" -v s="$start_marker" -v e="$end_marker" '
      $0 == s { print b; skip=1; next }
      $0 == e { skip=0; next }
      !skip { print }
    ' "$target_file" > "${target_file}.tmp" && mv "${target_file}.tmp" "$target_file"
  else
    {
      if [ -s "$target_file" ]; then
        [ -z "$(tail -c 1 "$target_file" 2>/dev/null)" ] || echo ""
        echo ""
      fi
      printf "%s\n" "$block"
    } >> "$target_file"
  fi
}

setupDirenvForGoogleCloudProject() {
  local project_id="$1"
  local location="${2:-europe-west1}"

  # 1. Resolve Project ID
  if [ -z "$project_id" ]; then
    if ! command -v gcloud &>/dev/null; then
      printf "\033[0;31mError:\033[0m 'gcloud' is not installed or not in PATH.\n"
      printf "Please specify the project ID: setupDirenvForGoogleCloudProject <project-id> [location]\n"
      return 1
    fi

    printf "Fetching Google Cloud projects...\n"
    local projects_list
    projects_list=$(gcloud projects list --format="value(projectId,name)" 2>/dev/null)
    if [ -z "$projects_list" ]; then
      printf "\033[0;31mError:\033[0m No projects found or gcloud not authenticated.\n"
      return 1
    fi

    if command -v gum &>/dev/null; then
      local selected
      selected=$(echo "$projects_list" | gum filter --placeholder "Select Google Cloud Project...")
      project_id=$(echo "$selected" | awk '{print $1}')
    elif command -v fzf &>/dev/null; then
      local selected
      selected=$(echo "$projects_list" | fzf --header="Select Google Cloud Project" --reverse)
      project_id=$(echo "$selected" | awk '{print $1}')
    else
      echo "$projects_list"
      printf "Enter Google Cloud Project ID: "
      read -r project_id
    fi

    if [ -z "$project_id" ]; then
      printf "Aborted: No project selected.\n"
      return 0
    fi
  fi

  # 2. Update .envrc and .envrc.example
  _direnv_gcp_upsert_block ".envrc" "$project_id" "$location"
  _direnv_gcp_upsert_block ".envrc.example" "your-gcp-project-id" "$location"

  # 3. Git Safeguard: Ensure .envrc is ignored while .envrc.example is trackable
  if git rev-parse --is-inside-work-tree &>/dev/null; then
    if ! git check-ignore -q .envrc 2>/dev/null; then
      if [ -f .gitignore ] && [ -s .gitignore ] && [ -n "$(tail -c 1 .gitignore 2>/dev/null)" ]; then
        echo "" >> .gitignore
      fi
      echo ".envrc" >> .gitignore
      printf "\033[0;32m[✔]\033[0m Added .envrc to .gitignore\n"
    fi
  fi

  # 4. Authorize direnv if installed
  if command -v direnv &>/dev/null; then
    direnv allow .
  else
    printf "\033[0;33m[!]\033[0m Note: 'direnv' command not found. Run 'direnv allow' once installed.\n"
  fi

  printf "\033[0;32m[✔]\033[0m Google Cloud environment configured successfully!\n"
  printf "    Project:  %s\n" "$project_id"
  printf "    Location: %s\n" "$location"
  printf "    Files:    .envrc (authorized), .envrc.example (committable template)\n"
}

# Convenience aliases
alias setup-gcp-direnv="setupDirenvForGoogleCloudProject"
alias direnv-gcp="setupDirenvForGoogleCloudProject"
