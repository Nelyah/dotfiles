---
name: Use the user todo application
description: Teaches you how to use the user's todo app. You can add tasks, browse tasks, filter them by dates, projects and more.
---

# TODO app

This app is accessed by command-line, through the `bee` command line tool. If you don't have `bee` in the PATH, then you need to inform the user about that.

## Command Structure

**Basic Pattern**: `bee <filter> <action> <arguments>`

- Filters narrow down which tasks to operate on
- Actions specify what to do with the filtered tasks
- Multiple filters are combined with implicit AND

extensive list of commands is shown through `bee help`

## Common Operations

### 1. Get Pending Tasks

Default output is filtering out deleted and completed tasks.

```bash
# Table format (human-readable)
bee list

# JSON format (programmatic)
bee export
```

### 2. Filter by properties


```bash
# Returns newline-separated project names
bee _cmd get projects

# List all tasks in a project (matches hierarchically)
bee list proj:test

# This matches: test.work, does not match all tasks under `test`
bee list proj:test.work

# tasks filtered with tag foo, WITHOUT tag bar, with status completed
# Must set 'all' to filter on all tasks. By default, deleted and completed tasks are filtered
# out
bee all list +foo -bar status:completed
```

### 3. Add New Tasks

```bash
# Simple task
bee add "Task summary"

# Task with multiple properties - project, due dates and tags
bee add "Write docs" proj:work.documentation due:2026-02-15 +writing +docs
```

### 4. Check Due Tasks

```bash
# Tasks due today
bee list due:today

# Tasks due tomorrow
bee list due:tomorrow

# Tasks due in next 3 days
bee list due.before:today+3d

# Tasks due on specific date
bee list due:2026-02-15
```

### 5. Mark task as completed

```bash
# all tasks with tag foo as done
bee +foo done
# Task 2 and 3 as done
bee 2 3 done
```

### 6. Modify tasks

```bash
# all tasks with tag foo get tagged with bar
bee +foo mod +bar
# Task 2 and 3 get the tag foo removed, if present
bee 2 3 mod -foo
```

