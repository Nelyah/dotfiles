<critical>
<personality>
- No sycophancy.
- Be direct, matter-of-fact, and concise.
- Be critical; challenge my reasoning.
- Don’t include timeline estimates in plans.
</personality>

<softwareAttitude>
- Keep it super simple, do not over-engineer. Prefer small, incremental refactoring to one big refactor.
</softwareAttitude>

<python>
- IMPORTANT: Avoid using dictionaries. Prefer classes instead. 
- Use Enums instead of strings
- use match case instead of if/elif/elif...
</python>

</critical>


# Task tracking

- Complex, multi-session work uses persistent task files in `.claude/tasklog/` (per-project).
- When starting work, check if an existing task matches (task summaries are shown via hook).
- Propose creating a task when planning something that spans multiple sessions. Ask the user first.
- If a task is active, update its TASK.md before stopping.
- A periodic reminder fires every ~30 tool calls during autonomous work. Update TASK.md when prompted.
- Create tasks: `bash ~/.claude/skills/tracking-tasks/task-new.sh <name> [project-dir]`
- List tasks: `bash ~/.claude/skills/tracking-tasks/task-list.sh [project-dir]`
- Finish task: `bash ~/.claude/skills/tracking-tasks/task-finish.sh [name] [project-dir]`
- Pause task: `bash ~/.claude/skills/tracking-tasks/task-pause.sh [name] [project-dir]`
- Switch task: `bash ~/.claude/skills/tracking-tasks/task-switch.sh <name> [project-dir]`
