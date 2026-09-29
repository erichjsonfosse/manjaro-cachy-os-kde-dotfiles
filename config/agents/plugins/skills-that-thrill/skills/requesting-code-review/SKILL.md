---
name: requesting-code-review
description: Use when completing tasks, implementing major features, or before merging to verify work meets requirements
---

# Requesting Code Review

Dispatch an independent code reviewer subagent to catch issues before they cascade. The reviewer receives precisely scoped context for evaluation — never your coordinator session's entire history.

**Core principle:** Review early, review often.

---

## When to Request Review

**Mandatory:**
- After each task in subagent-driven development
- After completing a major feature or implementation plan milestone
- Before merging a feature branch to main

**Optional but valuable:**
- When stuck on an implementation dilemma (fresh perspective)
- Before large-scale refactoring (baseline sanity check)
- After fixing a subtle or complex bug

---

## How to Request

### 1. Get Git SHAs Safely

Resolve the starting and ending revisions for the changes you want reviewed:

```bash
BASE_SHA=$(git rev-parse HEAD~1)  # or git merge-base HEAD origin/main
HEAD_SHA=$(git rev-parse HEAD)
```

> [!IMPORTANT]
> **Antigravity Command Execution Safety:**
> Always run git commands with the `Cwd: "$WORKTREE_PATH"` parameter in `run_command` (or in subshells `(cd "$WORKTREE_PATH" && ...)`). Never execute standalone `cd` across tool calls.

---

### 2. Dispatch Code Reviewer Subagent

Use Antigravity's native `invoke_subagent` tool, filling the template at [code-reviewer.md](code-reviewer.md):

```json
{
  "Subagents": [
    {
      "TypeName": "self",
      "Role": "Code Reviewer",
      "Model": "inherit",
      "Workspace": "inherit",
      "Prompt": "You are a Senior Code Reviewer with expertise in software architecture, design patterns, and best practices. Your job is to review completed work against its plan or requirements and identify issues before they cascade.\n\n## What Was Implemented\n[DESCRIPTION]\n\n## Requirements / Plan\n[PLAN_OR_REQUIREMENTS]\n\n## Git Range to Review\nBase: [BASE_SHA]\nHead: [HEAD_SHA]\n\n...\n"
    }
  ]
}
```

**Configuration Notes:**
- **`TypeName: "self"`**: Equips the reviewer with `run_command` to inspect git history (`git diff`, `git show`, `git log`) while operating under strict read-only review instructions.
- **`Model`**: Default to `"inherit"` for standard per-task reviews. Set to `"pro"` for whole-branch architectural reviews.
- **`Workspace: "inherit"`**: Shares current working tree and git database.

---

### 3. Reactive Wakeup (Zero Polling)

In Antigravity, the coordinator is woken automatically when the subagent completes its review and returns its evaluation.
- **Do NOT poll or loop on `manage_subagents` status.**
- Stop calling tools to yield control and wait for the notification.

---

### 4. Act on Feedback

Process the review findings using the `skills-that-thrill:receiving-code-review` skill:
- Fix **Critical** issues immediately
- Fix **Important** issues before proceeding to the next task
- Note **Minor** issues for later polish
- Push back with technical reasoning if the reviewer's premise is incorrect

> **Proof-of-Issue Requirement:**
> Reviewers must provide concrete proof for any Critical or Important issue:
> 1. Exact file and line citation with clickable links (`file:///...`).
> 2. The concrete triggering execution path or input condition.
> 3. The broken invariant or failure state.
> Reviewers must not raise speculative warnings without showing a reachable failure path.

---

## Concrete Example

```
[Completed Task 2: Add verification function]

Coordinator: Let me request code review before proceeding.

BASE_SHA=$(git log --oneline | grep "Task 1" | head -1 | awk '{print $1}')
HEAD_SHA=$(git rev-parse HEAD)

invoke_subagent:
  TypeName: "self"
  Role: "Code Reviewer"
  Prompt:
    DESCRIPTION: Added verifyIndex() and repairIndex() with 4 issue types
    PLAN_OR_REQUIREMENTS: Task 2 from documentation/plans/2026-09-28-2236-deployment-plan.md
    BASE_SHA: a7981ec
    HEAD_SHA: 3df7661

[Coordinator yields. Antigravity notifies when review completes]:
  Strengths: Clean architecture, real tests
  Issues:
    Important: Missing progress indicators
    Minor: Magic number (100) for reporting interval
  Assessment: Ready to proceed with fixes

Coordinator: [Fix progress indicators, run tests, proceed to Task 3]
```

---

## Common Rationalizations

| Excuse                                                                 | Reality                                                                                                                                                                                                                               |
|:-----------------------------------------------------------------------|:--------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------|
| "I'll just review the diff myself instead of dispatching a reviewer"   | You're the coordinator — reviewing the diff inline burns the context window you need to keep driving the work. Dispatch a reviewer subagent: the diff and the evaluation live in its context, and only the findings come back to you. |
| "The reviewer needs my whole session history to understand the change" | Hand it precisely crafted context, never your session's history. That keeps the reviewer on the work product, not your thought process.                                                                                               |
| "The change is tiny, review is overkill"                               | Small changes frequently introduce subtle edge cases or unverified assumptions.                                                                                                                                                       |

---

## Red Flags

**Never:**
- Skip review because "it's simple"
- Ignore Critical issues
- Proceed with unfixed Important issues
- Argue with valid technical feedback

**If reviewer is wrong:**
- Follow `skills-that-thrill:receiving-code-review`
- Push back with technical reasoning and tests proving behavior
- Escalate via `ask_question` if architectural decisions are at stake

See prompt template at: [code-reviewer.md](code-reviewer.md)
