#!/bin/sh
# Status segments for herdr's tab bar (ports the tmux-cpu RAM/CPU modules).
# Usage: status.sh <cpu|ram>
case "$1" in
  cpu)
    # 1s sample, like tmux-cpu: 100 - idle from the second iostat line.
    iostat -c 2 disk0 | tail -n 1 | awk '{printf "CPU %.0f%%\n", 100-$6}'
    ;;
  ram)
    # Same formula as tmux-cpu: (active + wired) / (used + cached + free).
    vm_stat | awk -F: '
      {v=$2; gsub(/[^0-9]/, "", v)}
      /^Pages (active|wired down)/ {used+=v}
      /^Pages (purgeable|speculative|occupied by compressor)|^File-backed pages/ {cached+=v}
      /^Pages free/ {free+=v}
      END {printf "RAM %.0f%%\n", used*100/(used+cached+free)}'
    ;;
  *) exit 2 ;;
esac
