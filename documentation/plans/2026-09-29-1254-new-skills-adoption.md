# Implementation Plan: Skills That Thrill New Skills Adoption

**Spec Reference:** [Design Spec](file:///home/erichjsonfosse/projects/manjaro-cachy-os-kde-dotfiles/main/documentation/specs/2026-09-29-1250-skills-that-thrill-new-skills-adoption-design.md)  
**Plan Date & Time:** 2026-09-29-1254  
**Target Repository:** [`/home/erichjsonfosse/projects/manjaro-cachy-os-kde-dotfiles/main`](file:///home/erichjsonfosse/projects/manjaro-cachy-os-kde-dotfiles/main)  
**Source Skills Directory:** [`/home/erichjsonfosse/projects/tests/training-purposes-hauws/main/skills`](file:///home/erichjsonfosse/projects/tests/training-purposes-hauws/main/skills)  
**Destination Plugin Directory:** [`config/agents/plugins/skills-that-thrill/skills/`](file:///home/erichjsonfosse/projects/manjaro-cachy-os-kde-dotfiles/main/config/agents/plugins/skills-that-thrill/skills/)  

---

## High-Level Overview

Integrate 8 high-leverage skills from the candidate repository into `skills-that-thrill`, adhering strictly to our action-gerund (`-ing`) naming convention, cross-runtime path priority (`~/.agents/...` first), and harness-neutral standards. Simultaneously refine existing skills (`brainstorming` and `requesting-code-review`) with principles borrowed from the candidate set.

---

## Detailed Task Breakdown

### Task 1: Refine `brainstorming/SKILL.md` (Add Non-Requirements)
- **Target File:** `config/agents/plugins/skills-that-thrill/skills/brainstorming/SKILL.md`
- **Action:** Update Step 6 to require an explicit `## Non-Requirements & Constraints` section in every generated design spec to guard against scope creep.
- **Verification Command:**
  ```bash
  grep -A 5 "Non-Requirements" config/agents/plugins/skills-that-thrill/skills/brainstorming/SKILL.md
  ```
  *(Cwd: `/home/erichjsonfosse/projects/manjaro-cachy-os-kde-dotfiles/main`)*

---

### Task 2: Refine `requesting-code-review/SKILL.md` (Mandate Proof-of-Issue)
- **Target File:** `config/agents/plugins/skills-that-thrill/skills/requesting-code-review/SKILL.md`
- **Action:** Update the review guidelines to require concrete proof of issues (execution path, broken invariant, and file/line citation) rather than hypothetical or speculative concerns.
- **Verification Command:**
  ```bash
  grep -A 5 "Proof-of-Issue" config/agents/plugins/skills-that-thrill/skills/requesting-code-review/SKILL.md
  ```
  *(Cwd: `/home/erichjsonfosse/projects/manjaro-cachy-os-kde-dotfiles/main`)*

---

### Task 3: Import & Standardize `reviewing-security`
- **Source:** `/home/erichjsonfosse/projects/tests/training-purposes-hauws/main/skills/v-review-security/SKILL.md`
- **Destination:** `config/agents/plugins/skills-that-thrill/skills/reviewing-security/SKILL.md`
- **Changes:**
  - Name: `reviewing-security`
  - Remove `v-` prefix and clean up frontmatter (`trigger`, `metadata`).
  - Standardize cross-runtime pathing (`~/.agents/...`).
- **Verification Command:**
  ```bash
  head -n 15 config/agents/plugins/skills-that-thrill/skills/reviewing-security/SKILL.md
  ```
  *(Cwd: `/home/erichjsonfosse/projects/manjaro-cachy-os-kde-dotfiles/main`)*

---

### Task 4: Import & Standardize `upgrading-dependencies`
- **Source:** `/home/erichjsonfosse/projects/tests/training-purposes-hauws/main/skills/v-upgrade-dependencies/SKILL.md`
- **Destination:** `config/agents/plugins/skills-that-thrill/skills/upgrading-dependencies/SKILL.md`
- **Changes:**
  - Name: `upgrading-dependencies`
  - Remove `v-` prefix and clean up frontmatter.
  - Standardize cross-runtime pathing and ensure git commit separation rules are prominent.
- **Verification Command:**
  ```bash
  head -n 15 config/agents/plugins/skills-that-thrill/skills/upgrading-dependencies/SKILL.md
  ```
  *(Cwd: `/home/erichjsonfosse/projects/manjaro-cachy-os-kde-dotfiles/main`)*

---

### Task 5: Import & Standardize `adversarial-code-review`
- **Source:** `/home/erichjsonfosse/projects/tests/training-purposes-hauws/main/skills/v-scored-code-review/` (SKILL.md, agents/, references/)
- **Destination:** `config/agents/plugins/skills-that-thrill/skills/adversarial-code-review/`
- **Changes:**
  - Name: `adversarial-code-review`
  - Rename internal references from `v-scored-code-review` to `adversarial-code-review`.
  - Adapt agents to Antigravity `invoke_subagent` syntax and standard multi-agent patterns.
  - Remove Visma repository URLs and author headers.
- **Verification Command:**
  ```bash
  ls -la config/agents/plugins/skills-that-thrill/skills/adversarial-code-review/
  ```
  *(Cwd: `/home/erichjsonfosse/projects/manjaro-cachy-os-kde-dotfiles/main`)*

---

### Task 6: Import & Standardize `managing-ci`
- **Source:** `/home/erichjsonfosse/projects/tests/training-purposes-hauws/main/skills/v-manage-ci/SKILL.md`
- **Destination:** `config/agents/plugins/skills-that-thrill/skills/managing-ci/SKILL.md`
- **Changes:**
  - Name: `managing-ci`
  - Clean frontmatter and remove `v-` prefix.
  - Verify deterministic CI and SHA-pinning guidelines.
- **Verification Command:**
  ```bash
  head -n 15 config/agents/plugins/skills-that-thrill/skills/managing-ci/SKILL.md
  ```
  *(Cwd: `/home/erichjsonfosse/projects/manjaro-cachy-os-kde-dotfiles/main`)*

---

### Task 7: Import & Standardize `testing-e2e`
- **Source:** `/home/erichjsonfosse/projects/tests/training-purposes-hauws/main/skills/v-test-e2e/` (SKILL.md, agents/, templates/)
- **Destination:** `config/agents/plugins/skills-that-thrill/skills/testing-e2e/`
- **Changes:**
  - Name: `testing-e2e`
  - Clean frontmatter, remove `v-` references.
  - Ensure Playwright templates and helper agent prompts use standardized paths and tools.
- **Verification Command:**
  ```bash
  ls -la config/agents/plugins/skills-that-thrill/skills/testing-e2e/
  ```
  *(Cwd: `/home/erichjsonfosse/projects/manjaro-cachy-os-kde-dotfiles/main`)*

---

### Task 8: Import & Standardize `running-lean`
- **Source:** `/home/erichjsonfosse/projects/tests/training-purposes-hauws/main/skills/v-run-lean/SKILL.md`
- **Destination:** `config/agents/plugins/skills-that-thrill/skills/running-lean/SKILL.md`
- **Changes:**
  - Name: `running-lean`
  - Clean frontmatter and remove `v-` prefix.
- **Verification Command:**
  ```bash
  head -n 15 config/agents/plugins/skills-that-thrill/skills/running-lean/SKILL.md
  ```
  *(Cwd: `/home/erichjsonfosse/projects/manjaro-cachy-os-kde-dotfiles/main`)*

---

### Task 9: Import & Standardize `capturing-learnings`
- **Source:** `/home/erichjsonfosse/projects/tests/training-purposes-hauws/main/skills/v-capture-learning/SKILL.md`
- **Destination:** `config/agents/plugins/skills-that-thrill/skills/capturing-learnings/SKILL.md`
- **Changes:**
  - Name: `capturing-learnings`
  - Clean frontmatter, align knowledge store locations (`docs/ai-memory.md` or `.ai-memory/`), remove `v-` references.
- **Verification Command:**
  ```bash
  head -n 15 config/agents/plugins/skills-that-thrill/skills/capturing-learnings/SKILL.md
  ```
  *(Cwd: `/home/erichjsonfosse/projects/manjaro-cachy-os-kde-dotfiles/main`)*

---

### Task 10: Import & Standardize `authoring-agent-context`
- **Source:** `/home/erichjsonfosse/projects/tests/training-purposes-hauws/main/skills/v-setup-agent-context/` (SKILL.md, references/)
- **Destination:** `config/agents/plugins/skills-that-thrill/skills/authoring-agent-context/`
- **Changes:**
  - Name: `authoring-agent-context`
  - Clean frontmatter, remove `v-` references.
  - Emphasize "Separating Inferable from Non-Inferable".
- **Verification Command:**
  ```bash
  ls -la config/agents/plugins/skills-that-thrill/skills/authoring-agent-context/
  ```
  *(Cwd: `/home/erichjsonfosse/projects/manjaro-cachy-os-kde-dotfiles/main`)*

---

### Task 11: Final Symlink, Git Status & Cleanliness Check
- **Action:**
  - Check `git status --porcelain` to verify all new files and modifications.
  - Verify symlinks at `~/.agents/plugins/skills-that-thrill` and `~/.gemini/config/plugins/skills-that-thrill`.
- **Verification Command:**
  ```bash
  git status --short config/agents/plugins/skills-that-thrill/
  ```
  *(Cwd: `/home/erichjsonfosse/projects/manjaro-cachy-os-kde-dotfiles/main`)*
