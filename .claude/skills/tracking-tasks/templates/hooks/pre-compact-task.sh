#!/usr/bin/env bash
# PreCompact hook — reminds Claude to persist progress before compaction.
# Outputs plain text (not JSON) because PreCompact hooks inject text into
# the conversation context, unlike UserPromptSubmit/Stop which use JSON.
set -euo pipefail

PROJECT_DIR="${CLAUDE_PROJECT_DIR:-$(pwd)}"
TASKLOG="$PROJECT_DIR/.claude/tasklog"
ACTIVE_FILE="$TASKLOG/.active"

[[ -f "$ACTIVE_FILE" ]] || exit 0
active=$(<"$ACTIVE_FILE")
[[ -n "$active" ]] || exit 0

cat <<MSG
IMPORTANT: Context compaction is about to happen.
Active task: $active
Update .claude/tasklog/$active/TASK.md NOW — record current progress, decisions made, and next steps.
Anything not saved to TASK.md will be lost after compaction.
MSG
