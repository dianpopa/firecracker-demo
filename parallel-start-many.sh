#!/bin/bash

set -euo pipefail

# Usage
## ./parallel-start-many.sh 0 100 5 # Will start VM#0 to VM#99 5 at a time.

start="${1:-0}"
upperlim="${2:-1}"
parallel="${3:-1}"

FAIL=0

echo "Start @ $(date)".
START_TS=$(date +%s%N | cut -b1-13)

for ((i=0; i<parallel; i++)); do
    echo "i is $i"
    s=$((i * upperlim / parallel))
    e=$(((i+1) * upperlim / parallel))
    ./start-many.sh $s $e &
    pids[$i]=$!
done

# wait for all pids
for pid in "${pids[@]}"; do
    wait $pid || (( FAIL+=1 ))
done

if [ "$FAIL" != "0" ]; then
    echo "Could not run start_many.sh!"
    exit 1
fi

END_TS=$(date +%s%N | cut -b1-13)
END_DATE=$(date)

total=$((upperlim-start))
delta_ms=$((END_TS-START_TS))
delta=$((delta_ms/1000))
rate=$(bc -l <<< "$total/$delta")

cat << EOL
Done @ $END_DATE.
Started $total microVMs in $delta_ms milliseconds.
MicroVM mutation rate was $rate microVMs per second.
EOL

./extract-times.sh &

