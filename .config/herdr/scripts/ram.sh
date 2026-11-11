#!/bin/sh

medium_thresh=50
high_thresh=80

report() {
  awk -v value="$1" -v pressure="$2" -v medium="$medium_thresh" -v high="$high_thresh" 'BEGIN {
    if (pressure == "high") level = "critical"
    else if (pressure == "medium") level = "warning"
    else if (pressure == "low") level = "success"
    else level = value >= high ? "critical" : value >= medium ? "warning" : "success"
    printf "{\"text\":\"%d%%\",\"level\":\"%s\"}\n", value, level
  }'
}

case "$(uname -s)" in
  Darwin)
    usage=$(vm_stat | awk -v memsize="$(sysctl -n hw.memsize)" '
      /page size of/ { match($0, /[0-9]+ bytes/); pagesize = substr($0, RSTART, RLENGTH - 6) }
      /^Anonymous pages:/ { anonymous = $3 }
      /^Pages purgeable:/ { purgeable = $3 }
      /^Pages wired down:/ { wired = $4 }
      /^Pages occupied by compressor:/ { compressor = $5 }
      END { print int(100 * (anonymous - purgeable + wired + compressor) * pagesize / memsize) }')
    case "$(sysctl -n kern.memorystatus_vm_pressure_level 2>/dev/null)" in
      4) pressure=high ;;
      2) pressure=medium ;;
      1) pressure=low ;;
      *) pressure=- ;;
    esac
    ;;
  Linux)
    usage=$(awk '/^MemTotal:/ { total = $2 } /^MemAvailable:/ { available = $2 }
      END { if (total > 0) print int(100 * (total - available) / total) }' /proc/meminfo)
    pressure=$(awk '
      $1 == "some" { sub("avg10=", "", $2); some = int($2) }
      $1 == "full" { sub("avg10=", "", $2); full = int($2) }
      END {
        if (some == "") print "-"
        else if (full >= 10) print "high"
        else if (some >= 10) print "medium"
        else print "low"
      }' /proc/pressure/memory 2>/dev/null || echo -)
    ;;
  *)
    exit 0
    ;;
esac

[ -n "$usage" ] && report "$usage" "$pressure"
