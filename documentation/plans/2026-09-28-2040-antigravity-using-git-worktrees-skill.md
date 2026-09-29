# Antigravity-First Using Git Worktrees Skill Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use skills-that-thrill:subagent-driven-development or skills-that-thrill:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Adapt the `using-git-worktrees` skill in `skills-that-thrill` for Antigravity-First, enforcing a sibling directory worktree architecture (`my-project/main`, `my-project/feature-auth`), replacing forbidden standalone `cd` commands with `Cwd` configuration, and integrating interactive `ask_question` modals for consent and baseline failure handling.

**Architecture:**
1. Rewrite `skills/using-git-worktrees/SKILL.md` to define the sibling worktree directory structure under the project container, prohibit standalone `cd` in favor of tool `Cwd`, document Antigravity's native `Workspace: "share"` / `"branch"` modes for subagents, and prescribe `ask_question` for consent and error choices.
2. Verify symlink synchronization and ensure zero dangling `.worktrees/` references remain.

**Tech Stack:** Markdown, Bash, Git worktrees, Antigravity Customization Architecture.

## Global Constraints

- Sibling worktree structure is mandatory: worktrees sit side-by-side under the project root (`my-project/main`, `my-project/feature-branch`). Never nest `.worktrees/` inside the default worktree.
- Standalone `cd` is prohibited in Antigravity: instructions must direct agents to set `Cwd: "$WORKTREE_PATH"` on tool calls.
- Use `ask_question` for interactive decision points.

---

### Task 1: Rewrite `skills/using-git-worktrees/SKILL.md` for Antigravity-First

**Files:**
- Modify: `config/agents/plugins/skills-that-thrill/skills/using-git-worktrees/SKILL.md`

- [ ] **Step 1: Write the updated `SKILL.md` content**

Update `config/agents/plugins/skills-that-thrill/skills/using-git-worktrees/SKILL.md` with:
- Frontmatter (`name: using-git-worktrees`, description).
- Step 0: Detect Existing Isolation using `GIT_DIR`, `GIT_COMMON`, and submodule check.
  - If not isolated, prompt for consent via `ask_question`:
    - `(Recommended) Create an isolated worktree`
    - `Work in place on current branch`
- Step 1: Create Isolated Workspace:
  - 1a. Native Antigravity Subagent Workspace (`invoke_subagent` with `Workspace: "share"` or `"branch"`).
  - 1b. Git Worktree Fallback with Sibling Architecture:
    - Sibling directory structure (`my-project/main`, `my-project/<branch>`).
    - Path resolution: `PROJECT_ROOT=$(cd "$(git rev-parse --show-toplevel)/.." && pwd -P)` and `WORKTREE_PATH="$PROJECT_ROOT/$BRANCH_NAME"`.
    - Worktree addition: `git worktree add "$WORKTREE_PATH" -b "$BRANCH_NAME"`.
    - Harness compliance warning: never run `cd "$path"`; set `Cwd: "$WORKTREE_PATH"` on subsequent tool calls.
- Step 2: Project Setup (dependency installation in `Cwd: "$WORKTREE_PATH"`).
- Step 3: Verify Clean Baseline.
  - If baseline tests fail, prompt via `ask_question`:
    - `(Recommended) Investigate and fix baseline test failures`
    - `Proceed anyway despite baseline test failures`

- [ ] **Step 2: Verify `SKILL.md` for sibling architecture and no standalone `cd`**

Run:
```bash
grep -n "PROJECT_ROOT" config/agents/plugins/skills-that-thrill/skills/using-git-worktrees/SKILL.md
grep -n "\.worktrees" config/agents/plugins/skills-that-thrill/skills/using-git-worktrees/SKILL.md
grep -n -E "cd \"\\\$path\"|cd \"\\\$WORKTREE" config/agents/plugins/skills-that-thrill/skills/using-git-worktrees/SKILL.md
```
Expected: Matches found for `PROJECT_ROOT`, zero matches for `.worktrees`, zero matches for standalone `cd "$path"`.

---

### Task 2: End-to-End Verification & Symlink Check

**Files:**
- Verify: `~/.gemini/config/plugins/skills-that-thrill/skills/using-git-worktrees/`

- [ ] **Step 1: Verify symlink synchronization**

Run:
```bash
ls -la ~/.gemini/config/plugins/skills-that-thrill/skills/using-git-worktrees/
```
Expected: Reflects updated `SKILL.md`.

- [ ] **Step 2: Verify plugin-wide consistency**

Run:
```bash
git diff config/agents/plugins/skills-that-thrill/skills/using-git-worktrees/SKILL.md
```
Expected: Clean git diff matching design specification.
