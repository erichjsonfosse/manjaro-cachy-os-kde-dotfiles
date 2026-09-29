---
name: authoring-agent-context
description: Create and maintain AGENTS.md, CLAUDE.md, or equivalent context files that help AI coding agents work effectively in a repository. Use when authoring or regenerating AGENTS.md or CLAUDE.md, when agents repeatedly miss the same project context, when the project has non-standard build, test, or deployment commands, when conventions differ from common defaults, or whenever the user says "set up AGENTS.md" or "refresh the agent instructions".
---

# Authoring Agent Context

## Objective

Create concise, high-signal context files that help AI coding agents work
effectively in a repository without wasting tokens on information they can
discover themselves. The goal is a file that contains only what an agent
cannot infer from the code — specific build commands, non-obvious conventions,
custom tooling quirks, and project-specific constraints.

Research shows that verbose, LLM-generated context files can actually hurt
agent performance by forcing models to process unnecessary information. The
best context files are short, human-written, and limited to non-inferable
details.

## When to Use

- Setting up a repository for AI-assisted development for the first time
- Agents repeatedly make the same mistakes due to missing project context
- A new team member (human or agent) would need specific, non-obvious
  information to contribute effectively
- Build commands, test commands, or deployment steps are non-standard
- The project has conventions that differ from common defaults
- The user asks to "set up AGENTS.md", "configure for AI", or "make this
  repo work with coding agents"

Do not create a context file when:
- The project uses standard tooling with no customization (agents discover
  standard patterns from package.json, Makefile, etc.)
- The only content would be information already in README.md
- The file would just describe what the code does (agents read the code)

## Context

Before writing a context file, understand what agents already know and
what they struggle with:

1. **Identify the target tools.** Which AI coding agents will use this repo?
   - Antigravity CLI / IDE reads `AGENTS.md` (project root and `~/.agents/` or `~/.gemini/antigravity-cli/`)
   - Gemini CLI reads `GEMINI.md` (project root and `~/.gemini/GEMINI.md`, falling back to `AGENTS.md`)
   - Claude Code reads `CLAUDE.md` (project root and nested)
   - Codex CLI reads `AGENTS.md` (with directory-scoped overrides)
   - GitHub Copilot reads `.github/copilot-instructions.md`
   - Cursor reads `.cursor/rules/` files
   - Most modern coding agents read `AGENTS.md` as a cross-runtime open standard

2. **Identify what agents get wrong.** Review past agent sessions or think
   through what a new developer would get wrong:
   - Wrong build or test commands?
   - Wrong dependency manager?
   - Missing environment setup steps?
   - Violating a naming convention or code pattern?
   - Using a deprecated API or approach?

3. **Separate inferable from non-inferable.** Agents can discover:
   - Language and framework (from file extensions, configs)
   - Dependencies (from package manifests)
   - Project structure (from directory listing)
   - Code patterns (from reading existing code)

   Agents cannot discover:
   - Custom build commands not in standard config files
   - Why a convention exists (and that violating it breaks things)
   - Environment-specific setup steps
   - Security-sensitive workflows (what NOT to do)
   - Team-specific review or commit conventions

## Workflow

### 1. Audit Current Agent Friction Points

Before writing anything, identify the specific problems:

- What do agents get wrong repeatedly in this repo?
- What commands fail because the agent guesses wrong?
- What conventions does the agent violate?
- What setup steps does a new contributor need that are not obvious?

If you do not have evidence of agent friction, observe one session and note
where the agent stumbles. Do not write a context file based on speculation.

### 2. Choose the File Format

Pick the format that matches your primary AI tool:

| Tool | File | Scope |
|------|------|-------|
| Cross-tool standard | `AGENTS.md` (repo root) | All agents |
| Claude Code | `CLAUDE.md` (repo root) | Claude Code sessions |
| GitHub Copilot | `.github/copilot-instructions.md` | Copilot workspace |
| Cursor | `.cursor/rules/*.md` | Cursor sessions |
| Codex CLI | `AGENTS.md` + `AGENTS.override.md` | Codex sessions |

For maximum compatibility, write `AGENTS.md` at the repo root. Add
tool-specific files only if you need tool-specific instructions.

For monorepos, place additional context files in subdirectories. Most agents
read the nearest file in the directory tree upward.

### 3. Write Only Non-Inferable Content

Structure the file with short, specific sections. Every line must pass the
test: "Could an agent figure this out by reading the code?" If yes, omit it.

**Include:**
- Custom build, test, lint, and deploy commands
- Environment setup steps (required env vars, services, databases)
- Non-obvious conventions (naming, file organization, commit messages)
- Security constraints (what not to do, what requires manual approval)
- Common pitfalls specific to this codebase
- Dependency management quirks

**Exclude:**
- Project description (agents read README)
- Architecture overview (agents read the code)
- Technology stack listing (agents detect this)
- Coding style basics (agents detect from existing code)
- Information already in README, CONTRIBUTING, or package configs

### 4. Keep It Under 100 Lines

The best context files are 30-80 lines. Every additional line is tokens the
agent processes before doing useful work. Research shows longer files increase
the number of steps agents take without improving task success.

