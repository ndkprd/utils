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

# Ensure the log file exists and is writable
touch "$LOG_FILE" || { echo "Error: Unable to create or access log file $LOG_FILE"; exit 1; }

# Initialize counters
total_files_cleaned=0
total_errors=0

# Function to clean old files.
clean_old_files() {
    local dir=$1
    local files_cleaned=0

    if find "$dir" -type f -mtime +"$RETENTION_DAYS" | grep -q .; then
        log "INFO" "Cleaning files older than $RETENTION_DAYS days in $dir"
        files_cleaned=$(find "$dir" -type f -mtime +"$RETENTION_DAYS" -exec rm -v {} \; | tee >(while read -r line; do log "INFO" "$line"; done) | wc -l)
        total_files_cleaned=$((total_files_cleaned + files_cleaned))
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
        total_errors=$((total_errors + 1))
    fi
done
log "INFO" "Script finished. Files cleaned: $total_files_cleaned. Errors encountered: $total_errors."
