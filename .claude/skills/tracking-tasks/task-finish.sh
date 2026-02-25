#!/usr/bin/env bash
set -euo pipefail

source "$HOME/.claude/skills/tracking-tasks/_parse-task.sh"

PROJECT_DIR="${2:-${CLAUDE_PROJECT_DIR:-$(pwd)}}"
TASKLOG="$PROJECT_DIR/.claude/tasklog"
ACTIVE_FILE="$TASKLOG/.active"

NAME="${1:-}"
if [[ -z "$NAME" && -f "$ACTIVE_FILE" ]]; then
    NAME=$(<"$ACTIVE_FILE")
fi
if [[ -z "$NAME" ]]; then
    echo "Usage: task-finish.sh [task-name] [project-dir]" >&2
    echo "       (defaults to active task)" >&2
    exit 1
fi

TASK_MD="$TASKLOG/$NAME/TASK.md"
if [[ ! -f "$TASK_MD" ]]; then
    echo "ERROR: No TASK.md at $TASK_MD" >&2
    exit 1
fi

sed -i '' 's/^status: .*/status: done/' "$TASK_MD"
echo -n > "$ACTIVE_FILE"
echo "Task '$NAME' marked as done. Active task cleared."
