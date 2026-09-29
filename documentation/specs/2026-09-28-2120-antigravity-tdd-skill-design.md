# Design Specification: Antigravity-First Test-Driven Development Skill

**Date:** 2026-09-28  
**Topic:** Test-Driven Development Skill Adaptation for Antigravity & Multi-Harness  
**Status:** Approved by User  

---

## 1. Context & Motivation

The `test-driven-development` (TDD) skill establishes the foundational disciplined engineering workflow: writing minimal tests, watching them fail for the intended reason, writing minimal passing production code, and refactoring under green tests.

In the original implementation:
- Test execution commands were presented as generic shell commands without harness parameterization, risking directory state bugs (such as raw `cd` calls across tool steps).
- The definition of structured verification evidence (RED and GREEN logs) was informal, making it harder for subagent implementers and orchestrators to exchange precise proof.
- Escalations when stuck relied on open-ended text questions rather than Antigravity's interactive `ask_question` modals.
- Minor stylistic/wording artifacts existed.

This adaptation modernizes `test-driven-development` and `writing-good-tests.md` for **Antigravity-First** usage, enforcing command execution via `Cwd`, standardizing verification evidence formats, and establishing interactive `ask_question` dialogs for architectural dilemmas.

---

## 2. Key Architecture Decisions

### 2.1 The Iron Law & Cycle Uncompromised
* **The Iron Law:** `NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST`. Code written before tests must be deleted.
* **Red-Green-Refactor Cycle:**
  1. **RED**: Write one minimal test exercising expected behavior.
  2. **Verify RED**: Run test; confirm it fails because the feature is missing, not due to compilation/syntax errors or typos.
  3. **GREEN**: Write minimal code to pass the test.
  4. **Verify GREEN**: Run test; confirm it passes and all other tests remain green. Output must be pristine.
  5. **REFACTOR**: Clean up design, improve names, eliminate duplication without altering behavior.

### 2.2 Command Execution Safety (`Cwd` & No Standalone `cd`)
* Antigravity strictly forbids standalone `cd` across tool steps.
* Always specify the `Cwd: "$WORKTREE_PATH"` parameter in `run_command`, or run within an explicit subshell `(cd "$WORKTREE_PATH" && <test-command>)`.
* Multi-stack patterns:
  - TypeScript/JavaScript: `npm test -- <path>` or `npx vitest run <path>`
  - Python: `pytest <path>`
  - Rust: `cargo test <test_name>`
  - Go: `go test -v ./...`
  - Shell / Bash: `bats <path>` or executable test scripts

### 2.3 Standardized Verification Evidence
* When reporting or documenting test results (e.g. in SDD implementer reports or executing-plans checkpoints):
  - **RED Evidence**: Exact command run (with `Cwd`), failing output excerpt showing missing feature, and explanation of why failure was expected.
  - **GREEN Evidence**: Exact command run (with `Cwd`), passing output summary showing zero errors/warnings.

### 2.4 Interactive Dilemma Resolution (`ask_question`)
* If an agent hits a genuine roadblock (e.g. untangling legacy untested code, external network boundary dilemmas, mock vs integration choice), pause and prompt the human partner using `ask_question` with structured options.

---

## 3. Components Modified

| File | Action | Description |
| :--- | :--- | :--- |
| `skills/test-driven-development/SKILL.md` | Rewrite | Update to Antigravity-First: execution safety (`Cwd`), structured verification evidence, `ask_question` escalations, and multi-stack examples. |
| `skills/test-driven-development/writing-good-tests.md` | Polish | Ensure clean formatting, remove any harness-specific quirks, and preserve test honesty principles. |

---

## 4. Verification & Acceptance Criteria

1. **Iron Law Preserved**: Zero weakening of TDD rigor.
2. **Command Safety**: Explicit instruction enforcing `Cwd` parameter in `run_command`.
3. **Evidence Standards**: Formalized RED and GREEN evidence contract.
4. **Symlink Synchronization**: Verified in `~/.gemini/config/plugins/skills-that-thrill/skills/test-driven-development/`.
