#!/usr/bin/env bash
# Shared frontmatter parser for TASK.md files.
# Outputs: name|summary|status
# Usage: source this file, then call parse_task_frontmatter <file>

parse_task_frontmatter() {
    local taskfile="$1"
    local name="" summary="" status=""
    local in_fm=false
    while IFS= read -r line; do
        if [[ "$line" == "---" ]]; then
            if $in_fm; then break; fi
            in_fm=true; continue
        fi
        $in_fm || continue
        case "$line" in
            name:*)    name="${line#name:}";       name="${name# }" ;;
            summary:*) summary="${line#summary:}"; summary="${summary# }" ;;
            status:*)  status="${line#status:}";   status="${status# }" ;;
        esac
    done < "$taskfile"
    printf '%s|%s|%s' "$name" "$summary" "$status"
}
