# Example Agent Context File

This is a real-world example of a well-structured AGENTS.md file. Note how
every line is a specific, actionable instruction — no architecture descriptions,
no tech stack summaries, no information the agent can discover from the code.

---

```markdown
# AGENTS.md

## Build & Test
- Build: `pnpm build`
- Test (unit): `pnpm test`
- Test (integration): `pnpm test:integration` — requires Docker running
- Test (single file): `pnpm test -- path/to/file.test.ts`
- Lint: `pnpm lint`
- Type check: `pnpm typecheck`
- Format: `pnpm format`

## Environment Setup
- Use `pnpm`, not npm or yarn — workspaces are configured for pnpm only
- Copy `.env.example` to `.env.local` for local development
- Start local services: `docker compose up -d` (Postgres + Redis)
- Run migrations: `pnpm db:migrate`

## Conventions
- File naming: kebab-case for all files (`user-profile.ts`, not `UserProfile.ts`)
- Test files: colocated next to source (`user-service.ts` → `user-service.test.ts`)
- Commit messages: Conventional Commits format (`feat:`, `fix:`, `chore:`)
- API routes: use the existing middleware chain in `src/middleware/` — do not create custom middleware per route

## Do Not
- Modify files in `src/generated/` — auto-generated from schemas via `pnpm codegen`
- Use `any` type — the strict TypeScript config will reject it in CI
- Import from `src/internal/` in API route handlers — use the public API in `src/api/`
- Add dependencies without checking for existing alternatives in the monorepo

## Common Pitfalls
- Integration tests fail if Docker is not running — run `docker compose up -d` first
- The `auth` package has a circular dependency risk — import from `@repo/auth` not `../auth/src`
- Hot reload does not pick up changes in `.env.local` — restart the dev server
```
