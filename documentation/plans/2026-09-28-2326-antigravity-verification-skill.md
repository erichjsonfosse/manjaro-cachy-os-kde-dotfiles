# Antigravity-First Verification Before Completion Skill Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use skills-that-thrill:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Adapt `verification-before-completion` for Antigravity-First, preserving the Iron Law (`NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE`), establishing command execution safety (`run_command` with `Cwd`), independent subagent verification, and an interactive `ask_question` escalation gate for verification failures.

**Architecture:**
1. Update `skills/verification-before-completion/SKILL.md` with Antigravity command safety (`Cwd: "$WORKTREE_PATH"`), independent subagent verification, and interactive `ask_question` escalation.
2. Verify symlink synchronization and ensure zero dangling references remain.

**Tech Stack:** Markdown, Bash, Antigravity Customization Architecture (`run_command` with `Cwd`, `ask_question`).

## Global Constraints

- Never propose a standalone `cd` command across tool calls; always specify `Cwd: "$WORKTREE_PATH"` on `run_command` or run in subshells `(cd "$WORKTREE_PATH" && ...)`.
- Maintain strict preservation of the Iron Law: zero completion claims without fresh verification evidence.
- Never trust subagent self-reported success; verify independently with `git diff` and fresh verification commands.

---

### Task 1: Rewrite `skills/verification-before-completion/SKILL.md`

**Files:**
- Modify: `config/agents/plugins/skills-that-thrill/skills/verification-before-completion/SKILL.md`

- [ ] **Step 1: Rewrite `verification-before-completion/SKILL.md`**

Update `config/agents/plugins/skills-that-thrill/skills/verification-before-completion/SKILL.md` with:
- Frontmatter (`name: verification-before-completion`, description).
- Overview & The Iron Law: `NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE`.
- The 5-Step Gate Function: Identify, Run, Read, Verify, Only Then.
- Antigravity Command Safety: `run_command` with `Cwd: "$WORKTREE_PATH"` (no standalone `cd`).
- Subagent Verification: coordinator independently verifies git diff and runs fresh verification commands in `Cwd` when subagents report completion via `invoke_subagent`.
- Red Flags & Rationalization Prevention tables.
- Interactive Escalation Gate (`ask_question`): structured decision dialog when verification fails.
- When to Apply.

- [ ] **Step 2: Verify `SKILL.md` content**

Ensure no Claude-specific artifacts or broken formatting.

---

### Task 2: End-to-End Verification & Symlink Check

**Files:**
- Verify: `~/.gemini/config/plugins/skills-that-thrill/skills/verification-before-completion/`

- [ ] **Step 1: Verify symlink synchronization**

Run:
```bash
ls -la ~/.gemini/config/plugins/skills-that-thrill/skills/verification-before-completion/
```
Expected: Reflects updated `SKILL.md`.

- [ ] **Step 2: Verify git status**

Run:
```bash
git status --short config/agents/plugins/skills-that-thrill/skills/verification-before-completion/
```
Expected: Shows modified files.
