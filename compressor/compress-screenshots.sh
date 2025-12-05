#!/bin/bash

# Screenshot compression script
# Triggered by QueueDirectories - receives file path as argument

MAGICK="/opt/homebrew/bin/magick"
SCREENSHOTS_DIR="$HOME/Screenshots"

# QueueDirectories passes the directory path, not individual files
# So we need to find the newest PNG file in that directory

timestamp=$(date "+%Y-%m-%d %H:%M:%S %Z")

# Find PNG files created in the last 5 seconds
current_time=$(date +%s)
find "$SCREENSHOTS_DIR" -maxdepth 1 -name "*.png" -type f -newermt "-5 seconds" 2>/dev/null | while read -r file; do
    filename=$(basename "$file")
    
    # Wait briefly to ensure file is fully written
    sleep 0.5
    
    # Compress the file
    if [ -f "$MAGICK" ]; then
        temp_file="${file}.tmp.png"
        
        if "$MAGICK" "$file" -quality 85 -resize 75% "$temp_file" 2>&1; then
            if [ -f "$temp_file" ]; then
                mv "$temp_file" "$file"
                echo "[$timestamp] Compressed: $filename"
            else
                echo "[$timestamp] ERROR: Temp file not created for $filename"
            fi
        else
            echo "[$timestamp] ERROR: ImageMagick failed to compress $filename"
        fi
    else
        echo "[$timestamp] ERROR: ImageMagick not found at $MAGICK"
        exit 1
    fi
done
