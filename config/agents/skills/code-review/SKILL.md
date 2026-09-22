---
name: review
description: Perform a code review against uncommitted changes, a specific commit, or a base branch.
---

# Code Review Protocol

When the user asks for a review (or types `/review`), execute the following workflow:

## 1. Scope Determination
Check the Git status to identify what needs reviewing:
* If the user specifies a base branch (e.g., `main`), fetch diff: `git diff origin/main...HEAD`
* If the user specifies a commit hash, fetch diff: `git show <commit_hash>`
* Otherwise, default to uncommitted changes: `git diff HEAD` and inspect untracked files with `git status --porcelain`.

## 2. Review Guidelines
Analyze the patch without modifying any files on disk. Focus strictly on actionable findings:

* 🚨 **CRITICAL (Blockers):** Security vulnerabilities, memory leaks, data corruption, crashes, breaking API contracts.
* ⚠️ **HIGH (Logic & Reliability):** Logic errors, unhandled edge cases, concurrency issues, missing error bounds.
* 💡 **MEDIUM (Quality & Maintainability):** Performance regressions, poor error messages, structural design smells.

## 3. Formatting Output
Group your findings by file path and line numbers:

```
📄 path/to/file.ext
[CRITICAL] Line 45: Potential SQL injection via direct string interpolation.

Suggested Fix: Use parameterized queries instead.

[HIGH] Line 112: Potential NullPointer if response.data is empty.
```

If no issues are found, explicitly output: `✅ Review complete: No critical or high-priority issues detected.`
