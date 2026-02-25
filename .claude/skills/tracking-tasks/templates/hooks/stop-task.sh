#!/usr/bin/env bash
# Stop hook — blocks session end until TASK.md is updated
set -euo pipefail

command -v jq >/dev/null || exit 0

source "$HOME/.claude/skills/tracking-tasks/_parse-task.sh"

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
TASKLOG="$PROJECT_DIR/.claude/tasklog"
ACTIVE_FILE="$TASKLOG/.active"

# No active task → allow
[[ -f "$ACTIVE_FILE" ]] || exit 0
active=$(<"$ACTIVE_FILE")
[[ -n "$active" ]] || exit 0

# Task already done → allow
task_md="$TASKLOG/$active/TASK.md"
if [[ -f "$task_md" ]]; then
    IFS='|' read -r _ _ status <<< "$(parse_task_frontmatter "$task_md")"
    [[ "$status" == "done" ]] && exit 0
fi

# If TASK.md was modified within the last 60 seconds, Claude already
# saved progress on a previous stop attempt — allow this time.
if [[ -f "$task_md" ]]; then
    mod_time=$(stat -f %m "$task_md" 2>/dev/null || stat -c %Y "$task_md" 2>/dev/null || echo 0)
    now=$(date +%s)
    if (( now - mod_time < 60 )); then
        exit 0
    fi
fi

# First firing — block and ask Claude to save progress
jq -n --arg active "$active" '{
    "decision": "block",
    "reason": ("Active task: " + $active + ". Update .claude/tasklog/" + $active + "/TASK.md with current progress, decisions, and next steps before stopping.")
}'
