# Antigravity-First Brainstorming Skill Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use skills-that-thrill:subagent-driven-development (recommended) or skills-that-thrill:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Adapt the `brainstorming` skill in `skills-that-thrill` to be Antigravity-First, removing the obsolete browser companion daemons and integrating native `ask_question` modals, workspace Mermaid diagrams, and clean `documentation/specs/` storage.

**Architecture:** 
1. Delete the external browser companion daemon scripts and documentation (`scripts/*` and `visual-companion.md`).
2. Rewrite `skills/brainstorming/SKILL.md` to establish the Antigravity-First workflow (TUI `ask_question` modals for multiple-choice decisions, Markdown & Mermaid diagrams for workspace viewing in developer IDEs, and spec storage in `documentation/specs/`).
3. Update `spec-document-reviewer-prompt.md` to target `documentation/specs/` and document dispatching via Antigravity's `invoke_subagent`.
4. Update `skills/using-skills-that-thrill/references/antigravity-tools.md` to document the brainstorming tool mapping.

**Tech Stack:** Markdown, Bash, Antigravity Customization Architecture.

## Global Constraints

- Never use abbreviated paths (use `documentation/specs/` and `documentation/plans/`, not `docs/`).
- Preserve cross-harness fallback logic (skills remain functional on Claude Code / Gemini CLI, but Antigravity tools like `ask_question` are the primary recommendation).
- Zero dangling links: ensure no file references the deleted `visual-companion.md` or `scripts/`.

---

### Task 1: Remove Obsolete Browser Companion Daemon Files

**Files:**
- Delete: `config/agents/plugins/skills-that-thrill/skills/brainstorming/visual-companion.md`
- Delete: `config/agents/plugins/skills-that-thrill/skills/brainstorming/scripts/server.cjs`
- Delete: `config/agents/plugins/skills-that-thrill/skills/brainstorming/scripts/start-server.sh`
- Delete: `config/agents/plugins/skills-that-thrill/skills/brainstorming/scripts/stop-server.sh`
- Delete: `config/agents/plugins/skills-that-thrill/skills/brainstorming/scripts/frame-template.html`
- Delete: `config/agents/plugins/skills-that-thrill/skills/brainstorming/scripts/helper.js`
- Delete Directory: `config/agents/plugins/skills-that-thrill/skills/brainstorming/scripts/`

- [ ] **Step 1: Delete visual companion markdown and scripts**

Run:
```bash
rm -f config/agents/plugins/skills-that-thrill/skills/brainstorming/visual-companion.md
rm -rf config/agents/plugins/skills-that-thrill/skills/brainstorming/scripts
```

- [ ] **Step 2: Verify files and directory are removed**

Run:
```bash
ls config/agents/plugins/skills-that-thrill/skills/brainstorming/
```
Expected: Only `SKILL.md` and `spec-document-reviewer-prompt.md` remain.

---

### Task 2: Rewrite `skills/brainstorming/SKILL.md` for Antigravity-First

**Files:**
- Modify: `config/agents/plugins/skills-that-thrill/skills/brainstorming/SKILL.md`

- [ ] **Step 1: Write the updated `SKILL.md` content**

Update `config/agents/plugins/skills-that-thrill/skills/brainstorming/SKILL.md` with:
- Frontmatter (`name: brainstorming`, description).
- Hard gate: No implementation without approved design spec.
- 8-step checklist:
  1. Explore project context (files, docs, git log, scope check).
  2. Ask clarifying questions (use `ask_question` for multi-choice / scoped options, chat text for open-ended).
  3. Visualize concepts (Mermaid diagrams in Markdown, UI mockups, clickable file links).
  4. Propose 2–3 approaches (tradeoffs + `ask_question` modal selection).
  5. Present design in sections (architecture, components, data flow, error handling, testing).
  6. Write design doc to `documentation/specs/YYYY-MM-DD-<topic>-design.md`.
  7. Spec self-review (placeholders, contradictions, ambiguity, scope).
  8. User reviews written spec (`ask_question` approval gate) -> transition to `writing-plans`.
- Clear instructions on using `ask_question` on capable runtimes (Antigravity CLI / IDE).
- Removal of all references to `visual-companion.md`, Node servers, or browser ports.

- [ ] **Step 2: Verify `SKILL.md` syntax and absence of dangling references**

Run:
```bash
grep -n -E "visual-companion|start-server|server\.cjs" config/agents/plugins/skills-that-thrill/skills/brainstorming/SKILL.md
```
Expected: No matches found.

---

### Task 3: Update `spec-document-reviewer-prompt.md`

**Files:**
- Modify: `config/agents/plugins/skills-that-thrill/skills/brainstorming/spec-document-reviewer-prompt.md`

- [ ] **Step 1: Update path and subagent dispatch instructions**

Update `spec-document-reviewer-prompt.md`:
- Change `Dispatch after: Spec document is written to documentation/skills-that-thrill/specs/` to `documentation/specs/`.
- Provide concrete Antigravity invocation syntax (`invoke_subagent` with `TypeName: "self"` or `"research"`) alongside generic `Subagent (general-purpose):` template.

- [ ] **Step 2: Verify file updates**

Run:
```bash
grep "documentation/specs" config/agents/plugins/skills-that-thrill/skills/brainstorming/spec-document-reviewer-prompt.md
```
Expected: Confirms path points to `documentation/specs/`.

---

### Task 4: Update Antigravity Tool Mapping Reference

**Files:**
- Modify: `config/agents/plugins/skills-that-thrill/skills/using-skills-that-thrill/references/antigravity-tools.md`

- [ ] **Step 1: Update tool mapping table and brainstorming section**

Ensure `antigravity-tools.md` explicitly describes:
- `ask_question` used for interactive choices during `brainstorming` and `finishing-a-development-branch`.
- Workspace documentation in `documentation/specs/` with Mermaid diagram previews.
- Task Artifacts for tracking.

- [ ] **Step 2: Verify references file**

Run:
```bash
grep -n "ask_question" config/agents/plugins/skills-that-thrill/skills/using-skills-that-thrill/references/antigravity-tools.md
```
Expected: Shows clean documentation of `ask_question` for interactive menus and brainstorming.

---

### Task 5: End-to-End Verification of Plugin & Symlink Integrity

**Files:**
- Verify: `~/.gemini/config/plugins/skills-that-thrill/skills/brainstorming/`

- [ ] **Step 1: Verify symlink synchronization**

Run:
```bash
ls -la ~/.gemini/config/plugins/skills-that-thrill/skills/brainstorming/
```
Expected: Reflects the deleted scripts and updated files cleanly.

- [ ] **Step 2: Run grep check across entire plugin for broken links to deleted files**

Run:
```bash
grep -rn "visual-companion" config/agents/plugins/skills-that-thrill/
```
Expected: Zero occurrences.
