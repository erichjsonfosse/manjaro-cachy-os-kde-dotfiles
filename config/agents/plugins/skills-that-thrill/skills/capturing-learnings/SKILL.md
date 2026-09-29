---
name: capturing-learnings
description: Capture durable lessons from high-friction tasks and store them so future sessions can reuse them at the point of need. Use when a non-obvious root cause was just resolved, when a tool or library behaved unexpectedly and the workaround is worth preserving, when an undocumented project convention caused confusion, or whenever the user says "remember this", "save a lesson", or "document this gotcha".
---

# Capturing Learnings

## Objective

Turn hard-won task knowledge into durable, retrievable entries that prevent
future sessions from repeating the same investigation. A captured learning
is not documentation — it's a specific, actionable signal that surfaces at
the right moment to short-circuit a problem someone has already solved.
Good learnings are terse, concrete, and tied to a recognizable trigger
condition so they activate when the same situation recurs, not when someone
happens to browse a file.

## When to Use

- A task required significant debugging and the root cause was non-obvious
- A tool, library, or service behaved differently than expected and the
  workaround is worth preserving
- A project convention exists that isn't documented and caused confusion
- A setup or configuration step fails in a way that wastes time if repeated
- A failure-to-success recovery pattern emerged that would help future work
- A recurring issue was resolved and the fix should be the default approach
- A teammate or future agent is likely to hit the same friction point

Do not use this skill for:

- Documenting features or API usage (use project documentation instead)
- Recording architectural decisions (use decision-record skills instead)
- Writing onboarding guides or tutorials (use documentation skills instead)
- Storing credentials, tokens, or personal data (never capture secrets)

The boundary: this skill captures specific, reusable signals from friction.
General documentation, decision records, and guides are separate concerns.

## Context

Before capturing a learning, determine whether it's worth preserving and how
to make it findable later:

### 1. Assess Capture Worthiness

Not every piece of task knowledge deserves a permanent entry. Evaluate:

- **Recurrence likelihood:** Will this situation come up again? A one-off
  issue with a since-deleted file is not worth capturing. A gotcha in a
  commonly-used library is.
- **Investigation cost:** How long did it take to figure this out? If the
  answer took five minutes of reading docs, it's probably not worth a learning
  entry. If it took an hour of debugging with misleading error messages, it
  is.
- **Discoverability gap:** Is this knowledge easy to find through normal
  channels (official docs, error messages, search)? If yes, skip it. If the
  answer is buried in a forum thread from three years ago or requires
  combining information from multiple sources, capture it.
- **Scope match:** Is this specific to the current project, or is it general
  knowledge? Project-specific learnings go in the project's knowledge store.
  General tool behavior might belong in a personal reference instead.

If fewer than two of these criteria are met, the learning probably doesn't
warrant capture. Move on.

### 2. Identify the Trigger Condition

A learning that says "the library has a bug" is useless. A learning that
says "when you see error X after doing Y, the cause is Z" is immediately
actionable. Before writing the entry, identify:

- What observable situation triggers this knowledge? (An error message, a
  configuration pattern, a specific file type, a sequence of operations)
- What would a future agent or developer be doing when they need this?
- What search terms or file patterns would they encounter?

The trigger condition determines when the learning resurfaces. If you can't
state it concretely, the learning won't activate when it's needed.

### 3. Locate the Knowledge Store

Determine where learnings are stored in this project:

- Check for an existing knowledge file (commonly in project metadata, docs
  directory, or a dedicated knowledge directory)
- If no convention exists, establish one and state it explicitly
- Verify you have write access to the target location
- Note the existing format if entries already exist — match it for
  consistency

### 4. Storage Modes

Two storage modes are common; pick the one that matches the project's needs:

- **Minimal mode:** a single human-readable lessons log (for example,
  `docs/ai-memory.md`). Easy to scan, easy to edit, suitable for projects
  with a small set of high-value learnings.
- **Structured mode:** a `.ai-memory/` directory with append-only JSONL files
  (`events.jsonl`, `candidates.jsonl`, `memories.jsonl`) for projects that
  want time-ordered, machine-readable logs that downstream tools can index.

If neither convention exists yet, choose one explicitly and note the choice
in the entry.

## Workflow

### 1. Capture the Raw Signal

