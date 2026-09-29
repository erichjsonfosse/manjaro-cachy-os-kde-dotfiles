# Plugin Skills Refinements Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use skills-that-thrill:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Apply all agreed architectural, consistency, and tool-mapping refinements across the skills-that-thrill skill suite.

**Architecture:** Systematic file-by-file edits across markdown skills, references, helper scripts, and prompt templates. Each edit adheres strictly to Antigravity CLI and IDE capabilities, prioritizing `~/.agents/...` paths and native Mermaid diagrams.

**Tech Stack:** Markdown, Bash, Antigravity Agent Runtime

## Global Constraints

- Always prioritize `~/.agents/...` over `~/.gemini/...` for user-global scopes.
- Never propose standalone `cd` across tool calls; use `Cwd` or scoped subshells.
- Maintain zero-polling reactive wakeup principles throughout.
- Keep all Mermaid diagrams valid and standard.

---

### Task 1: Refine `using-skills-that-thrill` & `references/antigravity-tools.md`
**Files:**
- Modify: `config/agents/plugins/skills-that-thrill/skills/using-skills-that-thrill/references/antigravity-tools.md`

- [ ] **Step 1: Prioritize `~/.agents/...` paths**
  Update "Skills and Rules Locations in Antigravity" section to list `~/.agents/skills/` (preferred) before `~/.gemini/...`.
- [ ] **Step 2: Nuance `ask_question` recommendation rule**
  Clarify that `(Recommended)` is used when an option clearly dominates; peer options can be presented neutrally.
- [ ] **Step 3: Verify changes**
  Inspect file to confirm accurate formatting.

---

### Task 2: Refine `brainstorming`
**Files:**
- Modify: `config/agents/plugins/skills-that-thrill/skills/brainstorming/SKILL.md`

- [ ] **Step 1: Add Multi-Phase Brainstorming Tracking**
  Add guidance in Step 1 / Step 2 for creating a temporary Task Artifact (`brainstorming_<topic>_tasks.md`) for complex multi-checkpoint explorations.
- [ ] **Step 2: Add Spec Header Upstream Links**
  Add spec header requirement to link upstream requirements/issues.
- [ ] **Step 3: Verify changes**
  Inspect file to confirm clean Markdown.

---

### Task 3: Refine `writing-plans`
**Files:**
- Modify: `config/agents/plugins/skills-that-thrill/skills/writing-plans/SKILL.md`

- [ ] **Step 1: Add clickable spec link to Plan Document Header**
  Update the mandatory plan document header template with `**Spec:** [Design Spec](file:///path/to/documentation/specs/...)`.
- [ ] **Step 2: Explicit `Cwd` in Task Code Blocks**
  Add explicit mention of `Cwd: "$WORKTREE_PATH"` in verification instructions.
- [ ] **Step 3: Verify changes**
  Inspect file to confirm clean Markdown.

---

### Task 4: Refine `using-git-worktrees`
**Files:**
- Modify: `config/agents/plugins/skills-that-thrill/skills/using-git-worktrees/SKILL.md`

- [ ] **Step 1: Dynamic container detection**
  Update Step 1b Directory Resolution to inspect whether the current repo is inside a container (`main/` subfolder) or a flat checkout.
- [ ] **Step 2: Verify changes**
  Inspect file to confirm logic.

---

### Task 5: Refine `subagent-driven-development` and Helper Prompts/Scripts
**Files:**
- Modify: `config/agents/plugins/skills-that-thrill/skills/subagent-driven-development/scripts/sdd-workspace`
- Modify: `config/agents/plugins/skills-that-thrill/skills/subagent-driven-development/task-reviewer-prompt.md`
- Modify: `config/agents/plugins/skills-that-thrill/skills/subagent-driven-development/re-review-prompt.md`

- [ ] **Step 1: Update comments in `sdd-workspace`**
  Modernize comments to agent-neutral terminology.
