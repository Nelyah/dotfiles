#!/usr/bin/env bash
# UserPromptSubmit hook — surfaces task summaries as additionalContext
set -euo pipefail

command -v jq >/dev/null || exit 0

PARSE_SCRIPT="$HOME/.claude/skills/tracking-tasks/_parse-task.sh"
source "$PARSE_SCRIPT"

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
TASKLOG="$PROJECT_DIR/.claude/tasklog"

[[ -d "$TASKLOG" ]] || exit 0

summaries=()
while IFS= read -r -d '' taskfile; do
    IFS='|' read -r name summary status <<< "$(parse_task_frontmatter "$taskfile")"
    [[ -n "$name" ]] && summaries+=("[$status] $name — $summary")
done < <(find "$TASKLOG" -maxdepth 2 -name "TASK.md" -print0 2>/dev/null | sort -z)

[[ ${#summaries[@]} -eq 0 ]] && exit 0

read_active_list "$TASKLOG/.active"

ctx="Tasks in .claude/tasklog/:"
for s in "${summaries[@]}"; do
    ctx+=$'\n'"  $s"
done
if [[ ${#_active[@]} -gt 0 ]]; then
    ctx+=$'\n'"Active tasks (read their TASK.md for full context):"
    for _a in "${_active[@]}"; do ctx+=$'\n'"  $_a"; done
fi

jq -n --arg c "$ctx" '{"additionalContext": $c}'