Immediately after the friction event, while context is fresh:

- Write down what happened — the task, the obstacle, the misleading signals,
  and the resolution
- Include the exact error messages, symptoms, or conditions that made this
  confusing
- Note what you tried that didn't work and why it didn't work — failed
  attempts are valuable negative signal
- Record the environment or version context if the behavior is version-
  specific

Don't polish yet. Raw capture preserves details that feel obvious now but
won't be in three months.

### 2. Distill to Reusable Signal

Strip the raw capture down to what a future reader needs:

- **Remove narrative.** "I spent two hours trying different approaches" is
  context for you, not signal for the reader. Keep the finding, drop the
  story.
- **Remove ephemeral details.** File paths that will change, ticket numbers
  that won't be searchable, names of people involved — these expire quickly.
- **Preserve the trigger.** The specific observable condition that indicates
  this learning is relevant.
- **Preserve the resolution.** The concrete action that resolves the issue.
- **Preserve the reason.** Why the resolution works — without this, the
  learning can't be adapted to similar-but-different situations.

A distilled learning should be readable in under 30 seconds and actionable
immediately.

### 3. Categorize the Entry

Assign a category that helps with retrieval and staleness management:

- **Gotcha:** A non-obvious behavior that causes confusion or errors. These
  are the most common and most valuable learnings. Example: "When X appears
  to be true but is actually false because of Y."
- **Pattern:** A recurring solution shape that applies across multiple
  situations. Example: "When encountering type Z problems, the effective
  approach is A-B-C."
- **Convention:** A project-specific rule that isn't enforced by tooling but
  matters for consistency. Example: "Always do X before Y in this codebase
  because Z depends on the order."
- **Tool behavior:** A specific behavior of a tool, library, or service that
  differs from documentation or reasonable expectation. Example: "Despite
  the docs saying X, the actual behavior is Y when Z is configured."

If a learning doesn't fit any category, it might be too vague. Sharpen the
trigger condition and try again.

### 4. Format the Entry

Write the learning in a consistent format that supports scanning and search:

- **Trigger:** One line describing the observable situation that activates
  this learning (error message, pattern, task type)
- **Learning:** One to three sentences with the actual knowledge — what's
  happening, why, and what to do about it
- **Category:** One of: gotcha, pattern, convention, tool-behavior
- **Scope:** Project-specific or general
- **Added:** Date of capture for staleness tracking

Keep it terse. The learning format is closer to a commit message than a blog
post. If it takes more than a paragraph to explain, it might need to be split
into multiple entries or captured as documentation instead.

### 5. Store the Entry

Append the formatted entry to the project's knowledge store:

- Add to the existing file in the established format
- Place new entries at the end or in the appropriate category section
- Do not modify or reformat existing entries during capture — that's a
  separate maintenance task
- Verify the entry is syntactically valid and doesn't break the file format

### 6. Verify Retrievability

After storing, confirm the learning can be found when needed:

- Search the knowledge store for the trigger condition terms — does the
  entry surface?
- Read the entry cold, as if you'd never seen the original problem. Is it
  clear what situation it addresses and what action to take?
- If the trigger condition is too generic (matches too many situations) or
  too specific (matches only one exact scenario), adjust it

### 7. Set Staleness Expectations

Not all learnings age the same way:

- **Tool behavior** entries become stale when the tool version changes.
  Note the version if the behavior is version-specific.
- **Convention** entries become stale when the project's practices evolve.
  These should be reviewed when major structural changes happen.
- **Gotcha** entries may become stale when the underlying cause is fixed
  upstream. Note the conditions under which the gotcha would no longer apply.
- **Pattern** entries are the most durable — they encode problem-solving
  approaches that outlast specific tool versions. These rarely go stale.

## Output Contract

Every learning capture produces these sections under `## Output Contract`:

### Summary

