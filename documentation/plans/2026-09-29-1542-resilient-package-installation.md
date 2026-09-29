# Resilient Package Installation & Failure Logging Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use skills-that-thrill:subagent-driven-development or skills-that-thrill:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Prevent dotfiles installation from aborting when a single package fails, isolate and install surviving packages via fallback, and record all failed packages to a dedicated log with an end-of-run summary.

**Architecture:** Introduce `installPackagesResiliently` in `utilities/during-install/utilities.sh` which executes an optimistic batch install (`pacman -S ...` or `paru -Syu ...`), and upon batch error, falls back to individual package retries while appending failed packages to `$FAILED_PACKAGES_LOG`. Integrate with `pacman-packages.sh`, `aur-packages.sh`, and `init.sh` summary reporting.

**Tech Stack:** Bash, Pacman, Paru, Gum (styling).

**Spec Reference:** [Design Spec](file:///home/erichjsonfosse/projects/manjaro-cachy-os-kde-dotfiles/main/documentation/specs/2026-09-29-1535-resilient-package-installation-design.md)

## Global Constraints
- Target log file: `$BASEDIR/failed-packages.log` (git-ignored).
- Fast path: Must install via single batch transaction when all packages succeed.
- Resilience: Must never return non-zero exit code from `installPackagesResiliently` to protect `init.sh` `set -eo pipefail` subshells.
- Lock safety: Always invoke `waitForPacmanLock` before batch and individual transactions.

---

### Task 1: Environment Variable Setup and Gitignore

**Files:**
- Modify: `set-variables.sh`
- Modify: `.gitignore`

**Interfaces:**
- Consumes: `BASEDIR` from `set-variables.sh`
- Exposes: `FAILED_PACKAGES_LOG` environment variable

- [ ] **Step 1:** Modify `set-variables.sh` to define and export `FAILED_PACKAGES_LOG="$BASEDIR/failed-packages.log"`.
- [ ] **Step 2:** Modify `.gitignore` to add `failed-packages.log`.
- [ ] **Step 3:** Verify variable is exported and `.gitignore` ignores the log file via `git check-ignore failed-packages.log`.
- [ ] **Step 4:** Commit changes with message `feat(core): define FAILED_PACKAGES_LOG and update gitignore`.

---

### Task 2: Implement and Test `installPackagesResiliently` Helper

**Files:**
- Test: `tests/test-resilient-package-installer.sh`
- Modify: `utilities/during-install/utilities.sh`

**Interfaces:**
- Function: `installPackagesResiliently <tool> [pkg1 pkg2 ...]`
- Output: Logs success/warnings to console, appends `[<tool>] <pkg>` to `$FAILED_PACKAGES_LOG` on failure. Always returns exit code 0.

- [ ] **Step 1:** Create `tests/test-resilient-package-installer.sh` containing test cases:
  1. Empty package list (returns 0).
  2. Batch success (executes batch command, records 0 failures).
  3. Batch failure with individual fallback (simulates 1 failing package among 3; verifies 2 installed, 1 recorded in `$FAILED_PACKAGES_LOG`, function returns 0).
- [ ] **Step 2:** Run `bash tests/test-resilient-package-installer.sh` to confirm test failure before implementation.
- [ ] **Step 3:** Implement `installPackagesResiliently` in `utilities/during-install/utilities.sh`.
- [ ] **Step 4:** Run `bash tests/test-resilient-package-installer.sh` to confirm all assertions pass.
- [ ] **Step 5:** Commit changes with message `feat(install): implement installPackagesResiliently with batch fallback and logging`.

---

### Task 3: Integrate Resilient Installation in Pacman & AUR Scripts

**Files:**
- Modify: `install/pacman-packages.sh:147-152`
- Modify: `install/aur-packages.sh:38-42`

**Interfaces:**
- Calls: `installPackagesResiliently "pacman" "${packages[@]}"`
- Calls: `installPackagesResiliently "paru" "${packages[@]}"`

- [ ] **Step 1:** In `install/pacman-packages.sh`, replace raw `sudo pacman -S --needed --noconfirm "${packages[@]}"` with `installPackagesResiliently "pacman" "${packages[@]}"`.
- [ ] **Step 2:** In `install/aur-packages.sh`, replace raw `paru -Syu --needed --noconfirm "${packages[@]}"` with `installPackagesResiliently "paru" "${packages[@]}"`.
- [ ] **Step 3:** Verify syntax of both scripts via `bash -n install/pacman-packages.sh` and `bash -n install/aur-packages.sh`.
- [ ] **Step 4:** Commit changes with message `feat(install): integrate resilient package installation in pacman and aur scripts`.

---

### Task 4: Add End-of-Installation Summary to `init.sh`

**Files:**
- Modify: `init.sh:65-67, 118-124, 295-300`

**Interfaces:**
- Consumes: `$FAILED_PACKAGES_LOG`
- Renders: Prominent Gum summary banner before reboot prompt if failures exist.

- [ ] **Step 1:** Add `displayFailedPackagesSummary` step to `init.sh` before `promptForReboot` (or inside step 23 sequence).
- [ ] **Step 2:** Implement `displayFailedPackagesSummary()` to read `$FAILED_PACKAGES_LOG`, format each failed package line, and display clear remediation instructions.
- [ ] **Step 3:** Verify syntax of `init.sh` with `bash -n init.sh`.
- [ ] **Step 4:** Commit changes with message `feat(init): display failed packages summary before reboot prompt`.

---

### Task 5: Verification & Shellcheck Audit

**Files:**
- Test: All modified files (`init.sh`, `install/*.sh`, `utilities/during-install/utilities.sh`, `tests/*.sh`)

- [ ] **Step 1:** Run `shellcheck` across all touched shell scripts: `shellcheck -x set-variables.sh utilities/during-install/utilities.sh install/pacman-packages.sh install/aur-packages.sh init.sh tests/test-resilient-package-installer.sh`.
- [ ] **Step 2:** Run full test suite: `bash tests/test-keepalive-utils.sh` and `bash tests/test-resilient-package-installer.sh`.
- [ ] **Step 3:** Final git status and diff review.
