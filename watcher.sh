#!/bin/bash

WATCH_DIR="/triage/data"
OUTPUT_DIR="/triage/output"
ELASTIC_SERVER="${ELASTIC_IP:-localhost}"
INDEX_NAME="timeline"

echo "Watching for new triage folders in $WATCH_DIR..."

inotifywait -m -e close_write -e moved_to --format '%w%f' "$WATCH_DIR" | while read NEW_ITEM; do
    if [[ -d "$NEW_ITEM" ]]; then
        BASENAME=$(basename "$NEW_ITEM")
        TIMESTAMP=$(date +%Y%m%d%H%M%S)
        PLSO_FILE="$OUTPUT_DIR/${BASENAME}_${TIMESTAMP}.plaso"

        echo "Processing: $NEW_ITEM"
        log2timeline.py --status_view none "$PLSO_FILE" "$NEW_ITEM"

        echo "Uploading to Elasticsearch at $ELASTIC_SERVER"
        psort.py -o elastic --server "$ELASTIC_SERVER" --elastic-user "$ELASTIC_USER" --elastic-password "$ELASTIC_PASSWORD" --index-name "$INDEX_NAME" "$PLSO_FILE"
        echo "Done processing $NEW_ITEM"
    fi
done