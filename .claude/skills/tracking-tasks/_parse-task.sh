#!/usr/bin/env bash
# Shared helpers for task scripts.
# Usage: source this file, then call the functions.

# Portable in-place sed (macOS needs -i '', GNU/Linux needs -i).
sed_inplace() {
    if sed --version 2>/dev/null | grep -q GNU; then
        sed -i "$@"
    else
        sed -i '' "$@"
    fi
}

# Parse TASK.md frontmatter → name|summary|status

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
