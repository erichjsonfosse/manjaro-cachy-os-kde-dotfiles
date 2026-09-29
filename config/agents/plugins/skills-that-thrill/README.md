# Skills that thrill

Skills that thrill is a complete software development methodology for your coding agents, built on top of a set of composable skills and some initial instructions that make sure your agent uses them.


## Quickstart

Give your agent Skills that thrill: [Antigravity](#antigravity), [Gemini CLI](#gemini-cli).

## How it works

Something something...

## Installation

### Antigravity

- Local development / dotfiles:

  ```bash
  # Symlink to global plugins directory (prefer ~/.agents/ or ~/.gemini/):
  ln -sfn /path/to/skills-that-thrill ~/.agents/plugins/skills-that-thrill
  ln -sfn /path/to/skills-that-thrill ~/.gemini/config/plugins/skills-that-thrill
  ```

- Or via CLI:

  ```bash
  agy plugin install https://github.com/erichjsonfosse/skills-that-thrill
  ```

Antigravity automatically loads the plugin's `rules/AGENTS.md`, ensuring Skills that thrill is active from the first message.


### Gemini CLI

- Install the extension:

  ```bash
  gemini extensions install https://github.com/erichjsonfosse/skills-that-thrill
  ```

- Update later:

  ```bash
  gemini extensions update skills-that-thrill
  ```
## The Basic Workflow

1. **brainstorming** - Activates before writing code. Refines rough ideas through questions, explores alternatives, presents design in sections for validation. Saves design document.

2. **using-git-worktrees** - Activates after design approval. Creates isolated workspace on new branch, runs project setup, verifies clean test baseline.

3. **writing-plans** - Activates with approved design. Breaks work into bite-sized tasks (2-5 minutes each). Every task has exact file paths, complete code, verification steps.

4. **subagent-driven-development** or **executing-plans** - Activates with plan. Dispatches fresh subagent per task with two-stage review (spec compliance, then code quality), or executes in batches with human checkpoints.

5. **test-driven-development** - Activates during implementation. Enforces RED-GREEN-REFACTOR: write failing test, watch it fail, write minimal code, watch it pass, commit. Deletes code written before tests.

6. **requesting-code-review** - Activates between tasks. Reviews against plan, reports issues by severity. Critical issues block progress.

7. **finishing-a-development-branch** - Activates when tasks complete. Verifies tests, presents options (merge/PR/keep/discard), cleans up worktree.

**The agent checks for relevant skills before any task.** Mandatory workflows, not suggestions.

## What's Inside

### Skills Library

**Testing**
- **test-driven-development** - RED-GREEN-REFACTOR cycle (includes testing anti-patterns reference)
- **testing-e2e** - Playwright browser E2E test specs, Page Object Models, and test runner subagents

**Debugging & Verification**
- **systematic-debugging** - 4-phase root cause process (includes root-cause-tracing, defense-in-depth, condition-based-waiting techniques)
- **verification-before-completion** - Ensure it's actually fixed

**Security & Review**
- **reviewing-security** - Dedicated security, secrets, injection, and auth audits
- **requesting-code-review** - Pre-review checklist with proof-of-issue requirement
- **receiving-code-review** - Responding to feedback with technical rigor
- **adversarial-code-review** - Scored, 3-stage game-theoretic review (Finder, Adversary, Judge)

**Operations & Maintenance**
- **upgrading-dependencies** - Safe, phased dependency upgrades with release note inspection
- **managing-ci** - Deterministic, hardened GitHub Actions CI workflow engineering

**Agent Productivity & Memory**
- **running-lean** - Cross-cutting token-frugality mode and terse communication
- **capturing-learnings** - Durable gotchas and friction recording into project memory
- **authoring-agent-context** - Concise, high-signal `AGENTS.md` / `GEMINI.md` authoring

**Collaboration & Execution** 
- **brainstorming** - Socratic design refinement with non-requirements boundaries
- **writing-plans** - Detailed implementation plans
- **executing-plans** - Batch execution with checkpoints
- **dispatching-parallel-agents** - Concurrent subagent workflows
- **using-git-worktrees** - Parallel development branches
- **finishing-a-development-branch** - Merge/PR decision workflow
- **subagent-driven-development** - Fast iteration with two-stage review (spec compliance, then code quality)

**Meta**
- **writing-skills** - Create new skills following best practices (includes testing methodology)
- **using-skills-that-thrill** - Introduction to the skills system

## Updating

Skills that thrill updates are dependent on your coding agent.

## License

MIT License - see LICENSE file for details
