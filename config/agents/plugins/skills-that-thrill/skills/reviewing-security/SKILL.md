---
name: reviewing-security
description: Audit code changes for security vulnerabilities, dependency risks, secrets exposure, and auth/access control issues. Use when changes touch authentication, authorization, or sensitive data handling, when API endpoints or input validation are modified, when dependencies are added or updated, when configuration affects CORS, CSP, or permissions, before any production release, or whenever the user asks for a security review or vulnerability check.
---

# Reviewing Security

## Objective

Identify security vulnerabilities, misconfigurations, and risks in code
changes before they reach production. A security review is not a general code
review — it specifically targets attack vectors, data exposure, authentication
flaws, dependency risks, and configuration weaknesses.

As agents take on more implementation work, security review becomes the
critical human-judgment layer. Agents can write functional code that passes
tests while containing injection vulnerabilities, overly permissive access
controls, or exposed secrets. Security review catches what functional tests
miss.

## Setup check

Before proceeding, verify `AGENTS.md` (or `GEMINI.md`) exists at the repo root. If missing,
stop and instruct the user to run the `skills-that-thrill:authoring-agent-context` skill first —
without it the review lacks the project's documented security posture,
trust boundaries, and known constraints to audit against.

## When to Use

- Any code change that handles authentication or authorization
- Changes to API endpoints, input handling, or data validation
- Dependency additions or updates
- Configuration changes (environment variables, CORS, CSP, permissions)
- Code that handles sensitive data (PII, credentials, tokens, payment info)
- Changes to deployment, infrastructure, or CI configuration
- Before any release to production
- The user asks for a "security review", "vulnerability check", or "security
  audit"

Do not do a dedicated security review when:
- The change is purely cosmetic (CSS, copy text, whitespace)
- The change is internal documentation with no code impact
- General code review already covered security for a trivial change

## Context

Before starting the review, establish what you are protecting:

1. **Identify the threat surface.** What does this code expose?
   - Public APIs, endpoints, or interfaces
   - Data flows involving sensitive information
   - Authentication or authorization boundaries
   - Third-party integrations and their trust levels

2. **Understand the trust boundaries.** Where does trusted input end and
   untrusted input begin? Every point where external data enters the system
   is a potential attack vector.

3. **Check the project's security posture.** Look for:
   - Existing security middleware, validation libraries, or frameworks
   - Security-related configuration (CSP headers, CORS policies, auth config)
   - Previous security patterns established in the codebase
   - Security testing infrastructure (SAST tools, dependency scanners)

4. **Know the compliance context.** Is the project subject to:
   - GDPR, HIPAA, PCI-DSS, or other regulatory frameworks
   - Internal security policies or standards
   - Data residency or encryption requirements

## Workflow

### 1. Dependency Audit

Review all dependencies for known vulnerabilities and supply chain risks:

- Check for known CVEs in direct and transitive dependencies
- Identify dependencies that are unmaintained, archived, or deprecated
- Flag dependencies with overly broad permissions or native code execution
- Verify dependency lock files are committed and up to date
- Check for dependency confusion risks (private package names that could
  be squatted on public registries)
- Review any new dependency additions: Is this dependency necessary? Is
  there a lighter alternative? What is its maintenance status?

### 2. Secrets and Credentials Scan

Check for accidental exposure of sensitive data:

- Scan for hardcoded API keys, tokens, passwords, or connection strings
- Check for secrets in configuration files, environment examples, or test
  fixtures
- Verify .gitignore covers all files that might contain secrets
- Check that environment variable names do not leak secret values in logs
  or error messages
- Verify secrets are loaded from environment or secret management, never
  from source code
- Check for sensitive data in comments, TODOs, or documentation

### 3. Input Validation and Injection

Review all points where external data enters the system:

- **SQL/NoSQL injection:** Are queries parameterized? Are ORMs used correctly?
  Is raw query construction avoided?
- **XSS (Cross-Site Scripting):** Is user input sanitized before rendering?
  Are template engines configured for auto-escaping? Is innerHTML or
  equivalent avoided?
- **Command injection:** Is user input ever passed to shell commands, exec,
  or system calls? Are arguments properly escaped?
- **Path traversal:** Is user input used in file paths? Is directory traversal
  (../) prevented?
- **Deserialization:** Is untrusted data deserialized? Are safe parsers used?
- **SSRF (Server-Side Request Forgery):** Can user input control URLs that
  the server fetches? Are allowlists in place?

### 4. Authentication and Authorization

Review access control implementation:

- Are authentication checks present on all protected endpoints?
- Is authorization enforced at the correct layer (not just UI-level hiding)?
- Are tokens validated correctly (signature, expiration, audience, issuer)?
- Is session management secure (httpOnly, secure, sameSite cookie flags)?
- Are password handling practices correct (hashing, salting, no plaintext)?
- Is rate limiting applied to authentication endpoints?
- Are privilege escalation paths possible (modifying user IDs in requests)?
- Is the principle of least privilege applied to service accounts and API
  keys?

### 5. Data Exposure

Check for unintended data leakage:

- Are API responses filtered to exclude sensitive fields?
- Do error messages expose internal details (stack traces, SQL queries,
  file paths)?
- Are logs sanitized to exclude PII and credentials?
- Is sensitive data encrypted at rest and in transit?
- Are debug endpoints or verbose error modes disabled in production config?
- Is data retention handled correctly (no indefinite storage of sensitive
  data)?

