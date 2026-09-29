# Plan Document Reviewer Prompt Template

Use this template when dispatching a plan document reviewer subagent.

**Purpose:** Verify the plan is complete, matches the spec in `documentation/specs/`, and has proper task decomposition.

**Dispatch after:** The complete plan is written to `documentation/plans/`.

---

## Antigravity Dispatch (`invoke_subagent`)

```json
{
  "Subagents": [
    {
      "TypeName": "research",
      "Role": "Plan Document Reviewer",
      "Prompt": "You are a plan document reviewer. Verify this plan is complete and ready for implementation.\n\nPlan to review: [PLAN_FILE_PATH]\nSpec for reference: [SPEC_FILE_PATH]\n\nCheck for:\n1. Completeness: TODOs, placeholders, incomplete tasks, missing steps\n2. Spec Alignment: Plan covers all spec requirements, no unexpected scope creep\n3. Task Decomposition: Clear component boundaries, actionable 2-5 minute steps, TDD cycles\n4. Buildability: Concrete file paths, exact interfaces, code blocks for code steps\n\nCalibration: Only flag issues that would cause real problems during implementation.\n\nOutput format:\n## Plan Review\n**Status:** Approved | Issues Found\n**Issues (if any):**\n- [Task X, Step Y]: [specific issue] - [why it matters]\n**Recommendations (advisory):**\n- [suggestions]",
      "Model": "inherit",
      "Workspace": "inherit"
    }
  ]
}
```

---

## Generic Template (Cross-Harness)

```
Subagent (general-purpose):
  description: "Review plan document"
  prompt: |
    You are a plan document reviewer. Verify this plan is complete and ready for implementation.

    **Plan to review:** [PLAN_FILE_PATH]
    **Spec for reference:** [SPEC_FILE_PATH]

    ## What to Check

    | Category | What to Look For |
    |----------|------------------|
    | Completeness | TODOs, placeholders, incomplete tasks, missing steps |
    | Spec Alignment | Plan covers spec requirements, no major scope creep |
    | Task Decomposition | Tasks have clear boundaries, steps are actionable |
    | Buildability | Could an engineer follow this plan without getting stuck? |

    ## Calibration

    **Only flag issues that would cause real problems during implementation.**
    An implementer building the wrong thing or getting stuck is an issue.
    Minor wording, stylistic preferences, and "nice to have" suggestions are not.

    Approve unless there are serious gaps — missing requirements from the spec,
    contradictory steps, placeholder content, or tasks so vague they can't be acted on.

    ## Output Format

    ## Plan Review

    **Status:** Approved | Issues Found

    **Issues (if any):**
    - [Task X, Step Y]: [specific issue] - [why it matters for implementation]

    **Recommendations (advisory, do not block approval):**
    - [suggestions for improvement]
```

**Reviewer returns:** Status, Issues (if any), Recommendations
