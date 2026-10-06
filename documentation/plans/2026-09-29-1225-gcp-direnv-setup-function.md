# Google Cloud Direnv Setup Function Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use skills-that-thrill:subagent-driven-development or skills-that-thrill:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Implement a globally available Zsh function `setupDirenvForGoogleCloudProject` in the dotfiles to automate per-repository Google Cloud project environment variables in `.envrc` and `.envrc.example` with direnv authorization.

**Architecture:** The helper function resides in `config/zsh/plugins/manjaro-cachy-os-kde-dotfiles/direnv.zsh` and is automatically sourced via Oh My Zsh custom plugins. It manages a delimited `# --- BEGIN GCP DIRENV CONFIG ---` block inside `.envrc` (with actual values) and `.envrc.example` (with non-secret placeholder values), ensures `.envrc` is excluded in `.gitignore` while `.envrc.example` is trackable, and runs `direnv allow`.

**Tech Stack:** Zsh / POSIX shell, direnv, gcloud CLI, gum / fzf (interactive picker).

**Spec Reference:** [Design Specification](../specs/2026-09-29-1215-gcp-direnv-setup-function-design.md)

## Global Constraints

- Primary function name: `setupDirenvForGoogleCloudProject`.
- Aliases: `setup-gcp-direnv`, `direnv-gcp`.
- Managed block delimiters: `# --- BEGIN GCP DIRENV CONFIG ---` and `# --- END GCP DIRENV CONFIG ---`.
- Managed environment variables: `GOOGLE_CLOUD_PROJECT`, `CLOUDSDK_CORE_PROJECT`, `GOOGLE_CLOUD_QUOTA_PROJECT`, `GOOGLE_VERTEX_LOCATION`, `GEMINI_LOCATION`.
- Default location: `europe-west1`.
- `.envrc.example` must contain non-secret placeholders (`your-gcp-project-id`) and remain committable to git.
- `.envrc` must be ignored in `.gitignore` if git is used.
- Must cleanly run `direnv allow` upon writing.

---

### Task 1: Managed Block Generator & Upsert Logic with Tests

**Files:**
- Create: `tests/test-direnv-gcp.sh`
- Modify: `config/zsh/plugins/manjaro-cachy-os-kde-dotfiles/direnv.zsh`

**Interfaces:**
- Produces: `_direnv_gcp_upsert_block <file> <project_id> <location>`, `_direnv_gcp_render_block <project_id> <location>`

- [ ] **Step 1: Write the failing test for block upsert in `.envrc` and `.envrc.example`**

Create `tests/test-direnv-gcp.sh`:
```bash
#!/usr/bin/env bash
set -eo pipefail

TEST_TMPDIR="$(mktemp -d)"
trap 'rm -rf "$TEST_TMPDIR"' EXIT

SOURCE_SCRIPT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)/config/zsh/plugins/manjaro-cachy-os-kde-dotfiles/direnv.zsh"
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
```
Make executable: `chmod +x tests/test-direnv-gcp.sh`

- [ ] **Step 2: Run test to verify it fails**

Run: `bash tests/test-direnv-gcp.sh`  
Expected: FAIL with `_direnv_gcp_upsert_block: command not found`

- [ ] **Step 3: Implement `_direnv_gcp_render_block` and `_direnv_gcp_upsert_block`**

Add to `config/zsh/plugins/manjaro-cachy-os-kde-dotfiles/direnv.zsh`:
```bash
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
        # Ensure file ends with newline before appending
        [ -z "$(tail -c 1 "$target_file")" ] || echo ""
        echo ""
      fi
      printf "%s\n" "$block"
    } >> "$target_file"
  fi
}
```

- [ ] **Step 4: Run test to verify it passes**

Run: `bash tests/test-direnv-gcp.sh`  
Expected: PASS with "All Task 1 tests passed!"

- [ ] **Step 5: Commit changes**

```bash
git add tests/test-direnv-gcp.sh config/zsh/plugins/manjaro-cachy-os-kde-dotfiles/direnv.zsh
git commit -m "feat(direnv): add GCP block rendering and idempotent upsert functions"
```

---

### Task 2: Implement Complete `setupDirenvForGoogleCloudProject` with Discovery, Git Safeguards, and Direnv Allow

**Files:**
- Modify: `config/zsh/plugins/manjaro-cachy-os-kde-dotfiles/direnv.zsh`
- Modify: `tests/test-direnv-gcp.sh`

