#!/usr/bin/env bash
# PostToolUse hook — periodic reminder to update task file during long autonomous work.
# Fires every 30 tool calls when active tasks exist.
set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
TASKLOG="$PROJECT_DIR/.claude/tasklog"
ACTIVE_FILE="$TASKLOG/.active"
COUNTER_FILE="$TASKLOG/.tool-counter"

# No active tasks → exit fast
[[ -f "$ACTIVE_FILE" ]] || exit 0
source "$HOME/.claude/skills/tracking-tasks/_parse-task.sh"
read_active_list "$ACTIVE_FILE"
[[ ${#_active[@]} -gt 0 ]] || exit 0

# Increment counter
count=0
[[ -f "$COUNTER_FILE" ]] && count=$(<"$COUNTER_FILE")
count=$((count + 1))

if (( count >= 30 )); then
    echo -n "0" > "$COUNTER_FILE"
    command -v jq >/dev/null || exit 0
    task_list=$(printf '%s, ' "${_active[@]}"); task_list="${task_list%, }"
    jq -n --arg tasks "$task_list" '{
        "additionalContext": ("Progress checkpoint: ~30 tool calls since last update. Update TASK.md for active tasks (" + $tasks + ") with current progress (check off completed plan steps, add progress log entry), then continue working.")
    }'
else
    echo -n "$count" > "$COUNTER_FILE"
fi
