#!/usr/bin/env bash
set -euo pipefail

source "$HOME/.claude/skills/tracking-tasks/_parse-task.sh"

NAME="${1:?Usage: task-switch.sh <task-name> [project-dir]}"
PROJECT_DIR="${2:-${CLAUDE_PROJECT_DIR:-$(pwd)}}"
TASKLOG="$PROJECT_DIR/.claude/tasklog"
ACTIVE_FILE="$TASKLOG/.active"
TASK_MD="$TASKLOG/$NAME/TASK.md"

if [[ ! -f "$TASK_MD" ]]; then
    echo "ERROR: No task '$NAME' found at $TASKLOG/$NAME/" >&2
    exit 1
fi

# Set new task status to in-progress
sed_inplace 's/^status: .*/status: in-progress/' "$TASK_MD"
echo -n "$NAME" > "$ACTIVE_FILE"
echo "Switched to task: $NAME"
