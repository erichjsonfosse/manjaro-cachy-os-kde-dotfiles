---
name: managing-ci
description: Configure, harden, and troubleshoot continuous integration workflows for reliability, security, and fast feedback. Use when setting up CI on a new repo, when adding build, test, or quality jobs to an existing workflow, when diagnosing failing or flaky checks, when hardening workflow permissions or secret handling, when locking actions to prevent supply-chain drift, or whenever the user mentions the build, CI, or workflow files.
---

# Managing CI

## Objective

Make continuous integration workflows deterministic, secure, and maintainable.
A well-managed CI workflow catches real problems fast, never leaks secrets,
runs the same way every time, and gives actionable feedback when something
breaks. The goal is a workflow that a new contributor can read, trust, and
debug — not one that passes by accident and fails mysteriously.

## When to Use

- Setting up a CI workflow for a new project or repository
- Adding build, test, or quality check jobs to an existing workflow
- Diagnosing and fixing failing or flaky automated checks
- Hardening workflow permissions and secret handling
- Reorganizing workflow files for clarity and maintainability
- Pinning dependencies and actions to prevent supply-chain drift
- Improving failure diagnostics so developers can fix issues without
  re-running the entire workflow locally
- Adding matrix testing for multiple runtime versions or platforms

Do not use this skill for:

- Deployment or release automation (use deployment-specific skills instead)
- Writing application code to make tests pass (use implementation skills)
- Reviewing pull requests (use code review skills)

CI workflow management is about the automation infrastructure, not the
application code it runs.

## Context

Before modifying any workflow, gather the information that determines what's
possible and what's safe:

> **Quick reference:** pin all action and runtime versions, scope job
> permissions to the minimum required, isolate jobs by responsibility (build /
> test / quality / security), and keep outputs deterministic so the same inputs
> always produce the same result. The deeper sections below expand on each
> point.

### 1. Understand the Current State

- Read existing workflow files and their trigger configurations
- Identify which events trigger which jobs (push, pull request, schedule,
  manual dispatch)
- Map the job dependency graph — which jobs depend on others?
- Check current permission scopes and secret usage
- Review caching configuration and its effectiveness
- Note any workflow files that are disabled, commented out, or dead

### 2. Identify the CI Requirements

- What must be verified on every change? (build, tests, lint, type checking,
  formatting, security scanning)
- What platforms and runtime versions must be covered?
- What's the acceptable feedback time? Fast feedback loops matter — a CI
  workflow that takes 30 minutes discourages frequent pushes
- Are there artifact outputs needed? (build outputs, coverage reports, test
  results)

### 3. Map the Security Surface

- Which secrets does the workflow need, and at which steps?
- What external services or registries are accessed?
- Which third-party actions are used, and are they pinned by SHA?
- Do any jobs run with write permissions that could be reduced?
- Are fork-triggered workflows isolated from secrets?

## Workflow

### 1. Organize Workflow Structure

Separate concerns into distinct workflow files or jobs:

- **Build job:** Compile, bundle, or prepare the project. Runs first so
  downstream jobs can assume a valid build.
- **Test job:** Run the project's test suite. Depends on build if tests
  require compiled output. Use matrix strategy for multiple versions.
- **Quality job:** Run your linter, formatter check, and type checker. These
  can often run in parallel with tests since they have no shared state.
- **Security job:** Run dependency audits and vulnerability scanning.
  Separate from tests to keep the failure signals distinct.

Keep each job focused. A single job that builds, tests, lints, and deploys
gives poor diagnostics — when it fails, you don't know which stage broke
without reading the full log.

### 2. Eliminate Nondeterminism

Flaky workflows erode trust. Address the common sources:

- **Pin all action versions by commit SHA**, not by mutable tag. Tags can be
  moved or deleted; a SHA is immutable. Add a comment with the version number
  for readability.
