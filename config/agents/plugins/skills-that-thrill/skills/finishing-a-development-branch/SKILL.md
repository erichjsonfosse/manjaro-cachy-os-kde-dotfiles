---
name: finishing-a-development-branch
description: Use when implementation is complete, all tests pass, and you need to decide how to integrate the work
---

# Finishing a Development Branch

## Overview

**Core principle:** Verify tests → Detect environment → Present options via `ask_question` → Execute choice → Clean up.

**Announce at start:** "I'm using the finishing-a-development-branch skill to complete this work."

---

## Step 1: Verify Tests

Before presenting integration options, invoke `skills-that-thrill:verification-before-completion`. Run the full verification suite (tests, linters, build) using `run_command` with `Cwd: "$WORKTREE_PATH"`.

**If tests fail:** Report the failures and stop immediately. The integration menu is gated behind a verified green suite:

```
Tests failing (<N> failures). Must fix before completing:

[Show failures]
```

**If tests pass with fresh evidence:** Continue to Step 2.

---

## Step 2: Detect Environment

Detect whether the workspace is a linked sibling worktree and determine the repository root:

```bash
GIT_DIR=$(git rev-parse --git-dir)
GIT_COMMON=$(git rev-parse --git-common-dir)
WORKTREE_PATH=$(git rev-parse --show-toplevel)
MAIN_ROOT=$(git -C "$GIT_COMMON/.." rev-parse --show-toplevel)
```

> [!IMPORTANT]
> **Antigravity Execution Safety (`Cwd`):**
> Standalone `cd` across tool calls does not persist in Antigravity.
> Always pass `Cwd: "$MAIN_ROOT"` or `Cwd: "$WORKTREE_PATH"` explicitly to `run_command`.

This determines the options menu and cleanup behavior:

| State                                  | Menu                         | Cleanup                                  |
|:---------------------------------------|:-----------------------------|:-----------------------------------------|
| `GIT_DIR == GIT_COMMON` (normal repo)  | Standard 3 options           | No worktree to clean up                  |
| `GIT_DIR != GIT_COMMON`, named branch  | Standard 3 options           | Linked worktree removal from `MAIN_ROOT` |
| `GIT_DIR != GIT_COMMON`, detached HEAD | Reduced 2 options (no merge) | Linked worktree removal from `MAIN_ROOT` |

---

## Step 3: Determine Base Branch

The base branch is whatever this work branched from — usually named in the implementation plan, conversation, or git tracking (`git rev-parse --abbrev-ref @{u}`).

If not already known with certainty, ask your human partner to confirm:
> "This branch split from `<base-guess>` — is that correct?"

---

## Step 4: Present Options via `ask_question`

Present the decision using the `ask_question` tool.

**Standard repository or named-branch worktree:**
```
question: "Implementation complete and verified. What would you like to do with branch <branch-name>?"
options:
  - "Push and create a Pull Request"
  - "Keep the branch as-is (I'll handle it later)"
  - "Merge back to <base-branch> locally"
```

**Detached HEAD worktree:**
```
question: "Implementation complete and verified on detached HEAD. What would you like to do?"
options:
  - "Push as new branch and create a Pull Request"
  - "Keep as-is (I'll handle it later)"
```

Wait for your human partner's response before proceeding. Discarding work happens ONLY in response to an explicit request.

---

## Step 5: Execute Choice

### Option 1: Push and Create PR

1. Push the branch to the remote:
   ```bash
   # In Cwd: "$WORKTREE_PATH"
   git push -u origin <feature-branch>
   ```
   *(From a detached HEAD: `git push origin HEAD:refs/heads/<new-branch>`)*

2. Create the pull/merge request:
   - Use the GitHub CLI (`gh pr create` with `Cwd: "$WORKTREE_PATH"`), or
   - Call the GitHub MCP server (`create_pull_request`).
   - Follow the repository's PR template and provide a clear summary with linked specs/plans.

3. **Preserve the worktree:** Keep the worktree in place so your human partner can review code and address PR comments.

