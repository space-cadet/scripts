#!/usr/bin/env python3
"""
Convert PDF pages to PNG images.

Usage:
    python pdf_to_png.py <pdf_file> <output_folder>

Arguments:
    pdf_file: Path to the PDF file
    output_folder: Path to folder where PNG images will be saved

Example:
    python pdf_to_png.py document.pdf ./output
"""

import sys
import os
from pathlib import Path

try:
    from pdf2image import convert_from_path
except ImportError:
    print("Error: pdf2image not installed.")
    print("Install with: pip install pdf2image")
    print("Also requires: poppler (brew install poppler on macOS)")
    sys.exit(1)


def convert_pdf_to_png(pdf_file, output_folder):
    """Convert all pages of a PDF to PNG images."""
    
    # Validate input file
    pdf_path = Path(pdf_file)
    if not pdf_path.exists():
        print(f"Error: PDF file not found: {pdf_file}")
        sys.exit(1)
    
    if not pdf_path.suffix.lower() == '.pdf':
        print(f"Error: File is not a PDF: {pdf_file}")
        sys.exit(1)
    
    # Create output folder if it doesn't exist
    output_path = Path(output_folder)
    output_path.mkdir(parents=True, exist_ok=True)
    
    try:
        # Convert PDF to images
        print(f"Converting {pdf_path.name}...")
        images = convert_from_path(str(pdf_path))
        
        # Save each page as PNG
        pdf_name = pdf_path.stem
        for i, image in enumerate(images, 1):
            output_file = output_path / f"{pdf_name}_page_{i:03d}.png"
            image.save(str(output_file), 'PNG')
            print(f"  Saved: {output_file.name}")
        
        print(f"\nConversion complete: {len(images)} pages saved to {output_folder}")
        
    except Exception as e:
        print(f"Error during conversion: {e}")
        sys.exit(1)


def main():
    if len(sys.argv) != 3:
        print("Usage: python pdf_to_png.py <pdf_file> <output_folder>")
        print("\nExample:")
        print("  python pdf_to_png.py document.pdf ./output")
        sys.exit(1)
    
    pdf_file = sys.argv[1]
    output_folder = sys.argv[2]
    
    convert_pdf_to_png(pdf_file, output_folder)


if __name__ == "__main__":
    main()
