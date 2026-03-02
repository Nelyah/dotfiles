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

# Add a task name to the active list (no-op if already present).
add_to_active() {
    local name="$1" active_file="$2"
    touch "$active_file"
    grep -qxF "$name" "$active_file" 2>/dev/null || echo "$name" >> "$active_file"
}

# Remove a task name from the active list.
remove_from_active() {
    local name="$1" active_file="$2"
    [[ -f "$active_file" ]] || return 0
    grep -vxF "$name" "$active_file" > "${active_file}.tmp" 2>/dev/null || true
    mv "${active_file}.tmp" "$active_file"
}

# Populate global _active array with non-empty lines from active file.
# Compatible with bash 3.2+ (macOS) and bash 4+ (Linux).
read_active_list() {
    local file="$1" line
    _active=()
    [[ -f "$file" ]] || return 0
    while IFS= read -r line; do
        [[ -n "$line" ]] && _active+=("$line")
    done < "$file"
}