- **Pin runtime versions explicitly.** Don't use "latest" for language
  runtimes, base images, or tool versions. Specify exact versions so the
  workflow behaves identically next week.
- **Use lock files for dependency installation.** Your package manager's lock
  file is the source of truth. Use the install mode that respects the lock
  file without modifying it.
- **Configure caching with stable keys.** Cache keys should incorporate the
  lock file hash so they invalidate when dependencies change, not randomly.
- **Set explicit timeouts** on jobs and steps. A hung process should fail
  fast, not consume resources for the maximum allowed duration.

### 3. Harden Permissions

Apply the principle of least privilege to every workflow:

- **Set top-level permissions to read-only** on the repository, then grant
  additional permissions only to jobs and steps that need them.
- **Isolate steps that need write permissions.** If only one step needs to
  push a commit or write a comment, don't grant that permission to the entire
  job.
- **Never expose secrets to steps that don't need them.** Pass secrets to
  specific steps via environment variables, not as workflow-level defaults.
- **Never hardcode secrets in workflow files.** Use your CI system's secret
  storage and reference them by name.
- **Restrict fork access.** Workflows triggered by forks should not have
  access to repository secrets. Use appropriate event types that distinguish
  between trusted and untrusted sources.
- **Audit third-party actions.** Before adding any external action, verify
  its source, check its permissions requirements, and pin it by SHA.

### 4. Configure Matrix Testing

When the project must work across multiple versions or platforms:

- Define the matrix explicitly — list each version rather than using dynamic
  ranges that may include unexpected entries.
- Use fail-fast judiciously. For PR checks, fail-fast saves time. For
  scheduled or release builds, run all combinations to get the full picture.
- Include only meaningful combinations. Testing every permutation of OS,
  language version, and dependency version is expensive. Focus on the
  combinations your users actually run.

### 5. Manage Artifacts

- Upload build outputs, test results, and coverage reports as workflow
  artifacts when they're needed for debugging or downstream use.
- Set retention periods appropriate to the artifact type. Build logs need
  days, not months.
- Name artifacts clearly so they can be identified without opening them.

### 6. Engineer Failure Diagnostics

When a workflow fails, the developer's first question is "what broke and why?"
Make that answer immediate:

- **Print actionable context on failure.** Test results, error summaries,
  and environment details should appear in the log without requiring artifact
  download.
- **Use conditional steps** that run only on failure to collect diagnostic
  information (system state, process lists, disk usage, dependency trees).
- **Annotate results** so failures surface directly in the pull request or
  commit status, not buried in log output.
- **Keep logs readable.** Group steps logically so the relevant output is
  easy to find. Avoid dumping enormous debug output by default — gate
  verbose output behind a debug flag or failure condition.

### 7. Triage Workflow Failures

**Tooling note:** Use the strongest CI-status integration available —
GitHub MCP server or `gh` CLI (`gh run list`, `gh run view`, `gh run
view --log-failed`) for GitHub-hosted CI, the equivalent CLI or MCP for
Bitbucket, Azure DevOps, GitLab, or whatever CI host the project uses.
If none is available, ask the user to share the failing job log; missing
integration is not a fail-stop.

When diagnosing a failing workflow:

1. **Read the error output first.** Identify whether the failure is in setup
   (dependency installation, environment), execution (build or test), or
   infrastructure (timeouts, resource limits, network).
2. **Reproduce locally when possible.** Run the same commands with the same
   versions. Many CI failures are reproducible outside CI.
3. **Check for recent changes.** Did a dependency update, a workflow file
   change, or an infrastructure change coincide with the failure?
4. **Distinguish flaky from broken.** Re-run the workflow once. If it passes
   intermittently, the issue is nondeterminism (timing, external services,
   resource contention). If it fails consistently, the issue is a real defect.
5. **Fix the workflow, then verify.** After making changes, run the workflow
   and confirm the specific failure is resolved. Don't assume a green check
   means the fix worked — verify the relevant job and step.

