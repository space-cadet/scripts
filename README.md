# Development Scripts Collection

A collection of utility scripts for automation, file conversion, and environment management.

## Projects

### 1. Screenshot Compression System (T1)
**Status**: 🔄 In Progress (Testing Pending)
**Location**: `compressor/`

Automated macOS screenshot compression system that monitors your Screenshots folder and compresses PNG files on capture using ImageMagick and launchd.

**Features**:
- Automatic compression on screenshot capture
- LaunchAgent-based monitoring with QueueDirectories
- POSIX-compatible shell script
- 85% quality, 75% resize for optimal size reduction
- Comprehensive logging

**Quick Start**:
```bash
cd compressor
chmod +x compress-screenshots.sh
cp com.deepak.screenshot-compressor.plist ~/Library/LaunchAgents/
launchctl load ~/Library/LaunchAgents/com.deepak.screenshot-compressor.plist
```

**Documentation**: See [compressor/README.md](compressor/README.md)

---

### 2. PDF to PNG Converter (T2)
**Status**: 🔄 In Progress (Testing Pending)
**Location**: `pdf-to-png/`

Dual-implementation PDF to PNG conversion utility with both shell script and Python approaches.

**Features**:
- Two implementations: Shell (ImageMagick) and Python (pdf2image)
- Comprehensive error handling and validation
- Automatic output directory creation
- Page numbering with zero-padding
- Cross-platform compatibility

**Quick Start**:

Shell version:
```bash
cd pdf-to-png
./pdf_to_png.sh document.pdf ./output
```

Python version:
```bash
cd pdf-to-png
python pdf_to_png.py document.pdf ./output
```

**Documentation**: See [pdf-to-png/README.md](pdf-to-png/README.md)

---

### 3. Conda Environment Backup System (T3)
**Status**: 🔄 In Progress (Testing Pending)
**Location**: `conda-env-backup/`

Comprehensive conda environment backup and restoration system with interactive and non-interactive modes.

**Features**:
- Interactive menu-driven interface
- Non-interactive CLI for automation
- Selective environment backup/restore
- fzf integration for better UX (with fallback)
- Works with both functional and broken conda installations
- Color-coded output
- Timestamped backups

**Quick Start**:

Interactive mode:
```bash
cd conda-env-backup
./conda_env_manager.sh
```

Backup environments:
```bash
./conda_env_manager.sh backup
```

Restore from backup:
```bash
./conda_env_manager.sh restore
```

**Documentation**: See [conda-env-backup/README.md](conda-env-backup/README.md)

---

## Project Structure

```
.
├── README.md                           # This file
├── compressor/                         # T1: Screenshot compression
│   ├── compress-screenshots.sh
│   ├── com.deepak.screenshot-compressor.plist
│   └── README.md
├── pdf-to-png/                        # T2: PDF conversion
│   ├── pdf_to_png.sh
│   ├── pdf_to_png.py
│   ├── README.md
│   ├── pdfs/                          # Input PDFs (gitignored)
│   └── output/                        # Output PNGs (gitignored)
├── conda-env-backup/                  # T3: Conda backup
│   ├── conda_env_manager.sh
│   ├── README.md
│   └── backups/                       # Backup files (gitignored)
└── memory-bank/                       # Project documentation
    ├── tasks/                         # Task tracking
    ├── sessions/                      # Session logs
    ├── implementation-details/        # Technical docs
    └── *.md                           # Memory bank files
```

## Installation

### Prerequisites

**For Screenshot Compression (T1)**:
- macOS
- ImageMagick: `brew install imagemagick`

**For PDF to PNG (T2)**:
- Shell version: ImageMagick (`brew install imagemagick`)
- Python version: Python 3.6+, pdf2image (`pip install pdf2image`), poppler (`brew install poppler`)

**For Conda Backup (T3)**:
- Bash 3.x or later
- Conda (miniconda, anaconda, or miniforge)
- Optional: fzf for enhanced UI (`brew install fzf`)

### Quick Install All Dependencies (macOS)

```bash
# Install Homebrew if not already installed
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Install all dependencies
brew install imagemagick poppler fzf

# Install Python dependencies
pip install pdf2image
```

## Usage Examples

### Screenshot Compression
Once set up, compression happens automatically when you take screenshots. Monitor activity:
```bash
tail -f /tmp/screenshot-compressor.log
```

### PDF Conversion
Convert a PDF to PNG images:
```bash
# Using shell script
./pdf-to-png/pdf_to_png.sh document.pdf output/

# Using Python script
python pdf-to-png/pdf_to_png.py document.pdf output/
```

### Conda Environment Backup
Backup all conda environments:
```bash
cd conda-env-backup
./conda_env_manager.sh backup
```

Restore environments from backup:
```bash
./conda_env_manager.sh restore
```

## Memory Bank System

This project uses a comprehensive memory bank system for documentation and task tracking.

**Key Files**:
- `memory-bank/tasks/*.md` - Individual task documentation
- `memory-bank/activeContext.md` - Current focus and recent changes
- `memory-bank/session_cache.md` - Session state and task status
- `memory-bank/implementation-details/*.md` - Technical documentation

**Quick Reference**:
```bash
# View active tasks
cat memory-bank/activeContext.md

# View task registry
cat memory-bank/tasks.md

# View implementation details
ls memory-bank/implementation-details/
```

## Development Status

| Project | Status | Completion | Testing |
|---------|--------|------------|---------|
| T1: Screenshot Compression | 🔄 In Progress | ~95% | Pending |
| T2: PDF to PNG Converter | 🔄 In Progress | ~95% | Pending |
| T3: Conda Env Backup | 🔄 In Progress | ~95% | Pending |

All three projects have production-ready code with comprehensive error handling. End-to-end testing is the primary remaining task for all projects.

## Contributing

This is a personal scripts collection. Each project is self-contained and can be used independently.

### Code Standards
- POSIX-compatible shell scripts where possible
- Comprehensive error handling
- Helpful error messages
- Documentation for all features
- No hard dependencies when possible

## License

Personal use scripts. No formal license.

## Author

Deepak

## Acknowledgments

- Screenshot compression system created with Claude Haiku 4.5
- Memory bank system following integrated-rules-v6.11 protocol
- All implementations reviewed and documented on 2025-12-26

## Troubleshooting

### Screenshot Compression Not Working
1. Check LaunchAgent status: `launchctl list | grep screenshot-compressor`
2. View error log: `cat /tmp/screenshot-compressor-error.log`
3. Verify ImageMagick: `which magick`
4. Check Full Disk Access permissions in System Preferences

### PDF Conversion Fails
1. Shell: Verify ImageMagick installation: `convert --version`
2. Python: Verify dependencies: `pip show pdf2image` and `which pdfinfo`
3. Check file permissions on input PDF and output directory

### Conda Backup Issues
1. Check conda status: `conda --version`
2. View error messages (color-coded in terminal)
3. Try manual mode if conda is broken (script has fallback methods)
4. Verify backup directory exists and is writable

## Support

For issues or questions:
1. Check the README in each project directory
2. Review implementation documentation in `memory-bank/implementation-details/`
3. Check error logs specific to each tool

## Changelog

See `memory-bank/edit_history.md` for detailed change log.

### Recent Updates (2025-12-26)
- Created comprehensive implementation documentation for all projects
- Corrected memory bank to reflect actual code completion status
- Added T3 (Conda Environment Backup System)
- Updated all task files with accurate progress tracking
