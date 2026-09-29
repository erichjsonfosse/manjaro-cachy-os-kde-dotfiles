---
name: upgrading-dependencies
description: Upgrade project dependencies safely — read release notes first, bump in dependency order, verify between steps, and separate mechanical version bumps from the code changes they force. Use when raising a dependency to a new version, applying a security advisory or CVE fix, clearing a backlog of outdated packages, resolving a transitive or lockfile conflict, or producing a dependency upgrade plan for a major version jump.
---

# Upgrading Dependencies

## Objective

Move dependencies to newer versions without breaking the build, weakening the
test gate, or silently changing runtime behavior. An upgrade is not "edit the
version number until it installs." It is a deliberate sequence: understand what
changed upstream, apply one bump, prove the project still works, then adapt the
code the new version forces — keeping the mechanical change and the adaptation
in separate, reviewable commits.

The hard parts of this work are not mechanical. They are ordering decisions,
the pin-vs-float policy, how to isolate a regression an upgrade introduced, and
judging how urgent a given upgrade actually is. This skill is about those
decisions, not about how to run an install command.

## When to Use

- Raising a single dependency to a new major, minor, or patch version
- Applying a security advisory or CVE fix to a vulnerable dependency
- Clearing a backlog of outdated packages flagged by an audit
- Resolving a transitive dependency conflict or a lockfile that won't converge
- Producing an upgrade plan for a major version jump before doing the work
- Reacting to a deprecation warning that signals a forced future upgrade

Do not use this skill for:

- Adding a brand-new dependency the project has never used (that is a design
  choice, not an upgrade — evaluate fit, license, and maintenance first)
- Removing a dependency (that is dead-code / refactor work)
- Bumping a version purely to silence a tool without intending to verify it

## Context

Before changing anything, establish the ground you are standing on:

1. **Find the source of truth.** Locate the dependency manifest and its
   lockfile. The manifest states intent (which versions are acceptable); the
   lockfile records the exact resolved graph that actually ships. Both matter,
   and they can disagree.

2. **Establish a green baseline.** Run the project's test / verify gate on the
   current code before touching any version. If the baseline is already red,
   stop and fix that first — you cannot attribute a post-upgrade failure to the
   upgrade if the suite was already failing.

3. **List what is being upgraded and why.** For each dependency, record the
   current version, the target version, and the reason (security, feature,
   deprecation, dependency-of-a-dependency). The reason drives urgency and
   ordering.

4. **Map the dependency order.** Identify which target packages depend on which
   others, and which are depended upon by the most code. Plugins, adapters, and
   ecosystem packages must usually move *after* the core library they extend.

## Workflow

### 1. Read the Release Notes Before Bumping

Read the changelog, migration guide, and release notes for the span between the
current and target version **before** changing the version number. This is the
single most skipped and most valuable step. You are looking for:

- **Breaking changes** — removed or renamed APIs, changed defaults, dropped
  runtime/platform support, stricter validation.
- **Deprecations** — things that still work but will force the next upgrade.
- **Behavioral changes** that are not "breaking" by the maintainer's
  definition but change output, ordering, error types, or performance.
- **Required migration steps** — codemods, config changes, data migrations.

For a multi-version jump, read the notes for *every* major version in between,
not just the target. Breaking changes accumulate across majors.

Output a short list of expected impact sites in this codebase before you touch
the version. If the notes promise breaking changes and you find zero impact
sites, you have not looked hard enough.

### 2. Upgrade in Dependency Order, One Step at a Time

Apply upgrades in dependency order — foundational libraries before the things
that depend on them. Do not batch unrelated upgrades into one step; each step
should be independently verifiable and independently revertible.

For each step:

1. Bump exactly one dependency (and the transitive changes it pulls in).
2. Let the package manager resolve and update the lockfile.
3. Run the project's test / verify gate.
4. Only proceed to the next dependency once this one is green or its required
   code adaptations are complete.

Running the gate *between* steps is non-negotiable. Batching ten bumps and
running the suite once turns a clean bisect into a guessing game — when it
breaks, you cannot tell which bump did it.

### 3. Separate the Bump From the Adaptation

Keep two kinds of change in **distinct commits**:

- **The mechanical bump** — the manifest version change and the resulting
  lockfile delta, with no source changes. This commit should be reviewable as
  "version X → Y" and nothing else.
- **The code adaptation** — the source edits the new version *forces*
  (renamed API calls, changed signatures, new required config). This is real
  engineering and deserves its own focused review.

