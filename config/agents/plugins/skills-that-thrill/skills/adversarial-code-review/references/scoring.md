# Scoring Rubric

## Severity to Points

| Severity | Points | Meaning |
|---|---:|---|
| Minor | 1 | Real but limited impact, narrow blast radius, or low-likelihood defect |
| Moderate | 3 | User-visible defect, bounded reliability risk, or meaningful regression risk |
| Major | 6 | High-impact bug, security weakness with realistic reach, data integrity issue, or broad outage risk |
| Critical | 10 | Severe security flaw, irreversible data loss/corruption, or catastrophic reliability failure |

## Confidence Levels

| Confidence | Meaning |
|---|---|
| High | Direct proof from code path, invariant break, or unavoidable scenario |
| Medium | Strong evidence with one or two reasonable assumptions |
| Low | Plausible but not fully proven from available context |

Prefer medium or high confidence. Low-confidence issues should be rare and only included when the risk is still meaningful.

## Proof Standard

Every issue must include proof strong enough for another reviewer to follow:

1. Cite concrete code locations such as file paths, line numbers, symbols, or diff hunks.
2. Explain the triggering scenario or execution path.
3. State why the current code permits the bad outcome.
4. State the impact.

Good proof usually looks like:

- `src/auth.ts:84-96` trusts `role` from the request body before authorization is enforced.
- `saveOrder()` writes the parent row before child validation and has no rollback path, so partial state can persist on failure.

## Downgrade Rules

The adversary may downgrade an issue when:

- the issue is real but the blast radius is smaller than claimed
- a guard exists that limits the triggering scenario
- the issue is only reachable behind a stronger prerequisite than the finder assumed

Award the adversary the point difference between the original and final severity.

## Rejection Rules

Reject an issue when the challenger shows that:

- the supposed bad path is impossible in the actual code
- an existing guard or invariant already prevents the outcome
- the evidence is too speculative to justify a scored finding
