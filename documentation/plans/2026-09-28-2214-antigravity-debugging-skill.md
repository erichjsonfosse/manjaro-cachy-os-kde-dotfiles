# Antigravity-First Systematic Debugging Skill Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use skills-that-thrill:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Adapt the `systematic-debugging` skill and its supporting references (`condition-based-waiting.md`, `defense-in-depth.md`, `root-cause-tracing.md`) for Antigravity-First, enforcing command execution safety (`run_command` with `Cwd`), prohibiting background `sleep` hacks, and integrating interactive `ask_question` dialogs for architectural roadblocks and irreproducible bugs.

**Architecture:**
1. Polish supporting references (`condition-based-waiting.md`, `defense-in-depth.md`, `root-cause-tracing.md`) for clarity and harness tool alignment.
2. Rewrite `skills/systematic-debugging/SKILL.md` enforcing the Iron Law, the Four Phases, `Cwd` command safety, no-sleep rules, and interactive `ask_question` escalation gates.
3. Verify symlink synchronization and ensure zero dangling references remain.

**Tech Stack:** Markdown, Bash, Antigravity Customization Architecture (`run_command` with `Cwd`, `ask_question`).

## Global Constraints

- Preserve the Iron Law: `NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST`.
- Never propose a standalone `cd` command across tool calls; always specify `Cwd: "$WORKTREE_PATH"` on `run_command` or run in subshells `(cd "$WORKTREE_PATH" && ...)`.
- Never run background `sleep` commands; use condition-based waiting or the scheduler tool.
- Use `ask_question` for interactive escalation when irreproducible or when 3+ fix attempts fail.

---

### Task 1: Polish Supporting Guides

**Files:**
- Modify: `config/agents/plugins/skills-that-thrill/skills/systematic-debugging/condition-based-waiting.md`
- Modify: `config/agents/plugins/skills-that-thrill/skills/systematic-debugging/defense-in-depth.md`
- Modify: `config/agents/plugins/skills-that-thrill/skills/systematic-debugging/root-cause-tracing.md`

- [ ] **Step 1: Polish `condition-based-waiting.md`**

Reinforce that agents must never run background `sleep` commands in terminal sessions, and document clean condition-based polling for async test operations.

- [ ] **Step 2: Polish `defense-in-depth.md` and `root-cause-tracing.md`**

Ensure clean formatting, verify code snippets avoid bad path patterns, and verify Mermaid/dot diagrams render cleanly.

---

### Task 2: Rewrite `skills/systematic-debugging/SKILL.md` for Antigravity-First

**Files:**
- Modify: `config/agents/plugins/skills-that-thrill/skills/systematic-debugging/SKILL.md`

- [ ] **Step 1: Rewrite `SKILL.md`**

Update `config/agents/plugins/skills-that-thrill/skills/systematic-debugging/SKILL.md` with:
- Frontmatter (`name: systematic-debugging`, description).
- The Iron Law: `NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST`.
- Phase 1: Root Cause Investigation
  - Stack traces, reproduction, boundary instrumentation across layers, backward data flow tracing.
  - Harness Safety: Run diagnostic/reproduction commands with `Cwd: "$WORKTREE_PATH"` (no standalone `cd`).
- Phase 2: Pattern Analysis
  - Compare with working examples, identify differences.
- Phase 3: Hypothesis and Testing
  - Form single specific hypothesis, test minimally (one variable at a time).
- Phase 4: Implementation
  - Write failing test first via `skills-that-thrill:test-driven-development`.
  - Implement focused root-cause fix.
  - Verify via `skills-that-thrill:verification-before-completion`.
- Interactive Escalation Gates via `ask_question`:
  - Irreproducibility gate: prompt user if bug cannot be reproduced.
  - Architectural Questioning Gate: if 3 fixes fail, STOP and prompt user via `ask_question` (re-evaluate architecture vs more logging vs design change).

- [ ] **Step 2: Verify `SKILL.md` content**

Ensure no Claude-specific artifacts or broken formatting.

---

### Task 3: End-to-End Verification & Symlink Check

**Files:**
- Verify: `~/.gemini/config/plugins/skills-that-thrill/skills/systematic-debugging/`

- [ ] **Step 1: Verify symlink synchronization**

Run:
```bash
ls -la ~/.gemini/config/plugins/skills-that-thrill/skills/systematic-debugging/
```
Expected: Reflects all updated files.

- [ ] **Step 2: Verify git status**

Run:
```bash
git status --short config/agents/plugins/skills-that-thrill/skills/systematic-debugging/
```
Expected: Shows modified files.
