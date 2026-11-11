#!/bin/sh

level() {
  awk -v value="$1" 'BEGIN {
    level = value >= 80 ? "critical" : value >= 30 ? "warning" : "success"
    printf "{\"text\":\"%d%%\",\"level\":\"%s\"}\n", value, level
  }'
}

case "$(uname -s)" in
  Darwin)
    usage=$(iostat -n 0 -w 1 -c 2 | awk '$1 ~ /^[0-9]+$/ { value = 100 - $3 } END { print value }')
    ;;
  Linux)
    read -r _ u1 n1 s1 i1 w1 q1 sq1 st1 _ </proc/stat
    sleep 1
    read -r _ u2 n2 s2 i2 w2 q2 sq2 st2 _ </proc/stat
    total=$(( (u2 + n2 + s2 + i2 + w2 + q2 + sq2 + st2) - (u1 + n1 + s1 + i1 + w1 + q1 + sq1 + st1) ))
    idle=$(( (i2 + w2) - (i1 + w1) ))
    [ "$total" -gt 0 ] || exit 0
    usage=$(( 100 - 100 * idle / total ))
    ;;
  *)
    exit 0
    ;;
esac

[ -n "$usage" ] && level "$usage"
