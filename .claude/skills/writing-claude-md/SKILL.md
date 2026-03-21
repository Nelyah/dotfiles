---
name: writing-claude-md
description: Writes, audits, and improves CLAUDE.md files for Claude Code projects.
  Use when asked to create a CLAUDE.md, improve project instructions, audit CLAUDE.md
  token efficiency, set up a new project for Claude Code, or when the user says
  "write me a CLAUDE.md" or "improve my CLAUDE.md".
---
# Writing CLAUDE.md Files

## Overview

CLAUDE.md is advisory context injected as a user message at session start. It competes for ~150 instruction slots that frontier models reliably follow (Claude Code's system prompt already consumes ~50). Every line you add uniformly degrades adherence to *all* instructions. The goal: **the shortest file that prevents Claude from making mistakes it would otherwise make.**

## When to Use

- User asks to create, write, or set up a CLAUDE.md
- User asks to improve, audit, clean up, or prune an existing CLAUDE.md
- User wants to set up a project for Claude Code
- User asks about CLAUDE.md best practices
- After running `/init`, to prune the output down to what matters

## Process: Writing a New CLAUDE.md

### 1. Audit the Codebase

Read before writing. Understand what Claude can already infer:

- `package.json`, `Makefile`, `Cargo.toml`, `pyproject.toml` — build/test/lint commands
- Directory structure — project layout
- `.editorconfig`, linter configs, `tsconfig.json` — style rules
- Existing `README.md`, `CONTRIBUTING.md` — documented conventions
- `.claude/rules/`, `.claude/skills/` — existing Claude Code configuration

### 2. Apply the Removal Test

For every candidate line, ask: **"If I remove this, will Claude make mistakes?"**

- Yes → keep it
- No → cut it

### 3. Draft Using the WHY / WHAT / HOW Framework

Structure the file in this order:

1. **Project context** (1–2 lines) — What this project is, tech stack
2. **Commands** — Build, test, lint, deploy. Exact strings Claude should run. Skip if obvious from config files.
3. **Directory map** (optional) — Only for monorepos or non-obvious layouts. Annotate what lives where. Skip for standard project structures.
4. **Conventions** — Only those that *differ* from language/framework defaults
5. **Do's and Don'ts** — Hard-won knowledge, gotchas, explicit workflow sequences

### 4. Enforce the Line Budget

- **Root CLAUDE.md: 50–80 lines.** Hard ceiling of 200.
- Move detailed guidance to `.claude/rules/*.md` (conditional on file paths) or `.claude/skills/` (on-demand).
- Use `@docs/file.md` imports with "Read when" annotations for architecture docs.
- See [Progressive Disclosure](reference-progressive-disclosure.md) for the tier system.

### 5. Validate Content

Run through the inclusion/exclusion checklist. See [What Belongs](reference-what-belongs.md) for the full list.

Quick check — **cut immediately** if you find:
- Standard language conventions Claude already knows
- Style rules enforceable by linters (use hooks instead)
- File-by-file descriptions discoverable by reading code
- Generic platitudes ("Write clean code", "Be thorough")
- Inline code snippets that will go stale

## Process: Improving an Existing CLAUDE.md

### 1. Read and Measure

- Read the current CLAUDE.md
- Count lines. If over 80, it likely needs pruning.
- Identify each instruction's category: command, convention, gotcha, platitude, redundant

### 2. Prune

Remove lines that fail the removal test:
- Things Claude can infer from reading code or config files
- Rules that duplicate linter/formatter behavior
- Stale instructions referencing removed code or old patterns
- Rules that haven't prevented a mistake in 3+ weeks

### 3. Add Missing Hard-Won Knowledge

Look for gaps — things that would cause Claude to make mistakes:
- Non-obvious build steps or environment setup
- Conventions the team follows that differ from defaults
- Common gotchas specific to the codebase
- Workflow sequences for multi-step operations

### 4. Set Up the Auto-Increment Loop

Teach the user the correction-driven pattern for ongoing improvement:

After every correction from the user, append the learned rule to CLAUDE.md. Every mistake becomes a permanent improvement. Pair this with monthly pruning to prevent bloat.

See [Self-Improvement Patterns](reference-self-improvement.md) for the full playbook including log-based analysis and hook-based enforcement.

## Handling the File Hierarchy

CLAUDE.md files exist at multiple scopes. Place instructions at the narrowest scope that applies:

| Scope | File | Loaded | Use for |
|---|---|---|---|
| User-global | `~/.claude/CLAUDE.md` | Always | Personal preferences, personality, cross-project conventions |
| Project (shared) | `./CLAUDE.md` or `./.claude/CLAUDE.md` | Always | Team conventions, build commands, project context |
| Project (personal) | `.claude/CLAUDE.local.md` | Always (gitignored) | Personal overrides, local env quirks |
| Subdirectory | `src/api/CLAUDE.md` | Lazily, when files accessed | Module-specific conventions |
| Rules | `.claude/rules/*.md` | Always (supports `paths:` globs) | Conditional instructions by file type |
| Skills | `.claude/skills/*/SKILL.md` | On-demand by relevance | Specialized workflows |

## Key Principles

- **Removal test is the only filter.** "If I remove this, will Claude make mistakes?" No → cut it.
- **50–80 lines for root.** Every line beyond this degrades all instructions uniformly.
- **Progressive disclosure.** Root CLAUDE.md points; rules and skills detail. See [reference](reference-progressive-disclosure.md).
- **Enforce with hooks, not instructions.** Formatting, linting, and test-running belong in Stop hooks, not CLAUDE.md. Instructions are advisory; hooks are mandatory.
- **Never trust /init output as-is.** Prune 60–80% immediately. LLM-generated CLAUDE.md files slightly *decrease* task completion rates vs. hand-crafted ones.
- **Correction-driven improvement.** After each correction: "Update CLAUDE.md so this doesn't happen again." See [self-improvement](reference-self-improvement.md).
- **No stale references.** Prefer `file:line` pointers over inline code. Code in CLAUDE.md rots.

## Example

See [Annotated Example](examples/example-claude-md.md) for a complete ~60-line CLAUDE.md with commentary.

## References

- [What Belongs in CLAUDE.md](reference-what-belongs.md) — Inclusion/exclusion checklist
- [Progressive Disclosure](reference-progressive-disclosure.md) — Tier system, rules, skills, @imports
- [Self-Improvement Patterns](reference-self-improvement.md) — Auto-increment loop, pruning, hooks, log analysis
- [Annotated Example](examples/example-claude-md.md) — Real example with commentary
