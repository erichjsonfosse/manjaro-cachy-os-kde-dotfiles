# Antigravity-First Test-Driven Development Skill Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use skills-that-thrill:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Adapt the `test-driven-development` skill and its companion reference `writing-good-tests.md` for Antigravity-First, enforcing command execution safety (`run_command` with `Cwd`), defining standardized verification evidence, and integrating interactive `ask_question` dialogs for testing dilemmas.

**Architecture:**
1. Polish `skills/test-driven-development/writing-good-tests.md` to remove awkward phrasing and preserve core test honesty principles.
2. Rewrite `skills/test-driven-development/SKILL.md` to enforce the Iron Law, Red-Green-Refactor, `Cwd` command safety, structured RED/GREEN evidence, and `ask_question` escalations.
3. Verify symlink synchronization and ensure clean execution.

**Tech Stack:** Markdown, Bash, Antigravity Customization Architecture (`run_command` with `Cwd`, `ask_question`).

## Global Constraints

- Preserve the Iron Law: `NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST`.
- Never propose a standalone `cd` command across tool calls; always specify `Cwd: "$WORKTREE_PATH"` on `run_command` or run in subshells `(cd "$WORKTREE_PATH" && ...)`.
- Use `ask_question` for interactive resolution of testing dilemmas.

---

### Task 1: Polish `writing-good-tests.md`

**Files:**
- Modify: `config/agents/plugins/skills-that-thrill/skills/test-driven-development/writing-good-tests.md`

- [ ] **Step 1: Polish content and wording**

Clean up lines with awkward phrasing (e.g. "your human partner's correction:", "your human partner's question:") and align with clean, professional prose while retaining all guidelines on:
- Naming the break (bug, not decision)
- Hand-derived literals (no mirror assertions)
- Exercising the real thing (no mock assertions)
- Mutation check

- [ ] **Step 2: Verify formatting**

Inspect the updated file to confirm clean markdown formatting.

---

### Task 2: Rewrite `skills/test-driven-development/SKILL.md` for Antigravity-First

**Files:**
- Modify: `config/agents/plugins/skills-that-thrill/skills/test-driven-development/SKILL.md`

- [ ] **Step 1: Rewrite `SKILL.md`**

Update `config/agents/plugins/skills-that-thrill/skills/test-driven-development/SKILL.md` with:
- Frontmatter (`name: test-driven-development`, description).
- The Iron Law: `NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST`.
- Red-Green-Refactor Cycle with clear step instructions.
- Antigravity Command Safety:
  - Run test commands via `run_command` with `Cwd: "$WORKTREE_PATH"` parameter.
  - Multi-stack examples: JS/TS (`npm test`, `vitest`), Python (`pytest`), Rust (`cargo test`), Go (`go test`), Bash (`bats`).
- Standardized Verification Evidence:
  - RED Evidence: exact command (with `Cwd`), failing output excerpt showing missing behavior.
  - GREEN Evidence: exact command (with `Cwd`), passing output summary showing pristine output.
- Interactive Dilemma Resolution (`ask_question`):
  - Modals for testing roadblocks (untested legacy code, external boundary dilemmas, mock vs integration decisions).

- [ ] **Step 2: Verify `SKILL.md` content**

Ensure no Claude-specific artifacts or broken formatting.

---

### Task 3: End-to-End Verification & Symlink Check

**Files:**
- Verify: `~/.gemini/config/plugins/skills-that-thrill/skills/test-driven-development/`

- [ ] **Step 1: Verify symlink synchronization**

Run:
```bash
ls -la ~/.gemini/config/plugins/skills-that-thrill/skills/test-driven-development/
```
Expected: Reflects all updated files.

- [ ] **Step 2: Verify git status**

Run:
```bash
git status --short config/agents/plugins/skills-that-thrill/skills/test-driven-development/
```
Expected: Shows modified `SKILL.md` and `writing-good-tests.md`.
