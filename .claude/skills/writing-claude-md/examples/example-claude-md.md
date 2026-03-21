# Annotated Example: CLAUDE.md

Below is a ~60-line CLAUDE.md for a fictional TypeScript monorepo. Comments in `<!-- -->` explain why each section exists — they would not appear in the real file.

---

```markdown
<!-- 1-2 lines of project context. Claude needs this to understand the domain. -->
## Project
SaaS billing platform. TypeScript monorepo: API (Express), Dashboard (React), Shared (types + utils).

<!-- Only non-obvious commands. `npm install` and `npm test` are obvious. These aren't. -->
## Commands
- Build all: `turbo build`
- Test single package: `turbo test --filter=@billing/api`
- Lint: `turbo lint`
- DB migrations: `cd packages/api && npx prisma migrate dev`
- Generate types from schema: `cd packages/shared && npm run codegen`

<!-- Monorepo layout — Claude can't infer cross-package relationships from a single file. -->
## Structure
- `packages/api/` — Express API, Prisma ORM, Bull queues
- `packages/dashboard/` — React SPA, TanStack Query, Zustand
- `packages/shared/` — Shared TypeScript types and validation schemas (Zod)
- `packages/jobs/` — Background job processors (billing cycles, invoices)

<!-- Conventions that DIFFER from defaults. Claude would use Redux otherwise. -->
## Conventions
- State management: Zustand only. No Redux.
- API responses: always `{ data: T } | { error: string, code: number }`
- Database access: repository pattern only (`packages/api/src/repos/`). No direct Prisma calls in handlers.
- Shared types: define in `packages/shared/src/types/`, import everywhere else. Never duplicate type definitions.
- Enums: use TypeScript `as const` objects, not `enum` keyword.

<!-- Gotchas that caused real bugs. Each traces to a specific incident. -->
## Gotchas
- Bull queues serialize/deserialize job data as JSON. Dates become strings. Always re-parse dates in job processors.
- Prisma transactions have a 5-second default timeout. Long-running billing cycles need `timeout: 30000`.
- Dashboard uses path aliases (`@/components`). Import from `@billing/shared` for shared types, not relative paths.

<!-- Multi-step workflow Claude would get wrong without explicit ordering. -->
## Adding an API Endpoint
1. Define request/response types in `packages/shared/src/types/`
2. Run `npm run codegen` in shared
3. Create handler in `packages/api/src/handlers/`
4. Create repo methods if new DB access needed
5. Add route in `packages/api/src/routes/`
6. Add test in `packages/api/tests/`
7. Run `turbo test --filter=@billing/api`

<!-- How Claude should verify its own work. -->
## Verify
Run before finishing: `turbo build && turbo test && turbo lint`

<!-- Compaction survival instructions. -->
## On Compaction
Preserve: all modified file paths, pending test commands, current task step.
```

---

## What Makes This Example Effective

- **60 lines.** Well under the 80-line target.
- **Every line fails the removal test.** Remove any line and Claude will make a specific mistake (use Redux, call Prisma directly, forget to re-parse dates in jobs).
- **No platitudes.** No "write clean code" or "follow TypeScript best practices."
- **No linter rules.** Those are handled by ESLint and Prettier via hooks.
- **No file descriptions.** Claude can read the code to understand what individual files do.
- **Commands are non-obvious.** `turbo build`, `turbo test --filter=`, Prisma migration — these aren't guessable from config alone.
- **Gotchas trace to real bugs.** The Bull queue date serialization, Prisma timeout, and path alias issues all caused actual incidents.

## Anti-Example: What to Avoid

```markdown
<!-- DON'T: This is 200+ lines of things Claude already knows or can infer. -->

## Project Overview
This is a TypeScript monorepo that uses Express for the API and React for the dashboard.
We follow modern TypeScript best practices and write clean, maintainable code.

## Code Style
- Use consistent indentation (2 spaces)
- Use semicolons at the end of statements
- Use single quotes for strings
- Add JSDoc comments to all public functions
- Keep functions under 50 lines

## TypeScript Guidelines
- Enable strict mode
- Use interfaces over type aliases where possible
- Avoid `any` — use `unknown` instead
- Use optional chaining (?.) and nullish coalescing (??)

## File: packages/api/src/index.ts
This is the main entry point for the API server. It sets up Express...

## File: packages/api/src/middleware/auth.ts
This middleware handles JWT authentication by checking the Authorization header...
```

Problems: restates TypeScript defaults, duplicates linter config, describes files Claude can read, includes platitudes, would be 200+ lines to cover the full codebase.
