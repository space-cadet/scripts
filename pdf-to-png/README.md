# PDF to PNG Converter

Converts all pages of a PDF file to individual PNG images.

Two implementations available:
- **pdf_to_png.sh** - Shell script using ImageMagick (simpler, faster)
- **pdf_to_png.py** - Python script using pdf2image (more control)

## Installation

### Option 1: Shell Script (ImageMagick)
On macOS:
```bash
brew install imagemagick
chmod +x pdf_to_png.sh
```

On Ubuntu/Debian:
```bash
sudo apt-get install imagemagick
chmod +x pdf_to_png.sh
```

### Option 2: Python Script
Install Python dependencies:
```bash
pip install pdf2image
```

Install system dependency (poppler):
On macOS:
```bash
brew install poppler
```

On Ubuntu/Debian:
```bash
sudo apt-get install poppler-utils
```

On Fedora:
```bash
sudo dnf install poppler-utils
```

## Usage

### Shell Script (ImageMagick)
```bash
./pdf_to_png.sh <pdf_file> <output_folder>
```

### Python Script
```bash
python pdf_to_png.py <pdf_file> <output_folder>
```

### Arguments
- `pdf_file`: Path to the PDF file to convert
- `output_folder`: Path to folder where PNG images will be saved (created if it doesn't exist)

### Examples

Using shell script:
```bash
./pdf_to_png.sh document.pdf ./output
./pdf_to_png.sh /path/to/document.pdf /path/to/output
```

Using Python script:
```bash
python pdf_to_png.py document.pdf ./output
python pdf_to_png.py /path/to/document.pdf /path/to/output
```

## Output

PNG files are named as: `{pdf_name}_page_{number}.png`

For example, converting `document.pdf` produces:
- `document_page_001.png`
- `document_page_002.png`
- `document_page_003.png`
- etc.

## Requirements

- Python 3.6+
- pdf2image
- poppler (system library)