- [ ] **Step 2: Require clickable links in review prompts**
  Add explicit instructions to `task-reviewer-prompt.md` and `re-review-prompt.md` to output clickable `[file:line](file:///...)` links.
- [ ] **Step 3: Verify changes**
  Check diff and inspect files.

---

### Task 6: Refine `dispatching-parallel-agents`
**Files:**
- Modify: `config/agents/plugins/skills-that-thrill/skills/dispatching-parallel-agents/SKILL.md`

- [ ] **Step 1: Add Antigravity multi-agent array dispatch example**
  Illustrate `invoke_subagent` with multiple workers in `Subagents: [...]` and emphasize reactive wakeup.
- [ ] **Step 2: Verify changes**
  Inspect file.

---

### Task 7: Refine `executing-plans`
**Files:**
- Modify: `config/agents/plugins/skills-that-thrill/skills/executing-plans/SKILL.md`

- [ ] **Step 1: Mandate verification gate before review checkpoint**
  Explicitly invoke `verification-before-completion` before presenting each `ask_question` review checkpoint.
- [ ] **Step 2: Verify changes**
  Inspect file.

---

### Task 8: Refine `test-driven-development`
**Files:**
- Modify: `config/agents/plugins/skills-that-thrill/skills/test-driven-development/SKILL.md`

- [ ] **Step 1: Distinguish harness/syntax error vs test assertion failure**
  Add guidance in Step 2 for environmental crashes, referencing `systematic-debugging`.
- [ ] **Step 2: Verify changes**
  Inspect file.

---

### Task 9: Refine `systematic-debugging`
**Files:**
- Modify: `config/agents/plugins/skills-that-thrill/skills/systematic-debugging/condition-based-waiting.md`

- [ ] **Step 1: Add Bash condition-based waiting example**
  Provide bounded polling loop pattern in Bash alongside TypeScript.
- [ ] **Step 2: Verify changes**
  Inspect file.

---

### Task 10: Refine `requesting-code-review` & `receiving-code-review`
**Files:**
- Modify: `config/agents/plugins/skills-that-thrill/skills/receiving-code-review/SKILL.md`

- [ ] **Step 1: Add rule-violation pushback guidance**
  Add explicit rule to reject suggestions violating harness rules or skill contracts.
- [ ] **Step 2: Verify changes**
  Inspect file.

---

### Task 11: Refine `verification-before-completion`
**Files:**
- Modify: `config/agents/plugins/skills-that-thrill/skills/verification-before-completion/SKILL.md`

- [ ] **Step 1: Add Git clean working tree verification row**
  Include `git status --porcelain` in the verification table.
- [ ] **Step 2: Verify changes**
  Inspect file.

---

### Task 12: Refine `finishing-a-development-branch`
**Files:**
- Modify: `config/agents/plugins/skills-that-thrill/skills/finishing-a-development-branch/SKILL.md`

- [ ] **Step 1: Add Main Root dirty check before local checkout/merge**
  Check `git -C "$MAIN_ROOT" status --porcelain` in Option 3 before checking out base branch.
- [ ] **Step 2: Verify changes**
  Inspect file.

---

### Task 13: Refine `writing-skills`
**Files:**
- Rename / Update: `config/agents/plugins/skills-that-thrill/skills/writing-skills/examples/CLAUDE_MD_TESTING.md` -> `AGENTS_MD_TESTING.md`
- Modify: `config/agents/plugins/skills-that-thrill/skills/writing-skills/SKILL.md`

- [ ] **Step 1: Modernize example test file**
  Rename to `AGENTS_MD_TESTING.md` and replace `~/.claude/skills/` with `~/.agents/skills/`.
- [ ] **Step 2: Note deprecation of Graphviz files**
  Note in `writing-skills/SKILL.md` that `graphviz-conventions.dot` and `render-graphs.js` are superseded by `mermaid-conventions.md`.
- [ ] **Step 3: Verify changes and symlinks**
  Inspect files and confirm symlinks stay in sync.
