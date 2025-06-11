#!/bin/bash

WATCH_DIR="/triage/data"
OUTPUT_DIR="/triage/output"
PROCESSED_FILE="/tmp/processed_folders.txt"

# Create processed tracking file
touch "$PROCESSED_FILE"

# Start Logstash in the background
echo "Starting Logstash..."
/usr/share/logstash/bin/logstash --log.level error -f /etc/logstash/conf.d/pipeline.conf &

echo "Watching $WATCH_DIR for new triage folders..."

# Check folder size in bytes
get_dir_size() {
    du -sb "$1" 2>/dev/null | cut -f1
}

while true; do
    for dir in "$WATCH_DIR"/*/; do
        [ -d "$dir" ] || continue
        BASENAME=$(basename "$dir")

        # Skip already processed
        if grep -Fxq "$BASENAME" "$PROCESSED_FILE"; then
            continue
        fi

        # Check if folder is not being written to
        SIZE1=$(get_dir_size "$dir")
        sleep 5
        SIZE2=$(get_dir_size "$dir")

        if [[ "$SIZE1" -eq "$SIZE2" && "$SIZE1" -gt 0 ]]; then
            echo "Detected complete folder: $dir"

            TIMESTAMP=$(date +%Y%m%d%H%M%S)
            PLSO_FILE="$OUTPUT_DIR/${BASENAME}_${TIMESTAMP}.plaso"
            JSON_FILE="$OUTPUT_DIR/${BASENAME}_${TIMESTAMP}.jsonl"

            echo "Processing with log2timeline..."
            log2timeline.py --status_view none --storage-file "$PLSO_FILE" "$dir"

            echo "Exporting to JSONL..."
            psort.py -o json_line -w "$JSON_FILE" "$PLSO_FILE"

            echo "$BASENAME" >> "$PROCESSED_FILE"
            echo "Finished processing: $dir"
        fi
    done
    sleep 5
done
