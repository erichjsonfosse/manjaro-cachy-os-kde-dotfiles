# Git Conventions & Staging Rules

## 1. Strict Explicit Staging
- **FORBIDDEN:** Never use blanket or directory-wide staging commands such as `git add .`, `git add -A`, `git add *`, or `git add <dir>/`.
- **MANDATORY:** Always specify exact file paths explicitly: `git add path/to/file1.sh path/to/file2.sh`.
- **PRE-STAGING CHECK:** Always check `git status -s <files>` or `git diff <files>` before staging to confirm exactly what changes are about to be staged.
- **POST-STAGING AUDIT:** Run `git diff --cached --stat` to verify only the intended files are in the index before committing.

## 2. Documentation & Specification Isolation
- **DEDICATED COMMITS:** Design specs (`documentation/specs/*`) and implementation plans (`documentation/plans/*`) must NEVER be bundled into code, bugfix, or feature commits.
- **SEPARATE SCOPE:** Always commit documentation and plans in dedicated commits prefixed with `docs(...)`.
- **NO UNINTENDED ARTIFACTS:** Never stage untracked files or scratch notes from previous tasks or sessions.

## 3. Conventional Commits Standard
- **FORMAT:** `<type>(<scope>): <short imperative summary>`
- **TYPES:**
  - `feat`: New feature or user-facing capability
  - `fix`: Bug fix or error resolution
  - `docs`: Documentation, design specs, implementation plans
  - `test`: Adding, updating, or fixing tests
  - `refactor`: Code refactoring without behavior or functional change
  - `chore`: Tooling, version bumps, dependencies, housekeeping
- **STYLE:** Use imperative mood ("add", "fix", "update", not "added" or "fixes"), all lowercase, and no trailing period.

## 4. Small & Cherry-Pickable Commits
- **ATOMIC CHANGES:** Keep commits small, focused, and scoped to a single logical change or responsibility.
- **CHERRY-PICKABLE:** Each commit must be self-contained and stable so it can be cherry-picked onto another branch without pulling in unrelated or half-finished code.
- **NO MONOLITHIC COMMITS:** Never group multiple independent features, fixes, or refactorings into one single commit.

## 5. Task Completion Reporting
- **PRESENT COMMITS & FILES:** On task completion (and at review checkpoints), agents MUST explicitly present:
  - All commits created during the task/step (short commit hash and full commit message).
  - The exact list of files modified per commit (using clickable markdown file links).

## 6. Safety Invariants
- **NO BYPASS:** Never use `--no-verify` to bypass pre-commit hooks unless explicitly requested by the user.
- **NO FORCE PUSH:** Never force-push (`git push -f` or `--force`) to `main`, `master`, or tracking branches.
- **NO DESTRUCTIVE RESETS:** Never execute `git reset --hard` or `git clean -fd` without explicit user permission.