Never fold them together. A reviewer reading a single commit that mixes a
lockfile diff with thirty source edits cannot tell which edits were mandatory
and which were opportunistic. When a bump requires no code change, the
adaptation commit simply does not exist — that is the ideal case.

If the adaptation is large, treat the code change as ordinary feature work and
cover it the way the project covers behavior changes (tests first where that
discipline applies).

### 4. Apply the Pin-vs-Float Policy

Decide, per dependency class, whether to pin or float:

- **Pin (exact version) for applications and anything that ships.** The
  lockfile is the contract: the same graph builds the same way on every machine
  and in CI. An application that floats its direct dependencies invites "works
  on my machine" drift.
- **Allow a compatible range for libraries you publish.** A published library
  that hard-pins forces version conflicts onto its consumers. Express the
  widest range you can actually support and test.
- **Always commit the lockfile** for applications. The manifest may express a
  range; the lockfile pins the exact resolution. Both go in the commit.
- **Never float to "latest" implicitly.** Unpinned upgrades that resolve at
  install time are not reproducible and turn an unrelated CI run into a
  surprise upgrade.

State the policy you applied so a reviewer knows whether a range was
intentional or an oversight.

### 5. Handle Transitive and Lockfile Changes

A direct bump usually drags transitive dependencies with it. These are the
quiet source of regressions because nothing in the manifest mentions them.

- **Read the lockfile diff, not just the manifest diff.** A one-line manifest
  change can shift dozens of transitive versions. Skim the lockfile delta for
  anything surprising — a transitive jumping a major version, a duplicated
  package at two versions, a resolution you did not expect.
- **Watch for duplicate or conflicting versions** of the same transitive
  dependency. Two copies at incompatible versions cause subtle runtime bugs and
  bloat. Resolve to a single version where the ecosystem allows it.
- **When the lockfile won't converge**, find the conflicting constraint rather
  than deleting the lockfile and regenerating blindly. Regenerating from
  scratch resolves the conflict by erasing intentional pins and can downgrade
  unrelated packages without telling you.
- **A pinned direct dependency does not pin its transitive graph** unless the
  lockfile is committed. The lockfile is what makes transitive resolution
  reproducible.

### 6. Judge Urgency: Security vs Feature

Not all upgrades carry the same urgency, and urgency changes how you sequence
the work:

- **Security-driven upgrades** are time-sensitive and should be isolated. Take
  the smallest version change that clears the advisory (often a patch on the
  current line), ship it on its own, and avoid coupling it to a risky feature
  upgrade that could delay the fix. The goal is to close the exposure quickly
  and cleanly.
- **Feature-driven upgrades** are discretionary. Schedule them when there is
  time to read the migration guide and absorb breaking changes. There is no
  rush to chase the newest version for its own sake — staying current is a
  maintenance practice, not an emergency.
- **Deprecation-driven upgrades** sit between the two: not urgent today, but a
  scheduled debt that gets more expensive the longer it waits.

When a single dependency needs both a security patch *and* a feature jump,
do the security patch first as its own step so the fix is not held hostage by
the larger migration.

### 7. Bisect a Regression Introduced by an Upgrade

When the gate goes red after an upgrade — or worse, when behavior breaks in a
way the gate did not catch — isolate the cause systematically instead of
guessing:

1. **Confirm the baseline was green** before the upgrade. If it was not, the
   regression may predate your work.
2. **Reduce to the smallest failing change.** If you upgraded several
   dependencies, revert all but one and re-run the gate. Re-introduce them one
   at a time until the failure reappears. This is why step 2 keeps bumps in
   separate, revertible steps — it makes this bisect mechanical.
3. **Bisect the version range of the culprit.** If a single dependency's
   upgrade is responsible, step through intermediate versions between the last
   good and first bad version to find exactly which release introduced the
   change.
4. **Map the failing version back to its release notes.** A behavior change
   that the maintainer documented turns a mysterious failure into a known
   migration step you missed in step 1.
5. **Decide: adapt or hold.** Either adapt the code to the new behavior (a
   distinct adaptation commit) or, if the cost is too high right now, hold at
   the last good version and record why.

   When breaking migrations or non-trivial adaptation costs arise, present the
   decision to your human partner using `ask_question`:
   ```
   question: "Upgrading <package> to <version> introduces breaking changes. How would you like to proceed?"
   options:
     - "(Recommended) Adapt codebase to new API in a separate commit"
     - "Hold dependency at <previous-version> and record deferred reason"
     - "Isolate and defer this upgrade, continuing with remaining dependencies"
   ```

