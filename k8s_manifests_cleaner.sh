#!/bin/bash

# Check if the directory argument is provided
if [ -z "$1" ]; then
    echo "Usage: $0 /path/to/yaml/files"
    exit 1
fi

# Assign the directory path
DIR_PATH="$1"

# Check if the directory exists
if [ ! -d "$DIR_PATH" ]; then
    echo "Error: Directory $DIR_PATH does not exist."
    exit 1
fi

# Define the fields to delete
FIELDS_TO_DELETE=(
    '.metadata.annotations."kubectl.kubernetes.io/last-applied-configuration"'
    '.metadata.annotations."deployment.kubernetes.io/revision"'
    '.metadata.annotations."pv.kubernetes.io/bind-completed"'
    '.metadata.creationTimestamp'
    '.metadata.generation'
    '.metadata.managedFields'
    '.metadata.uid'
    '.metadata.resourceVersion'
    '.spec.claimRef'
    '.spec.clusterIP'
    '.spec.clusterIPs'
    '.spec.template.metadata.annotations'
    '.status'
)

# Find all YAML files recursively and process them
find "$DIR_PATH" -type f \( -name "*.yaml" -o -name "*.yml" \) | while read -r file; do
    echo "Processing $file"

    # Build the del command for all fields
    DEL_COMMAND=""
    for field in "${FIELDS_TO_DELETE[@]}"; do
        DEL_COMMAND+="del(${field}) | "
    done

    # Remove the trailing '| ' and apply the command
    DEL_COMMAND="${DEL_COMMAND% | }"

    yq eval "$DEL_COMMAND" -i "$file"

    echo "Cleaned $file"
done

echo "Done cleaning YAML files in $DIR_PATH"