One sentence stating what was learned and where it was filed (e.g. "Captured
a tool-behavior gotcha about cache invalidation into `docs/ai-memory.md`").

### Detail

**Entry** — the formatted learning as it appears in the knowledge store:

- Trigger condition (one line)
- Learning body (one to three sentences)
- Category (gotcha / pattern / convention / tool-behavior)
- Scope (project-specific / general)
- Date added

**Location:**

- File path where the entry was stored
- Position within the file (appended, inserted into category section)
- Whether a new file or section was created

**Reuse trigger:**

- Description of when this learning should surface in future work
- What a future agent or developer would be doing when they need this
- Recommended search terms or file patterns for retrieval

### Verification

- Search the knowledge store for the trigger condition terms — confirm the
  entry surfaces
- Read the entry cold (as if you'd never seen the original problem) — confirm
  the situation and action are clear
- Confirm the entry contains no credentials, tokens, or personal data

### Follow-ups

- Related learnings that may need their own entries
- Staleness conditions worth recording (versions, conventions to revisit)
- "None" if the entry is self-contained

## Quality Bar

A captured learning meets the quality bar when:

- The trigger condition is specific enough to activate in the right
  situations and not in unrelated ones
- The learning body is actionable — a reader can apply it without further
  research
- The entry is self-contained — it doesn't require reading other entries or
  external resources to understand
- The category is accurate and the scope is correctly identified
- The format matches the existing entries in the knowledge store
- A cold reader (someone who wasn't present for the friction event) can
  understand and use the entry
- The entry contains no credentials, tokens, or personal data

A captured learning fails the quality bar when:

- The trigger condition is vague ("when something goes wrong with the
  build")
- The learning is advice rather than a finding ("always be careful with X"
  vs. "X fails silently when Y because Z")
- The entry requires context from the original task to understand
- The learning duplicates existing documentation that is easily findable
- The entry captures a one-off situation with near-zero recurrence
  probability
- The format deviates from the established convention without reason

## Anti-Patterns

**The journal entry.** Writing a narrative of what happened during the task
instead of distilling the reusable signal. "Today I spent two hours debugging
the build and eventually found that..." is a journal entry. "When the build
fails with error X, the cause is Y — fix by doing Z" is a learning.

**The fortune cookie.** Capturing vague advice instead of specific findings.
"Be careful with configuration files" teaches nothing. "The configuration
loader silently ignores entries after a blank line, causing values to
disappear" teaches exactly what to check and when.

**The knowledge hoarder.** Capturing everything regardless of recurrence
likelihood or investigation cost. A knowledge store with 200 low-value
entries buries the 10 that actually matter. Be selective — a smaller set of
high-signal learnings is more valuable than a comprehensive archive of
trivia.

**The stale library.** Never reviewing or pruning entries, so the knowledge
store accumulates learnings about tools and patterns that no longer apply.
Outdated learnings are worse than no learnings — they provide false
confidence and incorrect guidance. Tag entries for staleness review.

**The orphaned learning.** Storing an entry with no trigger condition, so it
exists in the file but never surfaces at the point of need. A learning
without a trigger is knowledge trapped in a file. Make sure future agents
encounter it when the situation recurs.

## Critical Rules

1. **Never capture credentials, tokens, or personal data.** Learnings are
   stored in files that may be shared, version-controlled, or read by
   automated tools. Secrets in a knowledge store are a security incident.
   If the learning involves authentication, capture the pattern without
   the actual values.

2. **Specific over general.** "The API has quirks" is not a learning. "The
   API returns 200 with an error body instead of a 4xx status when the
   token has expired" is a learning. The more specific the trigger condition,
   the more useful the entry.

3. **Trigger conditions are mandatory.** Every entry must state when it
   should activate. A learning without a trigger condition is a note buried
   in a file. The trigger is what transforms stored text into timely
   knowledge.

4. **Match the existing format.** If the project already has a knowledge
   store with an established format, match it exactly. Inconsistent formats
   make automated retrieval harder and manual scanning slower. If no format
   exists, establish one explicitly and follow it consistently.

5. **Distill before storing.** Raw capture is a draft, not a final entry.
   Remove narrative, ephemeral details, and emotional context. Keep the
   trigger, the finding, and the resolution. The entry should be useful
   to someone who has never met you and never will.

6. **One learning per entry.** If a single friction event yielded multiple
   independent insights, capture them as separate entries with separate
   trigger conditions. Combined entries are harder to retrieve and harder
   to evaluate for staleness.

7. **Verify cold readability.** After writing the entry, read it as a
   stranger would. If it requires knowledge of the original context to
   make sense, it needs rewriting. The test: would this entry help
   someone encountering the same trigger condition for the first time?