**Interfaces:**
- Consumes: `_direnv_gcp_upsert_block`
- Produces: `setupDirenvForGoogleCloudProject [PROJECT_ID] [LOCATION]`, aliases `setup-gcp-direnv`, `direnv-gcp`

- [ ] **Step 1: Add tests for `setupDirenvForGoogleCloudProject` covering gitignore and location overrides**

Extend `tests/test-direnv-gcp.sh` with Test 3 & Test 4:
```bash
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
  type setup-gcp-direnv &>/dev/null || alias setup-gcp-direnv &>/dev/null || { echo "FAIL: setup-gcp-direnv alias missing"; exit 1; }
  type direnv-gcp &>/dev/null || alias direnv-gcp &>/dev/null || { echo "FAIL: direnv-gcp alias missing"; exit 1; }
  echo "PASS: Aliases exist."
)
```

- [ ] **Step 2: Run test to verify it fails**

Run: `bash tests/test-direnv-gcp.sh`  
Expected: FAIL with `setupDirenvForGoogleCloudProject: command not found`

- [ ] **Step 3: Implement `setupDirenvForGoogleCloudProject` and aliases**

Add to `config/zsh/plugins/manjaro-cachy-os-kde-dotfiles/direnv.zsh`:
```bash
setupDirenvForGoogleCloudProject() {
  local project_id="$1"
  local location="${2:-europe-west1}"

  # 1. Resolve Project ID
  if [ -z "$project_id" ]; then
    if ! command -v gcloud &>/dev/null; then
      echo "\033[0;31mError:\033[0m 'gcloud' is not installed or not in PATH."
      echo "Please specify the project ID: setupDirenvForGoogleCloudProject <project-id> [location]"
      return 1
    fi

    echo "Fetching Google Cloud projects..."
    local projects_list
    projects_list=$(gcloud projects list --format="value(projectId,name)" 2>/dev/null)
    if [ -z "$projects_list" ]; then
      echo "\033[0;31mError:\033[0m No projects found or gcloud not authenticated."
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
      echo "Aborted: No project selected."
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
      echo "\033[0;32m[✔]\033[0m Added .envrc to .gitignore"
    fi
  fi

  # 4. Authorize direnv if installed
  if command -v direnv &>/dev/null; then
    direnv allow .
  else
    echo "\033[0;33m[!]\033[0m Note: 'direnv' command not found. Run 'direnv allow' once installed."
  fi

  echo "\033[0;32m[✔]\033[0m Google Cloud environment configured successfully!"
  echo "    Project:  $project_id"
  echo "    Location: $location"
  echo "    Files:    .envrc (authorized), .envrc.example (committable template)"
}

# Convenience aliases
alias setup-gcp-direnv="setupDirenvForGoogleCloudProject"
alias direnv-gcp="setupDirenvForGoogleCloudProject"
```

- [ ] **Step 4: Run test to verify it passes**

Run: `bash tests/test-direnv-gcp.sh`  
Expected: PASS with "All Task 1 tests passed!" and "All Task 2 tests passed!"

- [ ] **Step 5: Commit changes**

```bash
git add tests/test-direnv-gcp.sh config/zsh/plugins/manjaro-cachy-os-kde-dotfiles/direnv.zsh
git commit -m "feat(direnv): implement setupDirenvForGoogleCloudProject with git safeguards and aliases"
```

---

### Task 3: Interactive Zsh Sourcing & Documentation Verification

**Files:**
- Modify: `README.md`
- Verify: `config/zsh/plugins/manjaro-cachy-os-kde-dotfiles/manjaro-cachy-os-kde-dotfiles.plugin.zsh`

- [ ] **Step 1: Verify sourcing in an interactive Zsh subshell**

Run:
```bash
zsh -c 'source config/zsh/plugins/manjaro-cachy-os-kde-dotfiles/manjaro-cachy-os-kde-dotfiles.plugin.zsh && which setupDirenvForGoogleCloudProject'
```
Expected: Outputs function definition without any syntax errors.

- [ ] **Step 2: Update documentation in `README.md`**

Add documentation under the Direnv section in `README.md` explaining `setupDirenvForGoogleCloudProject`, its aliases (`setup-gcp-direnv`, `direnv-gcp`), and how `.envrc` / `.envrc.example` are managed.

- [ ] **Step 3: Run the full test suite**

Run:
```bash
./tests/test-keepalive-utils.sh
./tests/test-direnv-gcp.sh
```
Expected: All tests PASS.

- [ ] **Step 4: Commit documentation updates**

```bash
git add README.md
git commit -m "docs: document setupDirenvForGoogleCloudProject helper function"
```
