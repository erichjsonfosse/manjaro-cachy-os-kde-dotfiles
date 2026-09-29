# Antigravity-First Writing Plans Skill Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use skills-that-thrill:subagent-driven-development or skills-that-thrill:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Adapt the `writing-plans` skill in `skills-that-thrill` for Antigravity-First, standardizing paths on `documentation/plans/`, making execution handoff context-aware without hardcoded recommendations, and documenting native `ask_question` and `invoke_subagent` integration.

**Architecture:**
1. Rewrite `skills/writing-plans/SKILL.md` to establish `documentation/plans/` as canonical storage, define context-aware execution recommendation rules, and specify interactive `ask_question` execution handoff.
2. Update `skills/writing-plans/plan-document-reviewer-prompt.md` to target `documentation/plans/` and provide Antigravity `invoke_subagent` configuration.
3. Verify symlink synchronization and path integrity across the plugin.

**Tech Stack:** Markdown, Bash, Antigravity Customization Architecture.

## Global Constraints

- Never use abbreviated paths (use `documentation/plans/` and `documentation/specs/`, not `docs/`).
- Do NOT hardcode `(Recommended)` on any execution option in the handoff. Evaluate task independence and context before recommending, or present options neutrally.
- Maintain cross-harness compatibility while prioritizing Antigravity native tools.

---

### Task 1: Rewrite `skills/writing-plans/SKILL.md` for Antigravity-First

**Files:**
- Modify: `config/agents/plugins/skills-that-thrill/skills/writing-plans/SKILL.md`

- [ ] **Step 1: Write the updated `SKILL.md` content**

Update `config/agents/plugins/skills-that-thrill/skills/writing-plans/SKILL.md` with:
- Frontmatter (`name: writing-plans`, description).
- Canonical plan storage: `documentation/plans/YYYY-MM-DD-<feature-name>.md`.
- File structure and task decomposition guidelines (bite-sized 2–5 min steps, TDD: failing test → verify fail → minimal implementation → verify pass → commit).
- Plan document header template referencing `documentation/plans/`.
- Mandatory author self-review checklist (spec coverage, placeholder scan, interface consistency).
- Optional subagent review via `invoke_subagent` with `plan-document-reviewer-prompt.md`.
- Context-aware execution handoff:
  - If tasks are modular/independent/parallel: recommend Subagent-Driven.
  - If tasks are tightly coupled/sequential/small: recommend Inline Execution.
  - If neither dominates: present both neutrally.
  - Use `ask_question` for interactive selection on Antigravity runtimes.

- [ ] **Step 2: Verify `SKILL.md` paths and absence of hardcoded recommendation defaults**

Run:
```bash
grep -n "documentation/plans" config/agents/plugins/skills-that-thrill/skills/writing-plans/SKILL.md
grep -n "docs/superpowers" config/agents/plugins/skills-that-thrill/skills/writing-plans/SKILL.md
```
Expected: Matches found for `documentation/plans`, zero matches for `docs/superpowers`.

---

### Task 2: Update `skills/writing-plans/plan-document-reviewer-prompt.md`

**Files:**
- Modify: `config/agents/plugins/skills-that-thrill/skills/writing-plans/plan-document-reviewer-prompt.md`

- [ ] **Step 1: Update path and subagent dispatch instructions**

Update `plan-document-reviewer-prompt.md`:
- Change dispatch target to `documentation/plans/` and spec to `documentation/specs/`.
- Provide concrete Antigravity `invoke_subagent` configuration (`TypeName: "research"`, `Model: "inherit"`).
- Retain the generic cross-harness prompt template.

- [ ] **Step 2: Verify file updates**

Run:
```bash
grep "documentation/plans" config/agents/plugins/skills-that-thrill/skills/writing-plans/plan-document-reviewer-prompt.md
grep "documentation/specs" config/agents/plugins/skills-that-thrill/skills/writing-plans/plan-document-reviewer-prompt.md
```
Expected: Both return matching lines confirming updated paths.

---

### Task 3: End-to-End Verification & Symlink Check

**Files:**
- Verify: `~/.gemini/config/plugins/skills-that-thrill/skills/writing-plans/`

- [ ] **Step 1: Verify symlink synchronization**

Run:
```bash
ls -la ~/.gemini/config/plugins/skills-that-thrill/skills/writing-plans/
```
Expected: Reflects updated `SKILL.md` and `plan-document-reviewer-prompt.md`.

- [ ] **Step 2: Verify no dangling references across the plugin**

Run:
```bash
grep -rn "documentation/skills-that-thrill/plans" config/agents/plugins/skills-that-thrill/
```
Expected: Zero occurrences.
