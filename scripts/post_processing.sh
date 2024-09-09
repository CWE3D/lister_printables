#!/bin/bash

# Make this script executable
chmod +x "$0"

# Rest of your script goes here
REPO_PATH="/home/$USER/printer_data/gcodes/lister_printables"

# Create .thumbs directories
find "$REPO_PATH" -type d | while read -r dir; do
    mkdir -p "$dir/.thumbs"
    chmod 755 "$dir/.thumbs"
done

# Extract thumbnails
find "$REPO_PATH" -name "*.gcode" | while read -r file; do
    dir=$(dirname "$file")
    filename=$(basename "$file")
    extract-gcode-thumbnail "$file" -o "$dir/.thumbs/$filename.png"
done