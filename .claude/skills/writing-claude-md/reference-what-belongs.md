# What Belongs in CLAUDE.md

## Include — Things Claude Cannot Infer

### Build / Test / Lint Commands
Commands that aren't obvious from `package.json`, `Makefile`, or standard tooling. If `npm test` works, don't document it. If the real command is `./scripts/test.sh --integration --env=staging`, document it.

### Conventions That Differ from Defaults
Only encode conventions where your team deviates from standard language/framework patterns:
- "Use Zustand, never Redux"
- "All database access goes through the repository pattern"
- "Use `Float32` for all numeric computations"
- "Prefer classes over dictionaries" (Python)

If a convention matches what Claude would do by default (e.g., "use PEP 8" for Python), skip it.

### Architectural Decisions for Multi-Service Systems
Cross-boundary relationships in monorepos, microservices, and shared-package setups. Claude can read one file at a time — it can't always infer how services connect.

Format as a compact map, not a description:
```markdown
## Architecture
TypeScript monorepo: API (Express), Web (React), Shared (common types/utils)
```

### Workflow Sequences
Multi-step operations where the order matters and Claude wouldn't guess it:
```markdown
## Adding an API Endpoint
1. Define types in `shared/types/`
2. Implement handler in `api/handlers/`
3. Add route in `api/routes.ts`
4. Add request to `api/tests/*.http`
5. Write integration test
```

### Verification Commands
How Claude should check its own work:
```markdown
## Verify Changes
- `make test` — unit tests
- `make lint` — linting
- `make typecheck` — type checking
```

### Gotchas and Hard-Won Knowledge
Things that caused real bugs or wasted real time:
- "The app uses `shiny::ExtendedTask` for chat streaming — do not use standard async"
- "Redis keys are prefixed by environment; never hard-code the prefix"
- "Integration tests require `docker compose up` first"

### Compaction Instructions
What to preserve when context is compressed:
```markdown
## On Compaction
Preserve: all modified file paths, pending test commands, current task context
```

## Exclude — Things That Waste Tokens

### Standard Language Conventions
Claude already knows PEP 8, Go formatting, JavaScript best practices, TypeScript strict mode patterns. Don't restate them.

### Linter-Enforceable Rules
If ESLint, Prettier, Black, Ruff, or any formatter handles it, use a Stop hook to run the tool instead of documenting the rule. Hooks are enforced; instructions are advisory.

### API Documentation
Link to docs; don't inline them. Use conditional loading:
```markdown
@docs/api-reference.md — Read when working on API endpoints
```

### File-by-File Descriptions
Claude can read your code and infer what files do. A directory map is useful; describing every file is not.

### Inline Code Snippets
Code in CLAUDE.md goes stale. Use `file:line` references instead:
```markdown
See the auth middleware pattern at `src/middleware/auth.ts:15`
```

### Generic Platitudes
These add zero information:
- "Write clean, maintainable code"
- "Think step by step"
- "Be a senior engineer"
- "Follow best practices"

### Frequently Changing Information
If it changes often enough to create stale-instruction risk, it doesn't belong in a file that loads every session. Put it in a reference file or a rule with a `paths:` glob.
