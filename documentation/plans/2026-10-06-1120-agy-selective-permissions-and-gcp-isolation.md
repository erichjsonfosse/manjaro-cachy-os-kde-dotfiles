# Agy Selective Permission Sync & Google Cloud Project Isolation Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use skills-that-thrill:subagent-driven-development or skills-that-thrill:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Provide bidirectional command permission synchronization across Antigravity profiles while enforcing strict Google Cloud Project isolation and enabling shared ADC credentials.

**Architecture:** Maintain an independent `settings.json` file per profile, decoupling it from the master global `settings.json`. Synchronize only `permissions` (and non-conflicting UI preferences) between global and profile settings on startup and exit, export profile-scoped GCP environment variables, and symlink shared Google ADC credentials when present.

**Tech Stack:** Bash, `jq`, POSIX Shell, Git, Google Cloud CLI / ADC conventions.

**Spec Reference:** [Design Spec](../specs/2026-10-06-1120-agy-selective-permissions-and-gcp-isolation-design.md)

## Global Constraints

- Never use blanket staging (`git add .` or `git add -A`); stage exact file paths explicitly.
- Commit messages must strictly adhere to the Conventional Commits specification.
- Dedicated commits for documentation and implementation plans (`docs(...)`).
- Shell scripts must pass `shellcheck` with zero warnings.
- Preserve pre-existing code, helper functions, and comments when modifying `bin/agy`.

---

## Tasks

### Task 1: Test Suite for Selective Permissions & GCP Isolation

**Files:**
- Create: [`tests/test-agy-selective-permissions.sh`](../../tests/test-agy-selective-permissions.sh)

**Interfaces:**
- Consumes: Test environment sandbox with mock `ORIG_HOME` and mock `PROFILE_DIR`.
- Produces: Test runner asserting symlink breaking, permission unioning without `gcp` clobbering, profile-to-global writeback, and ADC symlink creation.

- [ ] **Step 1: Write the test script**

Create `tests/test-agy-selective-permissions.sh` testing:
1. Converting symlinked profile `settings.json` to a distinct real file.
2. Merging global permissions into profile `settings.json` while keeping profile `gcp.project` distinct.
3. Merging newly approved permissions from profile back to global on exit without altering global `gcp.project`.
4. Exporting `CLOUDSDK_CORE_PROJECT` and `GOOGLE_CLOUD_PROJECT` matching `.gcp.project`.
5. Linking `application_default_credentials.json` from `$ORIG_HOME/.config/gcloud` into `$PROFILE_DIR/.config/gcloud`.

- [ ] **Step 2: Run test to verify it fails (TDD Red step)**

Run: `bash tests/test-agy-selective-permissions.sh`
Expected: FAIL (functions or logic not yet present in `bin/agy`).

- [ ] **Step 3: Commit test suite**

```bash
git add tests/test-agy-selective-permissions.sh
git commit -m "test(agents): add test suite for agy selective permissions and gcp isolation"
```

---

### Task 2: Implement Selective Permission Synchronization & Standalone File Enforcement

**Files:**
- Modify: [`bin/agy:130-220`](../../bin/agy#L130-L220)

**Interfaces:**
- Consumes: `$ORIG_HOME/.gemini/antigravity-cli/settings.json`, `$PROFILE_DIR/.gemini/antigravity-cli/settings.json`.
- Produces: Functions `sync_global_permissions_to_profile` and `sync_profile_permissions_to_global`.

- [ ] **Step 1: Replace whole-file symlinking with standalone file enforcement**

In `bin/agy`:
- If `$PROF_SETTINGS` is a symlink, resolve its content, remove the symlink, and write it back as a real file.
- If `$PROF_SETTINGS` does not exist: create it with baseline non-conflicting preferences (e.g. `colorScheme`, `editor`) but without inheriting `.gcp` or `.trustedWorkspaces`.

- [ ] **Step 2: Implement selective permission merging using jq**

- Merge `permissions.allow`, `permissions.deny`, `permissions.ask` arrays from `$GLOBAL_SETTINGS` into `$PROF_SETTINGS` without modifying `.gcp` or `.trustedWorkspaces`.
- In the exit trap, merge any newly added permissions in `$PROF_SETTINGS` back into `$GLOBAL_SETTINGS`.

- [ ] **Step 3: Run test suite to verify partial pass**

Run: `bash tests/test-agy-selective-permissions.sh`
Expected: Permission sync and file decoupling tests PASS.

---

### Task 3: Implement Scoped GCP Environment Exports & ADC Credential Symlinking

**Files:**
- Modify: [`bin/agy:215-255`](../../bin/agy#L215-L255)

**Interfaces:**
- Consumes: `.gcp.project` and `.gcp.location` in `$PROF_SETTINGS`, `$ORIG_HOME/.config/gcloud/application_default_credentials.json`.
- Produces: Exported environment variables `CLOUDSDK_CORE_PROJECT`, `GOOGLE_CLOUD_PROJECT`, `GOOGLE_CLOUD_LOCATION`, and symlinked ADC file.

- [ ] **Step 1: Export scoped GCP environment variables**

Extract `.gcp.project` and `.gcp.location` from `$PROF_SETTINGS` if present:
- Export `CLOUDSDK_CORE_PROJECT` and `GOOGLE_CLOUD_PROJECT`.
- Export `GOOGLE_CLOUD_LOCATION`, `GOOGLE_VERTEX_LOCATION`, `GEMINI_LOCATION`.

- [ ] **Step 2: Symlink shared ADC credentials**

If `$ORIG_HOME/.config/gcloud/application_default_credentials.json` exists and `$PROFILE_DIR/.config/gcloud/application_default_credentials.json` does not exist:
- `mkdir -p "$PROFILE_DIR/.config/gcloud"`
- `ln -sfn "$ORIG_HOME/.config/gcloud/application_default_credentials.json" "$PROFILE_DIR/.config/gcloud/application_default_credentials.json"`

- [ ] **Step 3: Run test suite to verify all tests pass (TDD Green step)**

Run: `bash tests/test-agy-selective-permissions.sh`
Expected: ALL TESTS PASS.

- [ ] **Step 4: Run shellcheck on affected scripts**

Run: `shellcheck bin/agy tests/test-agy-selective-permissions.sh`
Expected: Zero warnings.

- [ ] **Step 5: Commit implementation**

```bash
git add bin/agy
git commit -m "feat(agents): implement selective permissions sync and gcp project isolation in agy"
```

---

### Task 4: Real Profile Verification & Reporting

**Files:**
- Inspect: `/home/erichjsonfosse/.local/share/agy/profiles/firmakonto-api/.gemini/antigravity-cli/settings.json`
- Inspect: `/home/erichjsonfosse/.local/share/agy/profiles/manjaro-cachy-os-kde-dotfiles/.gemini/antigravity-cli/settings.json`

- [ ] **Step 1: Verify existing profile settings.json files are standalone**
Confirm `firmakonto-api` maintains its `gcp.project: "firmakonto"` and `manjaro-cachy-os-kde-dotfiles` maintains `gcp.project: "gen-lang-client-0264501874"`.

- [ ] **Step 2: Dry-run profile launching**
Simulate `bin/agy` execution under test conditions to verify no errors or unintended mutations.

- [ ] **Step 3: Update task checklist artifact & present final summary**
