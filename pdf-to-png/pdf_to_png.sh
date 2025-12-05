#!/bin/bash
# Convert PDF pages to PNG images using ImageMagick
#
# Usage: ./pdf_to_png.sh <pdf_file> <output_folder>
#
# Arguments:
#   pdf_file: Path to the PDF file
#   output_folder: Path to folder where PNG images will be saved
#
# Example:
#   ./pdf_to_png.sh document.pdf ./output

set -e

# Check arguments
if [ $# -ne 2 ]; then
    echo "Usage: $0 <pdf_file> <output_folder>"
    echo ""
    echo "Example:"
    echo "  $0 document.pdf ./output"
    exit 1
fi

PDF_FILE="$1"
OUTPUT_FOLDER="$2"

# Validate PDF file exists
if [ ! -f "$PDF_FILE" ]; then
    echo "Error: PDF file not found: $PDF_FILE"
    exit 1
fi

# Check if file is a PDF
if [[ ! "$PDF_FILE" =~ \.pdf$ ]]; then
    echo "Error: File is not a PDF: $PDF_FILE"
    exit 1
fi

# Create output folder if it doesn't exist
mkdir -p "$OUTPUT_FOLDER"

# Get PDF filename without extension
PDF_NAME=$(basename "$PDF_FILE" .pdf)

# Check if convert command exists
if ! command -v convert &> /dev/null; then
    echo "Error: ImageMagick 'convert' command not found"
    echo "Install with: brew install imagemagick (macOS)"
    exit 1
fi

# Convert PDF to PNG
echo "Converting $PDF_FILE..."
convert -density 150 "$PDF_FILE" "$OUTPUT_FOLDER/${PDF_NAME}_page_%03d.png"

# Count generated files
PNG_COUNT=$(ls -1 "$OUTPUT_FOLDER"/${PDF_NAME}_page_*.png 2>/dev/null | wc -l)

if [ $PNG_COUNT -gt 0 ]; then
    echo "Conversion complete: $PNG_COUNT pages saved to $OUTPUT_FOLDER"
    ls -lh "$OUTPUT_FOLDER"/${PDF_NAME}_page_*.png
else
    echo "Error: No PNG files were created"
    exit 1
fi
