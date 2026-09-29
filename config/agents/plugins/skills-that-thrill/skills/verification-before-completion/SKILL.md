---
name: verification-before-completion
description: Use when about to claim work is complete, fixed, or passing, before committing or creating PRs - requires running verification commands and confirming output before making any success claims; evidence before assertions always
---

# Verification Before Completion

## Overview

**Core principle:** Evidence before claims, always.

Violating the letter of this rule is violating the spirit of this rule.

---

## The Iron Law

```
NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE
```

If you have not executed the verification command in the current interaction, you cannot claim it passes.

---

## The Gate Function

```
BEFORE claiming any status or expressing satisfaction:

1. IDENTIFY: What command proves this claim?
2. RUN: Execute the FULL command (fresh, complete, within proper Cwd)
3. READ: Full output, check exit code, count failures
4. VERIFY: Does output confirm the claim?
   - If NO: State actual status with evidence and escalate
   - If YES: State claim WITH evidence
5. ONLY THEN: Make the claim
```

**Skip any step = lying, not verifying.**

---

## Antigravity Execution Safety

> [!IMPORTANT]
> **No Standalone `cd`:**
> In Antigravity, shell directory state does not persist across tool calls.
> Always execute verification commands using `run_command` with the `Cwd: "$WORKTREE_PATH"` parameter (or within scoped subshells `(cd "$WORKTREE_PATH" && <command>)`). Never propose standalone `cd` across tool calls.

---

## Common Failures & Required Evidence

| Claim                 | Requires Fresh Evidence                                  | Not Sufficient                                 |
|:----------------------|:---------------------------------------------------------|:-----------------------------------------------|
| Tests pass            | Test command output: exit 0, 0 failures                  | Previous run, "should pass", partial run       |
| Linter clean          | Linter output: 0 errors                                  | Partial check, extrapolation, IDE indicators   |
| Build succeeds        | Build command: exit 0                                    | Linter passing, logs look good, types compile  |
| Bug fixed             | Test reproducing original symptom: passes                | Code changed, assumed fixed, manual inspection |
| Regression test works | Red-green cycle verified (fails before, passes after)    | Test passes once                               |
| Subagent completed    | Coordinator independently runs VCS diff & tests in `Cwd` | Subagent self-reports "success"                |
| Requirements met      | Line-by-line checklist verification against spec         | Tests passing                                  |
| Working tree clean    | VCS status output (`git status --porcelain`): clean      | Assuming git is clean, ignoring untracked files |

---

## Subagent Delegation Verification

When subagents report task completion via `invoke_subagent`:
- **Never trust a subagent's self-reported success.**
- The coordinator must independently verify changes:
  1. Inspect the workspace diff: `git status` and `git diff`.
  2. Execute the verification suite freshly in `Cwd: "$WORKTREE_PATH"`.
  3. Only mark the subagent's task complete after confirming output and exit code 0.

---

## Interactive Escalation Gate (`ask_question`)

If a verification command fails when you are preparing to conclude work or hand off a task, do not rationalize, ignore, or bypass the failure.

Trigger an interactive escalation modal via `ask_question`:

```
question: "Verification command failed with <N> errors in <worktree>. How would you like to proceed?"
options:
  - "(Recommended) Fix verification failures before claiming completion"
  - "Investigate whether failures are pre-existing baseline issues"
  - "Inspect detailed failure logs"
```

If proceeding to fix, activate `skills-that-thrill:systematic-debugging` to trace the root cause.

---

## Red Flags - STOP

- Using words like "should", "probably", "seems to", "appears clean"
- Expressing satisfaction before verification ("Great!", "Perfect!", "Done!", "Everything looks good!")
- About to commit, push, or create a PR without fresh command output
- Trusting subagent success reports without independent test execution
- Relying on partial or scoped checks when full suite verification is required
- Thinking "just this once" or wanting the session to be over
- **ANY wording implying success without having run verification**

---

## Rationalization Prevention

| Excuse                                  | Reality                                        |
|:----------------------------------------|:-----------------------------------------------|
| "Should work now"                       | RUN the verification command                   |
| "I'm confident"                         | Confidence ≠ evidence                          |
| "Just this once"                        | Zero exceptions                                |
| "Linter passed"                         | Linter does not test execution or compilation  |
| "Subagent said success"                 | Verify independently with fresh test run       |
| "I'm tired"                             | Exhaustion is never an excuse for false claims |
| "Partial check is enough"               | Partial proves nothing about regression        |
| "Different words so rule doesn't apply" | Spirit over letter                             |

---

## Key Patterns

### Unit / Integration Tests
```
✅ [Run test command with Cwd: "$WORKTREE_PATH"] [See: 34/34 pass, exit 0] "All 34 tests pass."
❌ "Should pass now" / "Looks correct" / "Tests were passing earlier"
```

### Regression Tests (TDD Red-Green)
```
✅ Write test → Run (fails) → Apply fix → Run (passes) → Verify clean state
❌ "I've added a regression test" (without verified failing baseline)
```

### Build & Compilation
```
✅ [Run build with Cwd: "$WORKTREE_PATH"] [See: exit code 0] "Build succeeds."
❌ "TypeScript showed no red squiggles" (typecheck ≠ full build)
```

### Requirements & Specs
```
✅ Re-read approved plan → Verify each task criterion against code → Report verified state
❌ "Tests pass, phase complete"
```

### Working Tree Cleanliness
```
✅ [Run git status --porcelain in Cwd: "$WORKTREE_PATH"] [See: empty] "Working tree is clean."
❌ "Only changed a couple of files" / Unverified untracked build artifacts
```

---

## When To Apply

**ALWAYS before:**
- ANY variation of success or completion claims
- ANY expression of satisfaction
- ANY positive statement about work state
- Committing, PR creation, or task handoff
- Marking task complete in task checklists or artifacts
- Moving to the next task in a plan

**Rule applies to:**
- Exact phrases
- Paraphrases and synonyms
- Implications of success
- ANY communication suggesting completion or correctness
