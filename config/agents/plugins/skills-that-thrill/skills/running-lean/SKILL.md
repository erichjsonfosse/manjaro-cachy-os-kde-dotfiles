---
name: running-lean
description: "Token-frugality mode: pull less into context (targeted reads, bounded command output) and answer in a terse register, on every turn, until switched off. Use when a session should minimise token cost — long or exploratory work, large repos, repeated runs, or any time someone says 'be brief', 'less tokens', or 'go lean'."
---

# Running Lean

A cross-cutting **mode**, not a task. Once invoked, stay lean on every response until the user says "stop lean" or "normal mode". Two fronts, held at once: no wasted tokens *in*, no wasted tokens *out*.

## When to Use

- A session is long, exploratory, or repeated, and context or output cost adds up.
- Someone asks to "be brief", "use fewer tokens", or "go lean".
- Work spans a large repo where reading whole files would flood context.

Do not use it where the user needs a full, expansive explanation — switch back with "stop lean".

## Workflow

Hold both fronts on every turn until switched off.

**Context-in — pull less in.**

- Known file? Read it directly — no scouting step first. Searching across many files? Locate with a search, then read only the matching lines. Never open a whole file just to see what is there; never re-read a file already in context.
- Bound a command's output at the source: a short-form status over a verbose one, a diff stat over a full diff, a count over a full listing, the first lines over the whole stream. A command whose full output you do not need gets a flag or a filter that shrinks it.
- Ask for the summary, not the firehose — counts, names, stats first; widen only when the summary points you there.

**Output-out — terse register.**

Answer like a senior paid by the word who resents it. Substance whole; scaffolding gone.

- Drop articles, filler (just/really/basically), pleasantries (sure/happy to/great question), and hedging (I think/it seems/probably) where they carry no meaning.
- Keep verbatim: code, identifiers, API names, file paths, error strings, numbers.
- Fragments fine. One line when one line is the answer. No preamble, no recap unless asked.

**Widening.** If the user asks for the full output or to explain a point in detail, widen there only — then snap back to lean.

## Critical Rules

- Substance is sacred: never compress code, identifiers, paths, error strings, or numbers — only prose padding goes.
- Frugality never costs correctness: if going lean would drop information the task needs, keep the information.
- Lean is a mode: it persists every turn until the user switches it off.

## Anti-Patterns

- Compressing code, identifiers, paths, or error strings to save tokens. Only prose padding goes — never the substance.
- Adding a scouting step before reading a file whose path you already know.
- Treating lean as one-shot. It persists every turn until explicitly switched off.
- Going terse where the user asked for depth. Widen on request, then return to lean.
