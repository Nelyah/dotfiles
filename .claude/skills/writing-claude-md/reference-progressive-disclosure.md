# Progressive Disclosure for CLAUDE.md

## The Token Budget

Frontier models reliably follow ~150 instructions. Claude Code's system prompt consumes ~50. That leaves ~100 instruction slots for your CLAUDE.md, rules, and skills combined.

A 2,800-line CLAUDE.md doesn't give you 2,800 rules — it gives you ~100 partially-followed rules with significant instruction drift. One practitioner reduced from 2,800 lines (2,100 tokens) to 180 lines (800 tokens), increasing per-session relevance from 30% to 85%.

## Three-Tier System

### Tier 1: Root CLAUDE.md (50–80 lines, always loaded)

Contains only:
- 1–2 lines of project context
- Essential build/test/lint commands
- Compact directory map (monorepos only)
- Non-default conventions (the short list)
- Critical do's and don'ts
- Pointers to deeper docs

This loads every session. Every line here costs tokens on every interaction.

### Tier 2: Rules and Conditional Docs (loaded by trigger)

**Project rules** in `.claude/rules/*.md` auto-load alongside CLAUDE.md. Use `paths:` frontmatter for conditional loading:

```yaml
# .claude/rules/api-conventions.md
---
paths:
  - "src/api/**"
  - "tests/api/**"
---
Use repository pattern for all database access.
Return standardized error shapes: { error: string, code: number, details?: object }
```

This rule loads only when Claude works on files matching those globs.

**Referenced docs** with `@imports` expand at launch:

```markdown
## Detailed Docs (read when relevant)
@docs/api-architecture.md — Read when adding/modifying API endpoints
@docs/database-schema.md — Read when working with data models
```

Use sparingly — `@imports` expand at session start, so large files cost tokens on every session.

### Tier 3: Skills (loaded on-demand by relevance)

Move specialized workflows to `.claude/skills/`. Skills load only when Claude determines they're relevant to the current task, making them the most token-efficient way to provide detailed instructions.

Good candidates for skills:
- Complex multi-step workflows (deployment, release, migration)
- Domain-specific processes (review checklists, testing strategies)
- Tool-specific knowledge (CLI tools, API patterns)

Measured impact: ~15,000 tokens recovered per session by moving specialized instructions from CLAUDE.md to skills.

## The File Hierarchy

CLAUDE.md files at multiple scopes, loaded in this order:

1. **User-global** (`~/.claude/CLAUDE.md`) — Personal preferences across all projects
2. **Walk-up** — Every CLAUDE.md found walking from CWD up to filesystem root
3. **Project** (`./CLAUDE.md` or `./.claude/CLAUDE.md`) — Shared team conventions
4. **Local** (`.claude/CLAUDE.local.md`) — Personal overrides, gitignored
5. **Subdirectory** (e.g., `src/api/CLAUDE.md`) — Loaded lazily when files in that directory are accessed

Place instructions at the **narrowest scope** that applies. User preferences go in user-global. Project commands go in project-level. Module-specific patterns go in subdirectory files.

## Practical Token-Saving Strategies

- **Disable unused MCP servers.** Each adds persistent tool definitions even when idle.
- **Prefer CLI tools over MCP servers when possible.** `gh`, `aws`, `glab` don't add tool schemas to context.
- **Delegate verbose operations to subagents.** They run in separate context windows.
- **Use `CLAUDE_AUTOCOMPACT_PCT_OVERRIDE=65`** to control compaction timing.