### 6. Configuration and Infrastructure

Review security-relevant configuration:

- Are HTTPS/TLS settings correct and enforced?
- Are CORS policies appropriately restrictive (not wildcard)?
- Are Content Security Policy (CSP) headers configured?
- Are security headers present (X-Frame-Options, X-Content-Type-Options,
  Strict-Transport-Security)?
- Are file upload restrictions in place (size, type, storage location)?
- Are default credentials or configurations changed?
- Are CI secrets properly scoped and not exposed in logs?

### 7. Document Findings

For each finding, record:
- **Severity:** Critical (exploitable now), High (likely exploitable),
  Medium (exploitable with effort), Low (defense-in-depth improvement)
- **Location:** File, line, function
- **Description:** What the vulnerability is
- **Attack scenario:** How it could be exploited
- **Remediation:** What to change to fix it
- **Verification:** How to confirm the fix works

## Output Contract

Every security review produces these sections under `## Output Contract`:

### Summary

- **Scope:** [what was reviewed — files, features, or full changeset]
- **Risk level:** [Critical / High / Medium / Low / Clean]
- **Recommendation:** [Ship / Ship with fixes / Block until resolved]
- **Counts:** Critical [n], High [n], Medium [n], Low [n]

### Detail

**Findings** — one block per finding, ordered by severity:

#### [SEVERITY] [Finding title]
- **Location:** `file:line`
- **Issue:** [what is wrong]
- **Attack scenario:** [how this could be exploited]
- **Remediation:** [what to change]
- **Verification:** [how to confirm the fix]

**Dependency audit:**

- New dependencies: [count] ([list any flagged])
- Known CVEs: [count or "none"]
- Unmaintained dependencies: [list or "none"]

**Secrets scan:**

- Hardcoded secrets found: [count or "none"]
- Gitignore coverage: [adequate / gaps found]

### Verification

- Static checks run (and their results) for each rule category in scope
- Manual review walked through every authentication, authorization, and
  input-handling boundary in the changeset
- Independent confirmation of any "Clean" verdict — explicitly note what
  was checked, not just what was not found

### Follow-ups

- Lower-severity items deferred to backlog issues
- Hardening recommendations beyond the immediate scope
- "None" if every flagged item is addressed in this pass

## Quality Bar

A security review meets the quality bar when:

- All six review areas are covered (dependencies, secrets, injection,
  auth, data exposure, configuration)
- Findings include specific file locations, not vague descriptions
- Each finding has an attack scenario — not just "this is bad"
- Remediation is actionable — specific code changes, not "fix this"
- Severity ratings are calibrated to actual exploitability
- The review distinguishes between findings that block release and those
  that are defense-in-depth improvements
- False positives are acknowledged and explained, not silently ignored

A security review fails the quality bar when:

- Only one or two areas are checked (e.g., only dependencies)
- Findings lack attack scenarios — severity is guessed, not reasoned
- Remediation is vague ("add input validation" without specifying where
  and how)
- The review produces zero findings on a non-trivial change (every change
  to auth, input handling, or data flow has at least observations)
- Known vulnerability databases were not consulted for dependencies

## Anti-Patterns

**The checkbox audit.** Running through a list of categories and marking each
"OK" without actually inspecting the code. A security review requires reading
code paths, tracing data flows, and thinking adversarially.

**The tool-only review.** Running a SAST scanner and reporting its output
without manual review. Automated tools miss logic flaws, business logic
vulnerabilities, and context-dependent issues. Tools supplement manual review;
they do not replace it.

**The severity inflation.** Marking everything as "Critical" to appear
thorough. Calibrate severity to actual exploitability and impact. A
theoretical timing attack on a non-sensitive endpoint is not Critical.

**The fix-it-yourself review.** Making security fixes during the review
instead of documenting them for the implementer. Security fixes need their
own testing and review — they should not be side effects of the audit.

**Ignoring the happy path.** Only checking error handling and edge cases.
Some of the most dangerous vulnerabilities are in the normal execution
path — overly permissive default access, broad data exposure in standard
API responses, missing rate limits on primary endpoints.

## Critical Rules

1. **Review is read-only.** Do not make code changes during a security
   review. Document findings with specific remediation. Fixes go through
   their own implementation and testing cycle.

2. **Think like an attacker.** For every input point, ask: "What happens if
   I send something unexpected?" For every access control check, ask: "What
   happens if I skip this?" For every data flow, ask: "Where could this leak?"

3. **Dependencies are attack surface.** Every dependency is code you did not
   write and may not audit. Treat new dependencies with suspicion. Check
   maintenance status, known vulnerabilities, and permission scope.

4. **Secrets in code are always Critical.** There is no acceptable reason for
   hardcoded credentials in source code. Not in tests, not in examples, not
   in comments. Use environment variables or secret management.

5. **Defense in depth.** Do not rely on a single security control. Input
   validation at the boundary, parameterized queries in the data layer, output
   encoding in the view, and access control at the endpoint are all needed.
   Each layer catches what the others miss.

6. **Document what you checked.** A security review that says "looks fine"
   is not a review. List the areas checked, the approach taken, and the
   conclusion for each area — even when no issues are found.

7. **Severity reflects exploitability.** A vulnerability that requires
   physical access to the server is not the same severity as one exploitable
   via a public API. Rate severity based on: access required, complexity of
   exploitation, and impact if exploited.
