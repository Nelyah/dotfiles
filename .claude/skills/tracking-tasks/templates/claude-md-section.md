# Task tracking

- Complex, multi-session work uses persistent task files in `.claude/tasklog/` (per-project).
- When starting work, check if an existing task matches (task summaries are shown via hook).
- Propose creating a task when planning something that spans multiple sessions. Ask the user first.
- If a task is active, update its TASK.md before stopping.
- Create tasks: `bash ~/.claude/skills/tracking-tasks/task-new.sh <name> [project-dir]`
- List tasks: `bash ~/.claude/skills/tracking-tasks/task-list.sh [project-dir]`
- Finish task: `bash ~/.claude/skills/tracking-tasks/task-finish.sh [name] [project-dir]`
- Pause task: `bash ~/.claude/skills/tracking-tasks/task-pause.sh [name] [project-dir]`
- Switch task: `bash ~/.claude/skills/tracking-tasks/task-switch.sh <name> [project-dir]`
