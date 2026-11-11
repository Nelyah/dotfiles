#!/bin/sh
# Today's Cursor + Claude spend (reuses the tmux script, which caches both sources).
printf '{"text":"%s"}\n' "$(~/.config/tmux/spend 2>/dev/null)"
