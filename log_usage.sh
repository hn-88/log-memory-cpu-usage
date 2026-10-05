#!/usr/bin/env bash
#
# log_usage.sh - Log memory and CPU usage to a CSV file every minute.
#
# Usage:   ./log_usage.sh [output_file.csv]
# Default: ~/system_usage.csv
#
# Columns: timestamp, mem_used_MB, mem_total_MB, mem_used_percent, cpu_used_percent

OUTFILE="${1:-$HOME/system_usage.csv}"
INTERVAL=60      # seconds between log entries
CPU_SAMPLE=1     # seconds over which CPU usage is measured

# Write the header only if the file doesn't exist yet
if [[ ! -f "$OUTFILE" ]]; then
    echo "timestamp,mem_used_MB,mem_total_MB,mem_used_percent,cpu_used_percent" > "$OUTFILE"
fi

# Prints overall CPU usage (%) measured over $CPU_SAMPLE seconds, using /proc/stat
get_cpu_usage() {
    local cpu user nice system idle iowait irq softirq steal rest
    local idle1 total1 idle2 total2

    read -r cpu user nice system idle iowait irq softirq steal rest < /proc/stat
    idle1=$((idle + iowait))
    total1=$((user + nice + system + idle + iowait + irq + softirq + steal))

    sleep "$CPU_SAMPLE"

    read -r cpu user nice system idle iowait irq softirq steal rest < /proc/stat
    idle2=$((idle + iowait))
    total2=$((user + nice + system + idle + iowait + irq + softirq + steal))

    awk -v di=$((idle2 - idle1)) -v dt=$((total2 - total1)) \
        'BEGIN { if (dt > 0) printf "%.1f", (1 - di / dt) * 100; else print "0.0" }'
}

echo "Logging to $OUTFILE every ${INTERVAL}s. Press Ctrl+C to stop."

while true; do
    timestamp=$(date '+%Y-%m-%d %H:%M:%S')

    # Memory in MB from `free -m` ("used" = total minus available)
    read -r mem_used mem_total < <(free -m | awk '/^Mem:/ {print $3, $2}')
    mem_pct=$(awk -v u="$mem_used" -v t="$mem_total" 'BEGIN { printf "%.1f", u / t * 100 }')

    cpu_pct=$(get_cpu_usage)

    echo "$timestamp,$mem_used,$mem_total,$mem_pct,$cpu_pct" >> "$OUTFILE"

    sleep $((INTERVAL - CPU_SAMPLE))
done
