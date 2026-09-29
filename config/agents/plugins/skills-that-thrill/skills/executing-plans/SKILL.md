---
name: executing-plans
description: Use when you have a written implementation plan to execute directly with review checkpoints
---

# Executing Plans

Execute an implementation plan directly within a session, tracking progress with Antigravity Task Artifacts and validating progress at interactive review checkpoints.

**Announce at start:** "I'm using the executing-plans skill to implement this plan."

**When to use:** Use this skill when executing plans inline within the current session, particularly for tightly coupled tasks or small sequential edits. If tasks are independent and modular, `skills-that-thrill:subagent-driven-development` is also available to run tasks in isolated subagents.

---

## The Process

### Step 1: Load and Review Plan

1. **Workspace Isolation:** Verify work happens in an isolated workspace: use `skills-that-thrill:using-git-worktrees` to ensure a sibling worktree (`my-project/<branch>`). Never start implementation on a main/master branch without explicit human partner consent.
2. **Read Plan & Specs:** Read the plan from `documentation/plans/` and review the corresponding design spec in `documentation/specs/`.
3. **Review Critically:** Check for contradictions, ambiguities, or missing requirements. If you find concerns, raise them with your human partner via `ask_question` before beginning.
4. **Initialize Task Tracking:** Create a user-facing **Task Artifact** at `<appDataDir>/brain/<conversation-id>/executing_<plan_slug>_tasks.md` using `write_to_file` with `ArtifactMetadata` (`UserFacing: true`, `RequestFeedback: false`).

---

### Step 2: Execute Tasks (Per-Task Loop)

For each task in the plan:

1. **Mark In Progress:** Update the task status in the Task Artifact to `- [/]` using `replace_file_content`.
2. **Implement:** Follow each step of the task exactly. If implementing code features or bugfixes, use `skills-that-thrill:test-driven-development` (RED-GREEN-REFACTOR).
3. **Verify (Mandatory Gate):** Run verifications as specified in the plan. Apply `skills-that-thrill:verification-before-completion` — you MUST run verification commands in this turn and observe fresh exit code 0 evidence before claiming success or presenting the review checkpoint.
   > [!IMPORTANT]
   > **Harness Command Safety:** Never propose a standalone `cd` command across tool calls. Always pass `Cwd: "$WORKTREE_PATH"` to `run_command`, or execute within subshells `(cd "$WORKTREE_PATH" && command)`.
4. **Mark Completed:** Update the task status in the Task Artifact to `- [x]` using `replace_file_content`.
5. **Interactive Review Checkpoint:** Only after obtaining fresh passing verification evidence, prompt your human partner after completing each task (or task batch) via `ask_question`:
   - `(Recommended) Proceed to Task N+1`
   - `Review Task N code changes before proceeding`
   - `Request adjustments to Task N`

---

### Step 3: Complete Development

After all tasks are completed and verified:

1. **Pre-Finish Review (Recommended):** Dispatch a code reviewer subagent via `skills-that-thrill:requesting-code-review`. For critical, security-sensitive, or complex branch features, consider invoking `skills-that-thrill:adversarial-code-review` and `skills-that-thrill:reviewing-security`.
2. **Announce:** "I'm using the finishing-a-development-branch skill to complete this work."
3. **REQUIRED SUB-SKILL:** Use `skills-that-thrill:finishing-a-development-branch`.
4. Follow that skill to verify tests, present integration options, and execute choice.

---

## When to Stop and Ask for Help

**STOP executing immediately when:**
- Hit a blocker (missing dependency, test failure, instruction unclear).
- Plan has critical gaps preventing starting.
- You don't understand an instruction or encounter unexpected behavior.
- Verification fails repeatedly.

**Do not guess or force through blockers.** Use `ask_question` to ask for clarification and agree on adjustments before proceeding.

---

## When to Revisit Earlier Steps

**Return to Review (Step 1) when:**
- Partner updates the plan based on feedback.
- Fundamental architecture needs rethinking.

---

## Remember

- Review plan critically first.
- Track progress via Antigravity Task Artifacts.
- Never propose standalone `cd` commands; specify `Cwd` directly.
- Follow plan steps and TDD discipline.
- Don't skip verification.
- Stop when blocked; don't guess.
- Never start implementation on main/master branch without explicit user consent.
