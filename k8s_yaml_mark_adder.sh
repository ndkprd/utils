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

# Find all YAML files recursively
find "$DIR_PATH" -type f \( -name "*.yaml" -o -name "*.yml" \) | while read -r file; do
    echo "Processing $file"

    # Read the first line of the file
    first_line=$(head -n 1 "$file")

    # Check if the file starts with '---'
    if [[ "$first_line" != "---" ]]; then
        echo "Adding '---' header to $file"

        # Add '---' to the top of the file with a blank line below it
        {
            echo "---"
            echo ""
            cat "$file"
        } > "${file}.tmp" && mv "${file}.tmp" "$file"
    else
        # Ensure a single blank line separates '---' from the first field
        second_line=$(sed -n '2p' "$file")
        if [[ -n "$second_line" ]]; then
            echo "Fixing spacing after '---' in $file"
            sed -i '1a\\' "$file"
        fi
    fi
done

echo "Done processing YAML files in $DIR_PATH"
