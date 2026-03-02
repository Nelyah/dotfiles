#!/usr/bin/env bash
# PreCompact hook — reminds Claude to persist progress before compaction.
# Outputs plain text (not JSON) because PreCompact hooks inject text into
# the conversation context, unlike UserPromptSubmit/Stop which use JSON.
set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
TASKLOG="$PROJECT_DIR/.claude/tasklog"
ACTIVE_FILE="$TASKLOG/.active"

[[ -f "$ACTIVE_FILE" ]] || exit 0
source "$HOME/.claude/skills/tracking-tasks/_parse-task.sh"
read_active_list "$ACTIVE_FILE"
[[ ${#_active[@]} -gt 0 ]] || exit 0

echo "IMPORTANT: Context compaction is about to happen."
echo "Active tasks:"
for _a in "${_active[@]}"; do
    echo "  $_a — update .claude/tasklog/$_a/TASK.md"
done
echo "Record current progress, decisions made, and next steps in each TASK.md."
echo "Anything not saved will be lost after compaction."
