#!/bin/bash

WATCH_DIR="/triage/data"
OUTPUT_DIR="/triage/output"

# Start Logstash in the background
echo "Starting Logstash..."
/usr/share/logstash/bin/logstash -f /etc/logstash/conf.d/pipeline.conf &

echo "Watching for new triage folders in $WATCH_DIR..."

inotifywait -m -e close_write -e moved_to --format '%w%f' "$WATCH_DIR" | while read NEW_ITEM; do
    if [[ -d "$NEW_ITEM" ]]; then
        BASENAME=$(basename "$NEW_ITEM")
        TIMESTAMP=$(date +%Y%m%d%H%M%S)
        PLSO_FILE="$OUTPUT_DIR/${BASENAME}_${TIMESTAMP}.plaso"
        JSON_FILE="$OUTPUT_DIR/${BASENAME}_${TIMESTAMP}.jsonl"

        echo "Processing: $NEW_ITEM"
        log2timeline.py --status_view none "$PLSO_FILE" "$NEW_ITEM"

        echo "Exporting to JSONL: $JSON_FILE"
        psort.py -o json_line -w "$JSON_FILE" "$PLSO_FILE"

        echo "Done: $NEW_ITEM"
    fi
done