# Antigravity-First Executing Plans Skill Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use skills-that-thrill:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Adapt the `executing-plans` skill for Antigravity-First, establishing structured Task Artifact tracking, interactive review checkpoints via `ask_question` after completed tasks, strict harness command safety (no standalone `cd`), and standardized `documentation/plans/` paths.

**Architecture:**
1. Rewrite `skills/executing-plans/SKILL.md` to guide inline execution with Antigravity Task Artifacts, interactive `ask_question` checkpoints, sub-skill references, and strict `Cwd` usage.
2. Verify symlink synchronization and ensure zero dangling references remain.

**Tech Stack:** Markdown, Bash, Antigravity Customization Architecture (Task Artifacts, `ask_question`, tool `Cwd`).

## Global Constraints

- Never propose a standalone `cd` command across tool calls; use `Cwd: "$WORKTREE_PATH"` on `run_command` or run in subshells `(cd "$WORKTREE_PATH" && ...)`.
- Use `documentation/plans/` and `documentation/specs/` for all documentation links.
- Use `ask_question` for interactive review checkpoints and blocker escalations.

---

### Task 1: Rewrite `skills/executing-plans/SKILL.md` for Antigravity-First

**Files:**
- Modify: `config/agents/plugins/skills-that-thrill/skills/executing-plans/SKILL.md`

- [ ] **Step 1: Rewrite `SKILL.md`**

Update `config/agents/plugins/skills-that-thrill/skills/executing-plans/SKILL.md` with:
- Frontmatter (`name: executing-plans`, description).
- Overview: In-session inline execution of written plans with human review checkpoints.
- Step 1: Load and Review Plan
  - Sibling worktree verification via `skills-that-thrill:using-git-worktrees`.
  - Read plan from `documentation/plans/` and spec from `documentation/specs/`.
  - Create user-facing Task Artifact at `<appDataDir>/brain/<conversation-id>/executing_<plan_slug>_tasks.md` using `write_to_file` with `ArtifactMetadata`.
- Step 2: Execute Tasks (Per-Task Loop)
  - Mark task in progress in Task Artifact (`replace_file_content` to `- [/]`).
  - Follow TDD (`skills-that-thrill:test-driven-development`).
  - Run verification commands using `run_command` with `Cwd: "$WORKTREE_PATH"` (no standalone `cd`).
  - Mark task complete in Task Artifact (`replace_file_content` to `- [x]`).
  - **Interactive Checkpoint:** Prompt user after completing each task/milestone via `ask_question`:
    - `(Recommended) Proceed to Task N+1`
    - `Review Task N code changes before proceeding`
    - `Request adjustments to Task N`
- Step 3: Complete Development
  - Use `skills-that-thrill:finishing-a-development-branch`.
- Blocker and Error Escalation
  - Stop immediately when blocked, prompt via `ask_question`.

- [ ] **Step 2: Verify `SKILL.md` for zero dangling old paths or forbidden patterns**

Run:
```bash
grep -n "documentation/skills-that-thrill/plans" config/agents/plugins/skills-that-thrill/skills/executing-plans/SKILL.md || true
```
Expected: Zero matches.

---

### Task 2: End-to-End Verification & Symlink Check

**Files:**
- Verify: `~/.gemini/config/plugins/skills-that-thrill/skills/executing-plans/`

- [ ] **Step 1: Verify symlink synchronization**

Run:
```bash
ls -la ~/.gemini/config/plugins/skills-that-thrill/skills/executing-plans/
```
Expected: Points cleanly to updated file.

- [ ] **Step 2: Verify git status**

Run:
```bash
git status --short config/agents/plugins/skills-that-thrill/skills/executing-plans/
```
Expected: Shows modified `SKILL.md`.
