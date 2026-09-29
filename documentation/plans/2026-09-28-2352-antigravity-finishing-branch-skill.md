# Antigravity-First Finishing a Development Branch Skill Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use skills-that-thrill:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Adapt `finishing-a-development-branch` for Antigravity-First, establishing interactive `ask_question` integration dialogs (with `Merge back locally` placed last), sibling worktree detection and cleanup, and strict command execution safety (`run_command` with `Cwd` / no standalone `cd`).

**Architecture:**
1. Update `skills/finishing-a-development-branch/SKILL.md` with prerequisite verification, sibling worktree detection, `ask_question` menu ordering (PR first, keep second, merge last), and safe `Cwd: "$MAIN_ROOT"` merge/cleanup operations.
2. Verify symlink synchronization and ensure zero dangling references remain.

**Tech Stack:** Markdown, Bash, Antigravity Customization Architecture (`run_command` with `Cwd`, `ask_question`, GitHub MCP server).

## Global Constraints

- Never propose a standalone `cd` command across tool calls; always specify `Cwd: "$MAIN_ROOT"` or `Cwd: "$WORKTREE_PATH"` on `run_command` or run in subshells `(cd "$DIR" && ...)`.
- Require `verification-before-completion` before presenting any integration options.
- The options menu in `ask_question` must place `Merge back to <base-branch> locally` last.

---

### Task 1: Rewrite `skills/finishing-a-development-branch/SKILL.md`

**Files:**
- Modify: `config/agents/plugins/skills-that-thrill/skills/finishing-a-development-branch/SKILL.md`

- [ ] **Step 1: Rewrite `finishing-a-development-branch/SKILL.md`**

Update `config/agents/plugins/skills-that-thrill/skills/finishing-a-development-branch/SKILL.md` with:
- Frontmatter (`name: finishing-a-development-branch`, description).
- Overview & Core Principle.
- Step 1: Verify Tests via `skills-that-thrill:verification-before-completion` in `Cwd: "$WORKTREE_PATH"`.
- Step 2: Detect Environment (sibling worktree resolution: `GIT_DIR`, `GIT_COMMON`, `WORKTREE_PATH`, `MAIN_ROOT`).
- Step 3: Determine Base Branch.
- Step 4: Present Options via `ask_question`:
  1. `Push and create a Pull Request`
  2. `Keep the branch as-is (I'll handle it later)`
  3. `Merge back to <base-branch> locally`
- Step 5: Execute Choice:
  - Option 1: Push and Create PR (via `gh pr create` or GitHub MCP; keep worktree for review).
  - Option 2: Keep As-Is.
  - Option 3: Merge Locally (in `Cwd: "$MAIN_ROOT"`, verify merged tests, clean up worktree, delete branch).
  - Explicit Discard workflow (`discard` confirmation, `Cwd: "$MAIN_ROOT"`).
- Step 6: Cleanup Workspace (sibling worktree removal from `Cwd: "$MAIN_ROOT"`).
- Rationalizations & Red flags table.

- [ ] **Step 2: Verify `SKILL.md` content**

Ensure no Claude-specific artifacts or broken formatting.

---

### Task 2: End-to-End Verification & Symlink Check

**Files:**
- Verify: `~/.gemini/config/plugins/skills-that-thrill/skills/finishing-a-development-branch/`

- [ ] **Step 1: Verify symlink synchronization**

Run:
```bash
ls -la ~/.gemini/config/plugins/skills-that-thrill/skills/finishing-a-development-branch/
```
Expected: Reflects updated `SKILL.md`.

- [ ] **Step 2: Verify git status**

Run:
```bash
git status --short config/agents/plugins/skills-that-thrill/skills/finishing-a-development-branch/
```
Expected: Shows modified files.
