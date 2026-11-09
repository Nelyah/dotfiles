#!/bin/sh
# Vim-aware pane navigation for herdr (vim-tmux-navigator equivalent).
# Usage: nav.sh <left|down|up|right>
# If the focused pane's foreground process is (n)vim or tmux, forward alt+<hjkl>
# to it: Neovim moves between its splits and calls `herdr pane focus` at the
# edge; tmux applies its own vim-aware bindings. Otherwise move herdr focus.
dir="$1"
case "$dir" in
  left) key=alt+h ;;
  down) key=alt+j ;;
  up) key=alt+k ;;
  right) key=alt+l ;;
  *) exit 2 ;;
esac

herdr="${HERDR_BIN_PATH:-herdr}"
pane="$HERDR_ACTIVE_PANE_ID"

if "$herdr" pane process-info --pane "$pane" 2>/dev/null \
  | grep -Eq '"name":"(n?vim|view|vimdiff|nvimdiff|tmux)"'; then
  exec "$herdr" pane send-keys "$pane" "$key"
fi
exec "$herdr" pane focus --pane "$pane" --direction "$dir"