## Output Contract

### Summary

One or two lines stating which dependencies were upgraded, from which versions
to which, and the driving reason (security / feature / deprecation).

### Detail

- **Upgrades applied:** each dependency, old → new version, and the reason.
- **Release-note findings:** the breaking changes and migration steps that
  applied to this codebase, and the impact sites they touched.
- **Commit split:** which commit is the mechanical bump and which is the code
  adaptation, per dependency.
- **Pin-vs-float decisions:** what was pinned, what was given a range, and why.
- **Transitive / lockfile notes:** notable transitive shifts, duplicate
  versions resolved, or conflicts encountered.

### Verification

- The test / verify gate result on the green baseline, before any upgrade.
- The gate result after each upgrade step (between steps, not just at the end).
- If a regression was found and bisected: the culprit version and how it was
  isolated.

### Follow-ups

- Deprecations now visible that will force a future upgrade.
- Upgrades intentionally deferred and the reason (e.g. held at last good
  version pending a larger migration).
- "None" when the upgrade set is fully clean.

## Quality Bar

An upgrade meets the quality bar when:

- Release notes for the full version span were read before the version changed,
  and expected impact sites were identified up front.
- The test / verify gate ran on a green baseline first, and again after each
  upgrade step.
- The mechanical bump and the forced code adaptation live in separate commits.
- The lockfile is committed for applications, and the pin-vs-float policy is
  stated.
- Transitive changes were reviewed via the lockfile diff, not assumed away.
- Security upgrades were isolated from discretionary feature upgrades.
- Any regression was bisected to a specific dependency and version, not patched
  over by reverting the whole batch.

An upgrade fails the quality bar when:

- Versions were bumped before reading what changed upstream.
- Multiple unrelated dependencies were bumped in one step with a single
  verification at the end.
- A version bump and its code adaptations are tangled in one commit.
- The lockfile was deleted and regenerated to "fix" a conflict, silently
  changing unrelated resolutions.
- The test gate was not run between steps, or was weakened to make the new
  version pass.
- A security fix was delayed by coupling it to a large feature migration.

## Anti-Patterns

**The blind bump.** Editing the version number, watching it install, and
declaring victory without reading the changelog or running the gate. Installing
is not working — a new major can install cleanly and break behavior at runtime.

**The big-bang upgrade.** Bumping everything at once "to get it over with,"
then facing a red gate with no way to tell which of twenty changes caused it.
One step at a time is slower per step and dramatically faster overall.

**The tangled commit.** Folding the lockfile delta and the forced source edits
into a single commit, so a reviewer cannot separate the mandatory adaptation
from incidental changes that rode along.

**The lockfile nuke.** Deleting the lockfile and regenerating it to resolve a
conflict. This "works" by discarding every intentional pin and may downgrade or
upgrade unrelated packages without anyone noticing.

**The latest-chaser.** Floating dependencies to their newest version on every
install for the sake of being current, trading reproducibility for novelty and
turning unrelated CI runs into surprise upgrades.

**The deferred security fix.** Holding a known-vulnerable dependency because the
upgrade is "bundled" with a larger migration that is not ready. Security fixes
ship on their own, on their own schedule.

## Critical Rules

1. **Read before you bump.** Read the release notes and migration guide for the
   full version span before changing the version. Skipping this turns every
   later step into guesswork.

2. **Verify on a green baseline first.** Run the project's test / verify gate
   before any upgrade. You cannot attribute a failure to an upgrade if the
   suite was already red.

3. **One dependency per step, gate between steps.** Each step must be
   independently verifiable and revertible. Running the gate between steps is
   what makes a later regression bisectable.

4. **Separate the bump from the adaptation.** The mechanical version change and
   the code it forces belong in distinct commits, always.

5. **Commit the lockfile and state the pin policy.** Applications pin and ship
   the lockfile; published libraries express the widest supportable range.
   Never float implicitly to "latest."

6. **Review the transitive graph, not just the manifest.** A one-line manifest
   change can move dozens of transitive versions. The lockfile diff is where
   the real change lives.

7. **Isolate security fixes.** A security-driven upgrade is time-sensitive and
   ships on its own — never held hostage by a discretionary feature migration.

8. **Bisect, don't guess.** When something breaks, reduce to the smallest
   failing change and step through versions to the exact culprit release, then
   map it back to the release notes.