---

### Option 2: Keep As-Is

Report:
> "Keeping branch `<feature-branch>`. Worktree preserved at `[<path>](file:///<path>)`."

Leave the branch and worktree untouched.

---

### Option 3: Merge Locally

1. **Verify Main Root Cleanliness:**
   Before checking out `<base-branch>`, verify that `MAIN_ROOT` has no uncommitted changes:
   ```bash
   # In Cwd: "$MAIN_ROOT"
   git status --porcelain
   ```
   If the output is non-empty, STOP and notify your human partner to stash or commit their changes before switching branches.

2. **Execute Merge Safely:**
   Execute the merge using `run_command` with `Cwd: "$MAIN_ROOT"` (never standalone `cd`):

```bash
# In Cwd: "$MAIN_ROOT"
git checkout <base-branch>
git pull
git merge <feature-branch>
```

**Verify tests on the merged result:**
Run the project's test suite with `Cwd: "$MAIN_ROOT"`.

- **If merged tests fail:** STOP immediately. Leave the feature branch and worktree intact. Nothing has been pushed, so the merge is local and recoverable. Investigate and resolve the regression.
- **If merged tests pass:** Proceed to Step 6 to clean up the worktree, then delete the branch:
  ```bash
  # In Cwd: "$MAIN_ROOT"
  git branch -d <feature-branch>
  ```

---

### If your human partner asks to discard the work

This path exists **only** in response to an explicit request to discard the work. Confirm first:

```
This will permanently delete:
- Branch <feature-branch>
- All commits: <commit-list>
- Worktree at <path>

Type 'discard' to confirm.
```

Wait for the exact word `discard`. When confirmed:
1. Clean up the worktree (Step 6).
2. Force delete the branch from `Cwd: "$MAIN_ROOT"`:
   ```bash
   git branch -D <feature-branch>
   ```

---

## Step 6: Cleanup Workspace

**Runs for Option 3 (Merge Locally) and confirmed discards.** Options 1 and 2 always preserve the worktree.

1. **If `GIT_DIR == GIT_COMMON`:** Main repository; no worktree to clean up.
2. **If `GIT_DIR != GIT_COMMON`:** Linked sibling worktree (`my-project/<branch>`). Remove it from `Cwd: "$MAIN_ROOT"`:
   ```bash
   # In Cwd: "$MAIN_ROOT"
   git worktree remove "$WORKTREE_PATH"
   git worktree prune
   ```

---

## Quick Reference

| Option                          | Merge | Push | Keep Worktree | Cleanup Branch |
|:--------------------------------|:-----:|:----:|:-------------:|:--------------:|
| 1. Create PR                    |   -   | yes  |      yes      |       -        |
| 2. Keep as-is                   |   -   |  -   |      yes      |       -        |
| 3. Merge locally                |  yes  |  -   |       -       |      yes       |
| Discard (explicit request only) |   -   |  -   |       -       |  yes (force)   |

---

## Common Rationalizations

| Excuse                                         | Reality                                                                  |
|:-----------------------------------------------|:-------------------------------------------------------------------------|
| "Tests passed earlier this session"            | Run the suite freshly on the exact tree you are about to integrate.      |
| "They obviously want it merged"                | Integration is your human partner's decision. Present the menu and wait. |
| "I'll offer to discard it"                     | Discard happens only when explicitly requested.                          |
| "'Yeah, get rid of it' counts as confirmation" | Only the typed word `discard` authorizes deletion.                       |
| "PR is up, so remove worktree"                 | PR feedback is iterated in that worktree. Keep it.                       |
| "Using naked `cd` in commands"                 | Antigravity shells do not persist `cd`. Always pass `Cwd: "$MAIN_ROOT"`. |
| "Merged test failure is flaky"                 | Failing merged tests stop everything. Worktree and branch stay intact.   |
| "The base branch is obviously main"            | Confirm the fork point. Merging into the wrong base is costly to undo.   |