## Output Contract

Every CI workflow change produces these sections under `## Output Contract`:

### Summary

One sentence stating what changed in CI (e.g. "Added a parallel test shard and
tightened workflow permissions on the publish job").

### Detail

**Changes:**

- What was added, modified, or removed in workflow configuration
- Which jobs or steps are affected

**Impact:**

- Effect on build time (faster, slower, unchanged)
- Effect on security posture (tighter permissions, new secret usage, etc.)
- Effect on reliability (reduced flakiness, added determinism)

### Verification

- Evidence that the workflow runs successfully after the change
- Specific jobs and steps observed to pass or fail
- Comparison to previous behavior when relevant

### Follow-ups

- Any remaining issues not addressed in this change
- Recommendations for future improvements (caching, parallelism, additional
  checks)
- "None" when the workflow is fully sound

## Quality Bar

A CI workflow meets the quality bar when:

- A new contributor can read the workflow file and understand what it does
  without external documentation
- Every action and dependency version is pinned to an immutable reference
- Permissions are minimal — no job has write access unless it demonstrably
  needs it
- Failures produce an error message that tells the developer what to fix
- The workflow completes in a reasonable time for the feedback loop it serves
- Secrets are used only in the steps that need them and never appear in logs
- Matrix configurations cover the supported platforms without redundant
  combinations
- Caching is effective and invalidates correctly when dependencies change

A CI workflow fails the quality bar when:

- Actions are pinned by mutable tags that can change without notice
- The entire workflow has write permissions because one step needs them
- Failure output says "exit code 1" with no context about what failed
- The workflow takes so long that developers skip waiting for results
- Secrets are passed as workflow-level environment variables to all jobs

## Anti-Patterns

**The kitchen-sink job.** One massive job that builds, tests, lints, scans,
and deploys. When it fails, you don't know what broke without reading the
entire log. Split into focused jobs with clear dependencies.

**The snowflake workflow.** A workflow that works only because of undocumented
assumptions about the CI environment — specific tools pre-installed, specific
network access, specific file system state. Make all dependencies explicit.

**The retry hammer.** Automatically retrying failed steps instead of fixing
the root cause. Retries mask flakiness and make failures intermittent instead
of visible. Fix nondeterminism at the source.

**The secret sprawl.** Granting every job access to every secret because it's
easier than figuring out which job needs what. This maximizes blast radius
when a single step is compromised.

**The stale cache.** Caching aggressively with keys that never change, so
developers get mysterious failures from cached state that no longer matches
the code. Cache keys must incorporate dependency version information.

## Critical Rules

1. **Never hardcode secrets in workflow files.** Not in environment variables,
   not in command arguments, not in comments. Use your CI system's secret
   storage exclusively.

2. **Pin every external dependency by immutable reference.** Actions by commit
   SHA, runtime versions by exact number, base images by digest. Mutable
   references (tags, "latest", version ranges) are a supply-chain risk.

3. **Use least-privilege permissions.** Start with read-only at the workflow
   level. Grant write only to the specific jobs and steps that need it. Audit
   permissions when adding new steps.

4. **Make failures actionable.** Every failure path must produce output that
   tells a developer what broke, where, and ideally how to investigate. A CI
   workflow that says "failed" without context is worse than no CI at all —
   it trains people to ignore the signal.

5. **Keep feedback fast.** CI exists to give developers confidence before
   merging. A workflow that takes longer than the developer's attention span
   becomes a bottleneck that gets ignored. Optimize for the common case:
   a focused change that passes.

6. **Separate concerns into distinct jobs.** Build, test, lint, and scan
   should be independent jobs so failures are immediately attributable and
   unrelated checks are not blocked by one failure.

7. **Test the workflow itself.** After modifying CI configuration, verify the
   change works. Don't merge workflow changes without evidence that the
   modified jobs run correctly.
