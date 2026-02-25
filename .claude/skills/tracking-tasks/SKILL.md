---
name: tracking-tasks
description: >
  Manages persistent task files that survive compactions and session boundaries.
  Use when starting complex multi-session work, or when task summaries appear in
  context from the UserPromptSubmit hook.
---
# Task Tracking

Persistent task files in `.claude/tasklog/` (per-project) preserve context across
compactions and sessions.

## Setup

```bash
python3 ~/.claude/skills/tracking-tasks/install.py install
```

This installs hook scripts to `~/.claude/hooks/`, registers them in
`~/.claude/settings.json`, and appends a task tracking section to `~/.claude/CLAUDE.md`.

To remove: `python3 ~/.claude/skills/tracking-tasks/install.py uninstall`

## When to create a task

Propose a task when work is complex enough to span multiple sessions or survive
compactions. **Always ask the user before creating one.**

## Creating a task

```bash
bash ~/.claude/skills/tracking-tasks/task-new.sh <task-name> [project-dir]
```

This creates:
```
.claude/tasklog/<task-name>/
├── TASK.md           # Frontmatter + plan, progress, references
├── decisions/        # Numbered decision records
├── explorations/     # Numbered exploration notes
├── scripts/          # Helper scripts
└── sessions/         # Per-session detailed logs
```

And sets `.claude/tasklog/.active` to the new task name.

## Listing tasks

```bash
bash ~/.claude/skills/tracking-tasks/task-list.sh [project-dir]
```

## TASK.md format

```yaml
---
name: <task-name>
summary: <one-line description>
status: in-progress  # in-progress | paused | done
project: <absolute-path>
---
```

Followed by markdown sections:

- **Context**: Why this task exists, background
- **Plan**: Numbered steps with `- [ ]` / `- [x]` checkboxes
- **Progress Log**: Dated entries of what was done
- **References**: Links to files, docs, related tasks

## Updating progress

When a compaction warning or stop-hook fires, update the active task:

1. Check off completed plan steps in TASK.md
2. Create a session log file in `sessions/`:
   ```
   sessions/YYYY-MM-DD-NNN.md   # e.g. sessions/2026-02-25-001.md
   ```
   Include full details: what was done, commands run, files changed, problems
   encountered, decisions made, and next steps.
3. Add a **short summary** (1–3 lines) to the Progress Log in TASK.md with a
   link to the session file:
   ```markdown
   ### 2026-02-25
   - Implemented auth middleware and added tests. [details](sessions/2026-02-25-001.md)
   ```
4. Note any decisions made (optionally create a decision record)

Keep TASK.md scannable — detailed context belongs in session files.

## Finishing a task

```bash
bash ~/.claude/skills/tracking-tasks/task-finish.sh [task-name] [project-dir]
```

Defaults to the active task. Sets `status: done` and clears `.active`.

## Pausing a task

```bash
bash ~/.claude/skills/tracking-tasks/task-pause.sh [task-name] [project-dir]
```

Defaults to the active task. Sets `status: paused` and clears `.active`.

## Switching tasks

```bash
bash ~/.claude/skills/tracking-tasks/task-switch.sh <task-name> [project-dir]
```

Sets the target task to `in-progress` and updates `.active`.

## Decision records

For significant decisions, create a file in the `decisions/` folder:
```
decisions/001-chose-jwt-over-sessions.md
```

Keep them brief: context, options considered, decision, rationale.

## Exploration notes

For research and investigation results, create a file in `explorations/`:
```
explorations/001-auth-library-comparison.md
```
