# Git Conventions Rule Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use skills-that-thrill:subagent-driven-development or skills-that-thrill:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** Codify strict explicit git staging, documentation isolation, conventional commits, and safety invariants into `skills-that-thrill` plugin rules.

**Architecture:** Create `rules/git-conventions.md` defining strict staging discipline, documentation isolation, and commit standards. Include this rule in `rules/AGENTS.md` and `rules/GEMINI.md`. Verify total expanded size stays under the 24 KB ceiling and verify symlinked discovery.

**Tech Stack:** Markdown, Git, Bash.

**Spec Reference:** [Design Spec](file:///home/erichjsonfosse/projects/manjaro-cachy-os-kde-dotfiles/main/documentation/specs/2026-09-29-1654-git-conventions-rule-design.md)

## Global Constraints
- Rule file location: `config/agents/plugins/skills-that-thrill/rules/git-conventions.md`.
- Expanded `AGENTS.md` limit: Must remain strictly below 24,000 bytes.
- Atomic commits: Practice the new rule immediately when staging and committing these changes.

---

### Task 1: Create `rules/git-conventions.md`

**Files:**
- Create: `config/agents/plugins/skills-that-thrill/rules/git-conventions.md`

- [ ] **Step 1:** Write `config/agents/plugins/skills-that-thrill/rules/git-conventions.md` containing:
  - Strict Explicit Staging directives (forbidden blanket adds, mandatory exact paths, status check first).
  - Documentation & Specification Isolation directives (dedicated `docs(...)` commits, never bundle with code).
  - Conventional Commits standard (format `<type>(<scope>): <summary>`, allowed types, imperative mood).
  - Small & Cherry-Pickable Commits directive (atomic, focused, independently applicable without trailing baggage).
  - Task Completion Presentation directive (on completion or checkpoint, present table/list of all commits created and exact files modified per commit).
  - Safety invariants (no `--no-verify`, no destructive force push/hard reset without permission).
- [ ] **Step 2:** Verify file content and readability.

---

### Task 2: Include Rule in `AGENTS.md` and `GEMINI.md` & Verify Budget

**Files:**
- Modify: `config/agents/plugins/skills-that-thrill/rules/AGENTS.md`
- Modify: `config/agents/plugins/skills-that-thrill/rules/GEMINI.md`

- [ ] **Step 1:** Add `@[git-conventions](./git-conventions.md)` to `config/agents/plugins/skills-that-thrill/rules/AGENTS.md`.
- [ ] **Step 2:** Add `@[git-conventions](./git-conventions.md)` to `config/agents/plugins/skills-that-thrill/rules/GEMINI.md`.
- [ ] **Step 3:** Calculate expanded file size and verify it is under the 24,000 bytes limit.
- [ ] **Step 4:** Verify symlink chain from `~/.agents/plugins/skills-that-thrill/rules/` and `~/.gemini/config/plugins/skills-that-thrill/rules/`.

---

### Task 3: Commit Documentation and Implementation According to New Git Conventions

**Files:**
- Modify: Git history

- [ ] **Step 1:** Stage and commit the design spec and implementation plan in a dedicated documentation commit:
  `git add documentation/specs/2026-09-29-1654-git-conventions-rule-design.md documentation/plans/2026-09-29-1655-git-conventions-rule.md`
  `git commit -m "docs(rules): add git conventions design spec and implementation plan"`
- [ ] **Step 2:** Stage and commit the rule files using exact file paths:
  `git add config/agents/plugins/skills-that-thrill/rules/git-conventions.md config/agents/plugins/skills-that-thrill/rules/AGENTS.md config/agents/plugins/skills-that-thrill/rules/GEMINI.md`
  `git commit -m "feat(rules): add git conventions rule for strict staging and conventional commits"`
- [ ] **Step 3:** Verify git log and working tree status.
- [ ] **Step 4:** Present all commits created and exact list of files per commit with clickable markdown links.
