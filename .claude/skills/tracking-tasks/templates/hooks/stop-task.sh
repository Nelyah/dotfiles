#!/usr/bin/env bash
# Stop hook — blocks session end until all active TASK.md files are updated
set -euo pipefail

command -v jq >/dev/null || exit 0

source "$HOME/.claude/skills/tracking-tasks/_parse-task.sh"

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
TASKLOG="$PROJECT_DIR/.claude/tasklog"
ACTIVE_FILE="$TASKLOG/.active"

# No active tasks → allow
[[ -f "$ACTIVE_FILE" ]] || exit 0
read_active_list "$ACTIVE_FILE"
[[ ${#_active[@]} -gt 0 ]] || exit 0

now=$(date +%s)
needs_update=()

for _active_task in "${_active[@]}"; do
    task_md="$TASKLOG/$_active_task/TASK.md"
    [[ -f "$task_md" ]] || continue

    # Task already done → skip
    IFS='|' read -r _ _ status <<< "$(parse_task_frontmatter "$task_md")"
    [[ "$status" == "done" ]] && continue

    # If TASK.md was modified within the last 60 seconds, Claude already
    # saved progress on a previous stop attempt — allow this time.
    mod_time=$(stat -f %m "$task_md" 2>/dev/null || stat -c %Y "$task_md" 2>/dev/null || echo 0)
    (( now - mod_time < 60 )) && continue

    needs_update+=("$_active_task")
done

[[ ${#needs_update[@]} -eq 0 ]] && exit 0

task_list=$(printf '%s, ' "${needs_update[@]}"); task_list="${task_list%, }"
jq -n --arg tasks "$task_list" '{
    "decision": "block",
    "reason": ("Active tasks need updating: " + $tasks + ". Update each task'\''s TASK.md with current progress, decisions, and next steps before stopping.")
}'
