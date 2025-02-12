#!/bin/bash

# Max files age. Files older than this will be deleted.
RETENTION_DAYS=14

# List of directories to check.
TARGET_DIRS=(
    "/var/log/syslog/fortiadc"
    "/var/log/syslog/fortiweb"
    "/var/log/syslog/fortigate"
)

# This script log file location.
LOG_FILE="/var/log/scripts/log_cleaner/message.log"

# Initialize counters
FILES_CLEANED=0
ERRORS_ENCOUNTERED=0

# Ensure the log file exists and is writable
touch "$LOG_FILE" || { echo "Error: Unable to create or access log file $LOG_FILE"; exit 1; }

# Function to clean old files.
clean_old_files() {
    local dir=$1
    if find "$dir" -type f -mtime +"$RETENTION_DAYS" | grep -q .; then
        log "INFO" "Cleaning files older than $RETENTION_DAYS days in $dir"
        # Increment the count for each deleted file
        find "$dir" -type f -mtime +"$RETENTION_DAYS" -exec rm -v {} \; | while read -r line; do
            log "INFO" "$line"
            ((FILES_CLEANED++))
        done
    else
        log "INFO" "No files older than $RETENTION_DAYS days in $dir"
    fi
}

# Logging function.
log() {
    local level=$1
    local message=$2
    local timestamp=$(date +'%Y-%m-%dT%H:%M:%S')
    local log_entry="$timestamp [$level] cleanup_script.sh $message"
    echo "$log_entry" | tee -a "$LOG_FILE"
}

# Iterate through directories
log "INFO" "Started running script."
for target_dir in "${TARGET_DIRS[@]}"; do
    if [ -d "$target_dir" ]; then
        log "INFO" "Processing directory: $target_dir"
        clean_old_files "$target_dir"
    else
        log "ERROR" "$target_dir is not a valid directory. Skipping..."
        ((ERRORS_ENCOUNTERED++))
    fi
done
log "INFO" "Script finished. Files cleaned: $FILES_CLEANED. Errors encountered: $ERRORS_ENCOUNTERED."
