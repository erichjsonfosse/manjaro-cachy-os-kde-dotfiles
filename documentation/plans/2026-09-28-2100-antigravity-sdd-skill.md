# Antigravity-First Subagent-Driven Development Skill Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use skills-that-thrill:subagent-driven-development or skills-that-thrill:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Adapt the `subagent-driven-development` skill and its prompt templates for Antigravity-First, integrating native `invoke_subagent` execution, dual-layer progress tracking (Task Artifact + markdown `ledger.md`), interactive `ask_question` conflict escalations, and standardized `documentation/plans/` paths.

**Architecture:**
1. Update `implementer-prompt.md`, `task-reviewer-prompt.md`, and `re-review-prompt.md` to document Antigravity `invoke_subagent` syntax and standardized paths.
2. Rewrite `skills/subagent-driven-development/SKILL.md` to describe Antigravity subagent dispatching, reactive wakeup (zero polling), dual-layer tracking with `ledger.md`, and `ask_question` dialogs for plan conflict/breaker tripping.
3. Verify symlink synchronization and ensure zero dangling references remain.

**Tech Stack:** Markdown, Bash, Antigravity Customization Architecture (`invoke_subagent`, Task Artifacts, `ask_question`).

## Global Constraints

- Never poll in a loop while waiting for subagents; Antigravity uses reactive wakeup.
- Use `documentation/plans/` and `documentation/specs/` for all documentation links.
- Use `ledger.md` (Markdown format) for the project-local workspace ledger.

---

### Task 1: Update Prompt Templates

**Files:**
- Modify: `config/agents/plugins/skills-that-thrill/skills/subagent-driven-development/implementer-prompt.md`
- Modify: `config/agents/plugins/skills-that-thrill/skills/subagent-driven-development/task-reviewer-prompt.md`
- Modify: `config/agents/plugins/skills-that-thrill/skills/subagent-driven-development/re-review-prompt.md`

- [ ] **Step 1: Update `implementer-prompt.md`**

Add Antigravity `invoke_subagent` dispatch example:
```json
{
  "Subagents": [
    {
      "TypeName": "self",
      "Role": "Task Implementer",
      "Prompt": "Detailed prompt...",
      "Model": "inherit",
      "Workspace": "inherit"
    }
  ]
}
```
Update brief and report paths to reflect markdown conventions and `documentation/plans/`.

- [ ] **Step 2: Update `task-reviewer-prompt.md`**

Add Antigravity `invoke_subagent` dispatch example:
```json
{
  "Subagents": [
    {
      "TypeName": "research",
      "Role": "Task Reviewer",
      "Prompt": "Review prompt...",
      "Model": "inherit",
      "Workspace": "inherit"
    }
  ]
}
```
Update plan and spec paths to `documentation/plans/` and `documentation/specs/`.

- [ ] **Step 3: Update `re-review-prompt.md`**

Add Antigravity `invoke_subagent` dispatch example (`TypeName: "research"`, `Model: "inherit"`).

---

### Task 2: Rewrite `skills/subagent-driven-development/SKILL.md` for Antigravity-First

**Files:**
- Modify: `config/agents/plugins/skills-that-thrill/skills/subagent-driven-development/SKILL.md`

- [ ] **Step 1: Rewrite `SKILL.md` content**

Update `config/agents/plugins/skills-that-thrill/skills/subagent-driven-development/SKILL.md` with:
- Frontmatter (`name: subagent-driven-development`, description).
- Antigravity dispatching (`invoke_subagent`, `send_message`, `manage_subagents`).
- Reactive Wakeup: stop calling tools after dispatch; do NOT poll or sleep in a loop.
- Dual-Layer Tracking:
  - User-facing Task Artifact in `<appDataDir>/brain/<conversation-id>/sdd_progress_<slug>.md`.
  - Workspace `ledger.md` in `.skills-that-thrill/sdd/<slug>/ledger.md`.
- Interactive Conflict Resolution (`ask_question`):
  - Reviewer findings conflict with plan text: ask human partner via `ask_question`.
  - Breaker trips after 5 fix rounds: ask human partner via `ask_question`.
- Sibling worktree and path standards (`documentation/plans/`, `documentation/specs/`).

- [ ] **Step 2: Verify `SKILL.md` for zero Claude models and zero dangling old paths**

Run:
```bash
grep -n -E "claude-|Sonnet|Haiku|Opus" config/agents/plugins/skills-that-thrill/skills/subagent-driven-development/SKILL.md
grep -n "documentation/skills-that-thrill/plans" config/agents/plugins/skills-that-thrill/skills/subagent-driven-development/SKILL.md
grep -n "ledger\.txt" config/agents/plugins/skills-that-thrill/skills/subagent-driven-development/SKILL.md
```
Expected: Zero matches across all checks.

---

### Task 3: End-to-End Verification & Symlink Check

**Files:**
- Verify: `~/.gemini/config/plugins/skills-that-thrill/skills/subagent-driven-development/`

- [ ] **Step 1: Verify symlink synchronization**

Run:
```bash
ls -la ~/.gemini/config/plugins/skills-that-thrill/skills/subagent-driven-development/
```
Expected: Reflects all updated files.

- [ ] **Step 2: Verify plugin-wide consistency**

Run:
```bash
git status --short config/agents/plugins/skills-that-thrill/skills/subagent-driven-development/
```
Expected: All template and skill modifications clean and verified.
