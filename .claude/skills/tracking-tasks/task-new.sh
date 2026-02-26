#!/usr/bin/env bash
set -euo pipefail

source "$HOME/.claude/skills/tracking-tasks/_parse-task.sh"

NAME="${1:?Usage: task-new.sh <task-name> [project-dir]}"
PROJECT_DIR="${2:-${CLAUDE_PROJECT_DIR:-$(pwd)}}"
TASKLOG="$PROJECT_DIR/.claude/tasklog"
TASK_DIR="$TASKLOG/$NAME"

# Validate task name: lowercase alphanumeric, hyphens, underscores
if [[ ! "$NAME" =~ ^[a-z0-9][a-z0-9_-]*$ ]]; then
    echo "ERROR: Invalid task name '$NAME'." >&2
    echo "       Must match: ^[a-z0-9][a-z0-9_-]*$ (lowercase, digits, hyphens, underscores)" >&2
    exit 1
fi

if [[ -d "$TASK_DIR" ]]; then
    echo "ERROR: Task '$NAME' already exists at $TASK_DIR" >&2
    exit 1
fi

# Validate project dir doesn't contain characters that break YAML
if [[ "$PROJECT_DIR" =~ [\"\'\`\$] ]]; then
    echo "ERROR: Project directory path contains characters that would break YAML frontmatter." >&2
    echo "       Path: $PROJECT_DIR" >&2
    exit 1
fi

# Create directory structure
mkdir -p "$TASK_DIR"/{decisions,explorations,scripts,sessions}

# Tasklog .gitignore: keep task data out of version control.
# Task notes may contain sensitive exploration data and are
# project-local. Remove this file to version-control your tasks.
if [[ ! -f "$TASKLOG/.gitignore" ]]; then
    cat > "$TASKLOG/.gitignore" << 'GI'
*
!.gitignore
GI
fi

# Create TASK.md (quoted heredoc to prevent variable expansion,
# then fill in values explicitly)
cat > "$TASK_DIR/TASK.md" << 'TASKEOF'
---
name: __NAME__
summary: TODO — describe this task
status: in-progress
project: __PROJECT_DIR__
---

## Context

<!-- Why does this task exist? What's the background? -->

## Plan

- [ ] Step 1

## Progress Log

### __DATE__

- Created task

## References

<!-- Links to files, docs, related tasks -->
TASKEOF

# Replace placeholders
sed_inplace "s|__NAME__|$NAME|g" "$TASK_DIR/TASK.md"
sed_inplace "s|__PROJECT_DIR__|$PROJECT_DIR|g" "$TASK_DIR/TASK.md"
sed_inplace "s|__DATE__|$(date +%Y-%m-%d)|g" "$TASK_DIR/TASK.md"

# Set as active task
echo -n "$NAME" > "$TASKLOG/.active"

echo "Created task: $TASK_DIR"
echo "Active task set to: $NAME"
