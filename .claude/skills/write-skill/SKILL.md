---
name: writing-skill-files
description: Creates and edits SKILL.md files for Claude Code agent skills. Use when
  asked to write a skill, create a skill, make a new skill, or improve an existing
  skill file. Produces well-structured skill packages with frontmatter, instructions,
  examples, and reference files.
---
# Writing Skill Files

## Overview

Create skill packages that teach Claude how to perform specific tasks. A skill is a directory under `.claude/skills/` containing a `SKILL.md` file and optional supporting files.

Context is scarce. Every token in a skill competes with the work context. Write the minimum instructions needed to change Claude's default behavior.

## Process

### 1. Understand the Skill's Purpose

Before writing, answer these questions (ask the user if unclear):

- **What does the skill do?** One-sentence summary of the capability.
- **When should it activate?** Specific trigger conditions (user phrases, file types, task patterns).
- **What would Claude get wrong without it?** Only encode what Claude wouldn't do by default.
- **What's the scope?** Read-only analysis vs. code generation vs. workflow orchestration.

### 2. Choose the Name

- Lowercase with hyphens: `processing-pdfs`, `reviewing-code`
- Gerund form preferred: `writing-tests` not `test-writer`
- Max 64 characters
- Must not contain "anthropic" or "claude"

### 3. Write the Frontmatter

The `description` field is the single most critical element. Claude uses it to select from hundreds of skills. A vague description means the skill never activates.

```yaml
---
name: skill-name-here
description: <What it does> + <When to use it>. Third person. Max 1024 chars.
---
```

<good_description>
```yaml
description: Reviews merge requests with inline diff comments and severity labels.
  Use when asked to review a MR, PR, code review, or provide feedback on merge requests.
```
Specific actions + clear trigger conditions.
</good_description>

<bad_description>
```yaml
description: Helps with code quality.
```
Too vague. Claude can't match this to any specific request.
</bad_description>

**Description checklist:**
- States what the skill does (capabilities)
- States when to use it (trigger conditions)
- Written in third person
- Includes keywords users would say ("review", "MR", "PR", "merge request")
- Under 1024 characters

### 4. Write the Body

The body contains the actual instructions Claude follows when the skill activates. Target under 500 lines. If longer, split detail into reference files.

**Structure the body with these sections (include only what's needed):**

1. **Overview** - One paragraph. What this skill does and its core principle.
2. **When to Use** - Trigger conditions and scope boundaries.
3. **Workflow/Process** - Step-by-step instructions in imperative voice.
4. **Examples** - Concrete input/output pairs showing correct behavior.
5. **Key Principles** - Short list of rules that override Claude's defaults.
6. **References** - Links to supporting files for detailed guidance.

**Writing rules:**

- **Imperative voice.** "Run `npm test` after changes" not "It would be good to run tests."
- **Positive framing.** "Use environment variables for configuration" not "Don't hard-code config values." Reserve negatives for hard safety boundaries only.
- **Concrete over abstract.** Show exact commands, exact output formats, before/after code pairs.
- **Skip what Claude already knows.** Don't explain how Git works, what TypeScript is, or how to write functions. Only encode project-specific or workflow-specific knowledge.
- **Delegate to tools.** Formatting rules belong in linters. Type rules belong in type checkers. Style rules belong in `.editorconfig`. Only put judgment calls in skills.

### 5. Add Supporting Files (If Needed)

```
my-skill/
├── SKILL.md              # Required. Under 500 lines.
├── reference-topic.md    # Detailed docs, loaded on demand
├── scripts/
│   └── helper.sh         # Executable code
└── assets/
    └── template.json     # Templates, resources
```

- Keep references **one level deep** from SKILL.md.
- Reference files load only when Claude accesses them, so they don't cost context until needed.
- Link from SKILL.md with relative paths: `See [topic details](reference-topic.md)`.
- Put large examples, checklists, or lookup tables in reference files rather than the SKILL.md body.

### 6. Validate

After writing, verify:

- [ ] `name` is lowercase-hyphenated, under 64 chars, gerund form
- [ ] `description` states both capabilities AND trigger conditions
- [ ] Body is under 500 lines
- [ ] Every instruction changes Claude's default behavior (remove anything Claude would do anyway)
- [ ] Instructions use imperative voice
- [ ] Negative instructions are rewritten as positive (except safety boundaries)
- [ ] Concrete examples are included for any non-obvious output format
- [ ] Reference files are one level deep from SKILL.md
- [ ] No conflicts with other skills in `.claude/skills/`

## Patterns to Follow

### Progressive Disclosure

Thin SKILL.md body pointing to detailed reference files:

```markdown
## Error Handling
For severity classification, see [severity-levels.md](severity-levels.md).
```

Claude reads the reference only when working on error handling, keeping context free for other tasks.

### Conditional Workflows

Provide branching instructions when the skill covers multiple scenarios:

```markdown
**Determine the task type:**
- Creating new code? Follow the Creation workflow below.
- Fixing a bug? Follow the Debugging workflow below.
- Refactoring? Follow the Refactoring workflow below.
```

### Feedback Loops

Mandate validation after every change:

```markdown
1. Make the edit
2. Run `make test` to verify
3. If tests fail, fix before proceeding
4. Only move to next step when tests pass
```

### Good/Bad Examples

Show correct and incorrect output side by side:

```markdown
<good_example>
feat(auth): implement JWT refresh token rotation
</good_example>

<bad_example>
updated some auth stuff
</bad_example>
```

## Anti-Patterns to Avoid

| Anti-Pattern | Fix |
|---|---|
| Description says "Helps with X" | State specific actions and trigger keywords |
| Body explains things Claude already knows | Delete. Only encode what changes default behavior |
| All instructions in SKILL.md, 800+ lines | Split into SKILL.md (process) + reference files (details) |
| Negative instructions ("Don't use X") | Rewrite as positive ("Use Y instead of X") |
| Abstract rules without examples | Add concrete input/output pairs |
| Deeply nested reference chains | Keep all references one level from SKILL.md |
| Style/format rules that a linter handles | Remove from skill, configure the linter instead |
| Vague "when to use" guidance | List specific user phrases and task patterns |

## Example: Minimal Skill

```markdown
---
name: generating-commit-messages
description: Generates conventional commit messages from staged changes. Use when
  writing commit messages, committing code, or reviewing staged changes.
---
# Generating Commit Messages

Run `git diff --staged` to see changes, then write a commit message following this format:

<type>(<scope>): <summary under 50 chars>

<body: what changed and why>

**Types:** feat, fix, refactor, test, docs, chore, perf
**Scope:** affected module or component name

## Example

Input: Added retry logic to API client with exponential backoff

Output:
feat(api): add retry with exponential backoff

Add automatic retry for failed API requests with exponential
backoff (100ms, 200ms, 400ms) and max 3 attempts. Handles
transient network errors and 5xx responses.
```

## Key Principles

- **Description is the skill's API.** If the description is wrong, the skill never fires.
- **Context is finite.** Every line must justify its token cost.
- **Show, don't tell.** One concrete example teaches more than a paragraph of rules.
- **Progressive disclosure.** Metadata at startup, body on activation, references on demand.
- **Skip the obvious.** Only encode what Claude wouldn't do by default.
