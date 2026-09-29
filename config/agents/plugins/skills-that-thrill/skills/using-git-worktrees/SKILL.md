---
name: using-git-worktrees
description: Use when starting feature work that needs isolation from current workspace or before executing implementation plans - ensures an isolated workspace exists via native tools or git worktree fallback
---

# Using Git Worktrees

## Overview

Ensure work happens in an isolated workspace. Prefer native subagent workspaces when delegating, or sibling git worktrees under the project container when working interactively.

**Core principle:** Detect existing isolation first. Then use native tools. Then fall back to git. Never fight the harness.

**Announce at start:** "I'm using the using-git-worktrees skill to set up an isolated workspace."

---

## Step 0: Detect Existing Isolation

**Before creating anything, check if you are already in an isolated workspace.**

```bash
GIT_DIR=$(cd "$(git rev-parse --git-dir)" 2>/dev/null && pwd -P)
GIT_COMMON=$(cd "$(git rev-parse --git-common-dir)" 2>/dev/null && pwd -P)
BRANCH=$(git branch --show-current)
```

**Submodule guard:** `GIT_DIR != GIT_COMMON` is also true inside git submodules. Before concluding "already in a worktree," verify you are not in a submodule:

```bash
# If this returns a path, you're in a submodule, not a worktree — treat as normal repo
git rev-parse --show-superproject-working-tree 2>/dev/null
```

**If `GIT_DIR != GIT_COMMON` (and not a submodule):** You are already in a linked worktree. Skip to Step 2 (Project Setup). Do NOT create another worktree.

Report with branch state:
- On a branch: "Already in isolated workspace at `<path>` on branch `<name>`."
- Detached HEAD: "Already in isolated workspace at `<path>` (detached HEAD, externally managed). Branch creation needed at finish time."

**If `GIT_DIR == GIT_COMMON` (or in a submodule):** You are in a normal repo checkout.

Check if the user has already indicated their worktree preference in your instructions. If not, ask for consent using `ask_question`:

```
question: "Would you like me to set up an isolated worktree? It protects your current branch from changes."
options:
  - "(Recommended) Create an isolated worktree"
  - "Work in place on current branch"
```

Honor any existing declared preference without asking. If the user declines consent, work in place and skip to Step 2.

---

## Step 1: Create Isolated Workspace

### 1a. Native Subagent Workspaces (preferred when delegating)

When delegating tasks to subagents via `invoke_subagent`, Antigravity provides native workspace isolation:
- `Workspace: "share"`: Shares the parent repository's object store (identical to git worktrees), allowing independent branching without duplicating storage.
- `Workspace: "branch"`: Clones/branches an isolated workspace directory from the parent.

Use native subagent workspace parameters whenever dispatching tasks.

### 1b. Sibling Git Worktree Fallback

When operating in the primary interactive session, create a linked worktree manually.

#### Sibling Directory Architecture

Worktrees must **never** be nested inside the default worktree (no `.worktrees/` inside `main/`). Instead, worktrees must sit as siblings under the project container directory:

```
my-project/
├── main/               <-- Default worktree
├── feature-auth/       <-- Linked worktree
└── hotfix-login/       <-- Linked worktree
```

#### Directory Resolution & Creation

```bash
# Determine sibling worktree path
TOPLEVEL=$(git rev-parse --show-toplevel)
BASENAME=$(basename "$TOPLEVEL")

# In standard container structures (my-project/main/), worktrees sit beside main/
if [ "$BASENAME" = "main" ] || [ "$BASENAME" = "master" ]; then
  PROJECT_ROOT=$(cd "$TOPLEVEL/.." && pwd -P)
else
  # Flat repository checkout: sibling directory beside repository root
  PROJECT_ROOT=$(cd "$TOPLEVEL/.." && pwd -P)
fi
WORKTREE_PATH="$PROJECT_ROOT/$BRANCH_NAME"

git worktree add "$WORKTREE_PATH" -b "$BRANCH_NAME"
```

#### Harness Compliance (No Standalone `cd`)

> [!CAUTION]
> **Antigravity Rule: NEVER propose a standalone `cd` command.**
> Antigravity tool invocations do not persist shell directory state across calls, and running `cd` across tool calls is strictly prohibited.
>
> **What to do instead:**
> - Set the tool parameter `Cwd: "$WORKTREE_PATH"` on subsequent tool calls (e.g. `run_command`).
> - For compound shell commands, wrap in a subshell: `(cd "$WORKTREE_PATH" && command)`.

---

## Step 2: Project Setup

Detect existing lockfiles and project tooling in `Cwd: "$WORKTREE_PATH"` to run the appropriate installation command.

> [!IMPORTANT]
> **Preserve Project Tooling:** Always inspect existing lockfiles first before installing dependencies. Never introduce a competing lockfile (e.g. do not generate a `package-lock.json` if `pnpm-lock.yaml` or `yarn.lock` is present, and do not invoke `poetry` if `uv.lock` is present).

```bash
# Node / JavaScript (inspect lockfiles first)
if [ -f pnpm-lock.yaml ]; then pnpm install;
elif [ -f yarn.lock ]; then yarn install;
elif [ -f bun.lockb ]; then bun install;
elif [ -f package-lock.json ] || [ -f package.json ]; then npm install;
fi

# Python (inspect lockfiles and environment managers)
if [ -f uv.lock ]; then uv sync;
elif [ -f poetry.lock ]; then poetry install;
elif [ -f Pipfile.lock ]; then pipenv install;
elif [ -f requirements.txt ]; then pip install -r requirements.txt;
fi

# Rust
if [ -f Cargo.toml ]; then cargo check || cargo build; fi

# Go
if [ -f go.mod ]; then go mod download; fi
```

---

## Step 3: Verify Clean Baseline

Run tests in `Cwd: "$WORKTREE_PATH"` to ensure workspace starts clean:

```bash
# Use project-appropriate command
npm test / cargo test / pytest / go test ./...
```

**If tests fail:**
Prompt the user via `ask_question`:
```
question: "Baseline tests failed with <N> failures in the new worktree. How would you like to proceed?"
options:
  - "(Recommended) Investigate and fix baseline test failures"
  - "Proceed anyway despite baseline test failures"
```

**If tests pass:** Report ready.

### Report

```
Worktree ready at <full-path>
Tests passing (<N> tests, 0 failures)
Ready to implement <feature-name>
```

---

## Quick Reference

| Situation | Action |
| :--- | :--- |
| **Already in linked worktree** | Skip creation (Step 0) |
| **In a submodule** | Treat as normal repo (Step 0 guard) |
| **Dispatching subagent** | Use native `Workspace: "share"` or `"branch"` |
| **Interactive worktree** | Create sibling directory at `PROJECT_ROOT/$BRANCH_NAME` |
| **Navigating into worktree** | Set tool parameter `Cwd: "$WORKTREE_PATH"`, never run standalone `cd` |
| **Baseline test failure** | Prompt via `ask_question` (Investigate vs Proceed) |
| **No package.json/Cargo.toml** | Skip dependency install |

---

## Common Rationalizations

| Excuse | Reality |
| :--- | :--- |
| **"I'll just create `.worktrees` inside the repo"** | Worktrees must be siblings under `PROJECT_ROOT` to avoid repo pollution. |
| **"I'll run `cd $WORKTREE_PATH`"** | Violates Antigravity rules. Set `Cwd: "$WORKTREE_PATH"` on tool calls. |
| **"I'm obviously not in a worktree"** | Run Step 0. Harness isolation and submodules can mislead eyeballing. |
| **"Baseline tests can wait"** | A dirty baseline makes every subsequent failure ambiguous. Run tests first. |
