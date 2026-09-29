# Antigravity-First Code Review Skills Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use skills-that-thrill:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Adapt `requesting-code-review` (including `code-reviewer.md`) and `receiving-code-review` for Antigravity-First, establishing native `invoke_subagent` reviewer dispatches with reactive wakeup, command execution safety (`run_command` with `Cwd`), standardized doc paths (`documentation/plans/YYYY-MM-DD-HHMM-...`), and interactive `ask_question` conflict escalation gates.

**Architecture:**
1. Update `skills/requesting-code-review/SKILL.md` and `skills/requesting-code-review/code-reviewer.md` with Antigravity `invoke_subagent` syntax, reactive wakeup, `Cwd` safety, and standard paths.
2. Update `skills/receiving-code-review/SKILL.md` with technical verification rules, sequential implementation, `ask_question` conflict resolution, and GitHub commenting options.
3. Verify symlink synchronization and ensure zero dangling references remain.

**Tech Stack:** Markdown, Bash, Antigravity Customization Architecture (`invoke_subagent`, `run_command` with `Cwd`, `ask_question`).

## Global Constraints

- Never propose a standalone `cd` command across tool calls; always specify `Cwd: "$WORKTREE_PATH"` on `run_command` or run in subshells `(cd "$WORKTREE_PATH" && ...)`.
- Enforce reactive wakeup: parent coordinator dispatches reviewer via `invoke_subagent` and yields control; never poll or sleep in loops.
- Use `ask_question` for interactive escalation when review feedback conflicts with architecture or spec requirements.

---

### Task 1: Rewrite `skills/requesting-code-review/SKILL.md` & `code-reviewer.md`

**Files:**
- Modify: `config/agents/plugins/skills-that-thrill/skills/requesting-code-review/SKILL.md`
- Modify: `config/agents/plugins/skills-that-thrill/skills/requesting-code-review/code-reviewer.md`

- [ ] **Step 1: Rewrite `requesting-code-review/SKILL.md`**

Update `config/agents/plugins/skills-that-thrill/skills/requesting-code-review/SKILL.md` with:
- Frontmatter (`name: requesting-code-review`, description).
- Review Early, Review Often principle.
- Antigravity Native Subagent Dispatch: concrete `invoke_subagent` block with `TypeName: "self"` (read-only instruction) or `TypeName: "research"`.
- Reactive Wakeup: coordinator dispatches subagent and yields control without polling.
- Safe Git SHA resolution: `run_command` with `Cwd: "$WORKTREE_PATH"`.
- Standard documentation paths (`documentation/plans/YYYY-MM-DD-HHMM-<feature>.md`).

- [ ] **Step 2: Rewrite `requesting-code-review/code-reviewer.md`**

Update `config/agents/plugins/skills-that-thrill/skills/requesting-code-review/code-reviewer.md` with:
- Concrete Antigravity `invoke_subagent` template block.
- Read-only review instructions (no mutations to tree/index/HEAD).
- Structured output format: Strengths, Issues (Critical, Important, Minor), Recommendations, Assessment.

---

### Task 2: Rewrite `skills/receiving-code-review/SKILL.md`

**Files:**
- Modify: `config/agents/plugins/skills-that-thrill/skills/receiving-code-review/SKILL.md`

- [ ] **Step 1: Rewrite `receiving-code-review/SKILL.md`**

Update `config/agents/plugins/skills-that-thrill/skills/receiving-code-review/SKILL.md` with:
- Frontmatter (`name: receiving-code-review`, description).
- Technical rigor over performative agreement; prohibition of empty pleasantries.
- Structured response cycle: Read, Understand, Verify against codebase, Evaluate, Respond, Implement sequentially.
- Sequential fix order: Blocking/security → Simple fixes → Complex refactors.
- Interactive conflict adjudication via `ask_question`: pause and prompt user when review feedback conflicts with architecture or spec.
- GitHub integration: `gh api` with `Cwd` or `github-mcp-server` inline replies.

- [ ] **Step 2: Verify `SKILL.md` content**

Ensure no Claude-specific artifacts or broken formatting.

---

### Task 3: End-to-End Verification & Symlink Check

**Files:**
- Verify: `~/.gemini/config/plugins/skills-that-thrill/skills/requesting-code-review/`
- Verify: `~/.gemini/config/plugins/skills-that-thrill/skills/receiving-code-review/`

- [ ] **Step 1: Verify symlink synchronization**

Run:
```bash
ls -la ~/.gemini/config/plugins/skills-that-thrill/skills/requesting-code-review/
ls -la ~/.gemini/config/plugins/skills-that-thrill/skills/receiving-code-review/
```
Expected: Reflects all updated files.

- [ ] **Step 2: Verify git status**

Run:
```bash
git status --short config/agents/plugins/skills-that-thrill/skills/requesting-code-review/ config/agents/plugins/skills-that-thrill/skills/receiving-code-review/
```
Expected: Shows modified files.
