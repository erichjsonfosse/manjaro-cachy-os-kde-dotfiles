# Antigravity-First Writing Skills Skill Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use skills-that-thrill:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Adapt `writing-skills` for Antigravity-First, establishing cross-runtime paths (`~/.agents/...` preferred), standardizing visual diagrams on native Mermaid, creating `mermaid-conventions.md`, and aligning subagent pressure testing with `invoke_subagent`.

**Architecture:**
1. Create `skills/writing-skills/mermaid-conventions.md` establishing Mermaid diagram conventions for process skills.
2. Update `skills/writing-skills/testing-skills-with-subagents.md` to use Antigravity `invoke_subagent` pressure testing.
3. Rewrite `skills/writing-skills/SKILL.md` with prioritized `~/.agents/...` paths, Mermaid diagram conversion, and subagent testing references.
4. Verify symlink synchronization and ensure zero broken references.

**Tech Stack:** Markdown, Mermaid, Antigravity Customization Architecture (`invoke_subagent`, `ask_question`).

## Global Constraints

- Prefer `~/.agents/...` and `.agents/...` over runtime-specific paths.
- Standardize all diagrams on native Mermaid; avoid Graphviz `.dot` diagrams and external rendering scripts.
- Use `invoke_subagent` with reactive wakeup for skill pressure testing.

---

### Task 1: Create `skills/writing-skills/mermaid-conventions.md`

**Files:**
- Create: `config/agents/plugins/skills-that-thrill/skills/writing-skills/mermaid-conventions.md`

- [ ] **Step 1: Write `mermaid-conventions.md`**

Provide guidelines for:
- Supported diagram types: `flowchart TD`/`LR`, `sequenceDiagram`, `stateDiagram-v2`.
- Node shapes: rectangles `[...]`, diamonds `{...}`, rounded `(...)`.
- Node quoting rules: always quote node labels containing parentheses, brackets, or colons (`id["Label (info)"]`).
- Style syntax (`style id fill:#...,stroke:#...`).
- Native IDE and GitHub previewing (zero daemon overhead).

---

### Task 2: Update `skills/writing-skills/testing-skills-with-subagents.md`

**Files:**
- Modify: `config/agents/plugins/skills-that-thrill/skills/writing-skills/testing-skills-with-subagents.md`

- [ ] **Step 1: Update subagent dispatch instructions**

Update to use Antigravity's `invoke_subagent` tool:
- Dispatching baseline tester (`TypeName: "self"` or `"research"`, `Model: "inherit"` or `"pro"`).
- Recording verbatim rationalizations in RED phase.
- Re-testing with skill in GREEN phase.
- Reactive wakeup (no polling loop).

---

### Task 3: Rewrite `skills/writing-skills/SKILL.md`

**Files:**
- Modify: `config/agents/plugins/skills-that-thrill/skills/writing-skills/SKILL.md`

- [ ] **Step 1: Rewrite `writing-skills/SKILL.md`**

Update:
- Skill paths: User global (`~/.agents/skills/` preferred, `~/.gemini/antigravity-cli/skills/`), project-local (`.agents/skills/`), and plugin scopes.
- Flowchart diagram: Convert `when_flowchart` dot block to native Mermaid.
- Flowchart guidance: Reference `mermaid-conventions.md` instead of graphviz.
- Subagent testing: Reference `invoke_subagent` and TDD for skills.
- Frontmatter and formatting.

- [ ] **Step 2: Verify `SKILL.md` content**

Ensure no Claude-specific artifacts or broken formatting.

---

### Task 4: End-to-End Verification & Symlink Check

**Files:**
- Verify: `~/.gemini/config/plugins/skills-that-thrill/skills/writing-skills/`

- [ ] **Step 1: Verify symlink synchronization**

Run:
```bash
ls -la ~/.gemini/config/plugins/skills-that-thrill/skills/writing-skills/
```
Expected: Reflects created and updated files.

- [ ] **Step 2: Verify git status**

Run:
```bash
git status --short config/agents/plugins/skills-that-thrill/skills/writing-skills/
```
Expected: Shows modified and untracked files.
