#!/usr/bin/env bash
set -euo pipefail

source "$HOME/.claude/skills/tracking-tasks/_parse-task.sh"

PROJECT_DIR="${1:-${CLAUDE_PROJECT_DIR:-$(pwd)}}"
TASKLOG="$PROJECT_DIR/.claude/tasklog"

if [[ ! -d "$TASKLOG" ]]; then
    echo "No tasklog found at $TASKLOG"
    exit 0
fi

active=""
[[ -f "$TASKLOG/.active" ]] && active=$(<"$TASKLOG/.active")

found=false
while IFS= read -r -d '' taskfile; do
    IFS='|' read -r name summary status <<< "$(parse_task_frontmatter "$taskfile")"

    if [[ -n "$name" ]]; then
        marker=""
        [[ "$name" == "$active" ]] && marker=" ← active"
        printf "%-30s [%-11s] %s%s\n" "$name" "$status" "$summary" "$marker"
        found=true
    fi
done < <(find "$TASKLOG" -maxdepth 2 -name "TASK.md" -print0 2>/dev/null | sort -z)

$found || echo "No tasks found."