If you need more than 100 lines, split into directory-scoped files:
- Root `AGENTS.md`: repo-wide conventions and commands
- `services/api/AGENTS.md`: API-specific instructions
- `packages/ui/AGENTS.md`: UI-specific instructions

### 5. Use Imperative, Agent-Directed Language

Write instructions as direct commands. Agents respond better to imperative
instructions than descriptive prose.

Good: "Run `make test-integration` for integration tests, not `make test`."
Bad: "The project has integration tests that can be run using make."

Good: "Never modify files in `generated/` — they are auto-generated from
schemas in `schemas/`."
Bad: "The generated/ directory contains auto-generated files."

Good: "Use the workspace package manager for all installs. Other managers are
not configured for this workspace."
Bad: "This project uses a specific package manager."

### 6. Validate With a Real Agent Session

After creating the file, run a representative task with an AI agent and
verify:
- The agent uses the correct build/test commands
- The agent follows the conventions specified
- The agent does not waste time on things the context file should prevent
- The agent does not perform unnecessary exploration due to verbose context

If the agent ignores part of the context file or performs worse, trim or
rewrite that section.

## Output Contract

A completed authoring-agent-context pass produces these sections under `## Output Contract`:

### Summary

One sentence stating what was created or updated (e.g. "Wrote 62-line AGENTS.md
covering build/test/lint commands, monorepo conventions, and known pitfalls").

### Detail

The context file itself. Include only the sections relevant to the project; use
this template and delete what's not needed:

```markdown
# AGENTS.md

## Build & Test
- Build: `[exact command]`
- Test: `[exact command]`
- Lint: `[exact command]`
- Type check: `[exact command]`

## Environment Setup
- [Required setup step with exact command]
- [Required env var: what it's for, not the value]

## Conventions
- [Convention with rationale if non-obvious]
- [Convention with rationale if non-obvious]

## Do Not
- [Prohibited action with brief reason]
- [Prohibited action with brief reason]

## Common Pitfalls
- [Pitfall: what goes wrong and how to avoid it]
```

See ./references/example-agents-md.md for a worked example following this template.

### Verification

- File path written and final line count (target 30–80, hard cap 100)
- Confirmation that every line passes the "could an agent infer this from
  the code?" test
- Result of a representative agent session run with the file (correct
  commands used, conventions followed, no wasted exploration)

### Follow-ups

- Content explicitly deferred to directory-scoped context files
- Known gaps that are not yet observed but may need entries later
- "None" when the file is complete and validated

## Quality Bar

A context file meets the quality bar when:

- Every line contains information an agent cannot discover from the code
- Total length is under 100 lines (ideally 30-80)
- Commands are exact and copy-pasteable, not described in prose
- An agent session using this file makes fewer mistakes than one without it
- No duplication with README, CONTRIBUTING, or config files
- Instructions are imperative and specific, not descriptive and vague
- The file is actually maintained — stale instructions are worse than none

A context file fails the quality bar when:

- It describes what the code does (agents read the code)
- It lists the tech stack (agents detect this from configs)
- It exceeds 100 lines without directory-scoped splitting
- Commands are described instead of shown (e.g., "run the test suite"
  instead of the exact command)
- It was generated by an LLM without human review
- It contains information already in README or config files
- It has not been validated with an actual agent session

## Anti-Patterns

**The project essay.** A 200-line file describing the project's architecture,
history, and design philosophy. Agents do not need a narrative. They need
specific instructions for the things they get wrong.

**The LLM-generated context file.** Asking an AI to write its own context
file typically produces verbose, generic content that adds token overhead
without adding signal. Research shows LLM-generated context files have a
marginally negative effect on task success rates.

**The stale context file.** A context file written once and never updated.
Stale instructions actively mislead agents — they follow the wrong commands
with confidence. If you cannot maintain it, do not create it.

**The duplicate file.** Creating AGENTS.md, CLAUDE.md, and
copilot-instructions.md with the same content. Maintain one source of truth
(AGENTS.md) and use tool-specific files only for tool-specific instructions.
Duplication guarantees inconsistency.

**The kitchen sink.** Including every possible instruction "just in case."
Each unnecessary line costs tokens and attention. Include only instructions
that address observed problems or non-obvious conventions.

## Critical Rules

1. **Only non-inferable content.** Every line must pass the test: "Could an
   agent figure this out from the code?" If yes, delete it. The context file
   is for the gaps, not a summary.

2. **Short is better.** Aim for 30-80 lines. Research confirms that longer
   context files increase agent steps without improving outcomes. When in
   doubt, cut.

3. **Commands, not descriptions.** Show the exact command. Do not describe
   what the command does in prose. Agents execute commands; they do not read
   about commands.

4. **Validate empirically.** Test the context file with a real agent session.
   If the agent does not demonstrably work better with the file, revise or
   remove content until it does.

5. **Maintain or delete.** A context file is a living document. When commands
   change, conventions change, or tooling changes, update the file. If no one
   is maintaining it, delete it — stale guidance is worse than no guidance.

6. **One source of truth.** Use AGENTS.md as the cross-tool standard. Add
   tool-specific files only when tool-specific instructions are needed.
   Never duplicate content across files.

7. **Human-written only.** Do not auto-generate context files. Human judgment
   about what agents struggle with is the entire value. LLM-generated files
   add noise, not signal.
