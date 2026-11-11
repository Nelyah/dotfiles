#!/bin/dash
# Vim-aware pane navigation for herdr (vim-tmux-navigator equivalent).
# Usage: nav.sh <left|down|up|right>
# If the focused pane's foreground process is (n)vim or tmux, forward alt+<hjkl>
# to it: Neovim moves between its splits and calls `herdr pane focus` at the
# edge; tmux applies its own vim-aware bindings. Otherwise move herdr focus.
#
# Talks to the herdr socket with /usr/bin/nc instead of exec'ing the herdr CLI:
# endpoint security (Kandji/SentinelOne) holds the first exec of the 24MB herdr
# binary after idle for ~250-400ms, while Apple-signed nc and the socket itself
# answer in a few ms.
dir="$1"
case "$dir" in
  left) key=alt+h ;;
  down) key=alt+j ;;
  up) key=alt+k ;;
  right) key=alt+l ;;
  *) exit 2 ;;
esac

# herdr sets this for plugin actions, shell keybinds and panes. Don't guess a
# default: it differs between herdr builds, XDG_CONFIG_HOME and named sessions.
sock="$HERDR_SOCKET_PATH"
[ -S "$sock" ] || exit 1
# HERDR_PANE_ID when run as a plugin action, HERDR_ACTIVE_PANE_ID as a shell keybind.
pane="${HERDR_PANE_ID:-$HERDR_ACTIVE_PANE_ID}"

request() {
  printf '{"id":"nav","method":"%s","params":%s}\n' "$1" "$2" | /usr/bin/nc -U "$sock"
}

case "$(request pane.process_info "{\"pane_id\":\"$pane\"}")" in
  *'"name":"vim"'* | *'"name":"nvim"'* | *'"name":"view"'* | \
  *'"name":"vimdiff"'* | *'"name":"nvimdiff"'* | *'"name":"tmux"'*)
    request pane.send_keys "{\"pane_id\":\"$pane\",\"keys\":[\"$key\"]}" >/dev/null ;;
  *)
    request pane.focus_direction "{\"pane_id\":\"$pane\",\"direction\":\"$dir\"}" >/dev/null ;;
esac
