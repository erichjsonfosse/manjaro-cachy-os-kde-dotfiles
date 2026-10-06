# Implementation Plan: Skills Refinements, Visual Diagrams & Cross-Skill Synergy

- **Topic:** Final Skills Refinement, Visual Diagrams, and Cross-Skill Synergy
- **Date:** 2026-09-29 13:29
- **Design Spec:** [2026-09-29-1327-skills-refinements-and-cross-synergy-design.md](../specs/2026-09-29-1327-skills-refinements-and-cross-synergy-design.md)
- **Status:** Pending Approval

---

### Task 1: Taxonomy & URI Standardization

**Files to modify:**
- `config/agents/plugins/skills-that-thrill/skills/receiving-code-review/SKILL.md`
- `config/agents/plugins/skills-that-thrill/skills/finishing-a-development-branch/SKILL.md`

**Steps:**
1. In `config/agents/plugins/skills-that-thrill/skills/receiving-code-review/SKILL.md`, update line 6 from `# Code Review Reception` to `# Receiving Code Review`.
2. In `config/agents/plugins/skills-that-thrill/skills/finishing-a-development-branch/SKILL.md`, update line 115 from `[<path>](file://<path>)` to `[<path>](file:///<path>)`.
3. Verify changes with `git diff`.

---

### Task 2: Visual Workflow Diagrams (Mermaid)

**Files to modify:**
- `config/agents/plugins/skills-that-thrill/skills/receiving-code-review/SKILL.md`
- `config/agents/plugins/skills-that-thrill/skills/adversarial-code-review/SKILL.md`

**Steps:**
1. In `config/agents/plugins/skills-that-thrill/skills/receiving-code-review/SKILL.md`, replace the ASCII block in lines 18-27 with a Mermaid flowchart:
   ```mermaid
   flowchart TD
       A["1. READ<br/>(Complete feedback without reacting)"] --> B["2. UNDERSTAND<br/>(Restate requirement in own words, or ask)"]
       B --> C["3. VERIFY<br/>(Check against codebase reality: grep, test, inspect)"]
       C --> D["4. EVALUATE<br/>(Technically sound for THIS codebase?)"]
       D --> E["5. RESPOND<br/>(Technical acknowledgment or reasoned pushback)"]
       E --> F["6. IMPLEMENT<br/>(One item at a time, test each)"]
   ```
2. In `config/agents/plugins/skills-that-thrill/skills/adversarial-code-review/SKILL.md`, insert a Mermaid pipeline diagram under `## Workflow`:
   ```mermaid
   flowchart TD
       A["1. Define Review Target<br/>(PR, branch diff, files)"] --> B["2. Scope & Dispatch Finders<br/>(1 or more Points Review Finder subagents)"]
       B --> C["3. Merge Duplicate Issues<br/>(Keep strongest proof & highest severity)"]
       C --> D["4. Adversary Challenge<br/>(Points Review Adversary subagent challenges claims)"]
       D --> E["5. Final Adjudication<br/>(Points Review Judge subagent settles score)"]
       E --> F["6. Persist & Present<br/>(Save to .reviews/ and output final scoreboard)"]
   ```
3. Verify syntax and formatting.

---

### Task 3: Cross-Skill Synergies & Intelligent Handoffs

**Files to modify:**
- `config/agents/plugins/skills-that-thrill/skills/systematic-debugging/SKILL.md`
- `config/agents/plugins/skills-that-thrill/skills/subagent-driven-development/SKILL.md`
- `config/agents/plugins/skills-that-thrill/skills/executing-plans/SKILL.md`
- `config/agents/plugins/skills-that-thrill/skills/authoring-agent-context/SKILL.md`

**Steps:**
1. In `config/agents/plugins/skills-that-thrill/skills/systematic-debugging/SKILL.md`, in Phase 4 step 3, add guidance to invoke `skills-that-thrill:capturing-learnings` (or recommend `/learn` in Antigravity) when resolving non-obvious, surprising, or high-friction issues.
2. In `config/agents/plugins/skills-that-thrill/skills/subagent-driven-development/SKILL.md`, under `## Final Review & Completion`, note that for high-stakes, security-sensitive, or complex branch features, developers should consider `skills-that-thrill:adversarial-code-review` and `skills-that-thrill:reviewing-security`.
3. In `config/agents/plugins/skills-that-thrill/skills/executing-plans/SKILL.md`, under `### Step 3: Complete Development`, add a recommendation to run `skills-that-thrill:requesting-code-review` (or `adversarial-code-review` / `reviewing-security` for sensitive tasks) before finishing the branch.
4. In `config/agents/plugins/skills-that-thrill/skills/authoring-agent-context/SKILL.md`, add Antigravity CLI/IDE and Gemini CLI context targets to the target tools list.
5. Verify changes with `git diff`.

---

### Task 4: Interactive Decision Gates (`ask_question`)

**Files to modify:**
- `config/agents/plugins/skills-that-thrill/skills/upgrading-dependencies/SKILL.md`

**Steps:**
1. In `config/agents/plugins/skills-that-thrill/skills/upgrading-dependencies/SKILL.md`, under Step 5 ("Decide: adapt or hold"), add explicit `ask_question` modal choices for presenting trade-offs:
   - `(Recommended) Adapt code to new API in a distinct commit`
   - `Hold dependency at current version and document reason`
   - `Isolate and defer upgrade`
2. Verify formatting and alignment.

---

### Task 5: Verification & Integrity Check

**Steps:**
1. Run python link validation across all markdown files to confirm no broken relative links exist.
2. Run git diff and status checks to confirm clean formatting across all modified files.
3. Confirm symlinks reflect the updated files.
