# Project Brief
*Created: 2025-11-29 10:58:28 IST*
*Last Updated: 2025-12-05 15:18:31 IST*

## Project Overview
**Project Name**: Screenshot Compression Automation
**Description**: Automated macOS system that monitors ~/Screenshots directory and compresses PNG files in real-time using ImageMagick, reducing file sizes before passing images to LLMs to minimize token consumption and costs.

## Objectives
1. Automatically compress new screenshots on capture
2. Reduce file sizes to minimize LLM token usage
3. Maintain reliable automation without manual intervention
4. Provide transparent logging for troubleshooting

## Key Features
- Real-time directory monitoring via LaunchAgent
- 85% quality JPEG compression
- 75% resize of original dimensions
- Automatic file identification (5-second window)
- Comprehensive error logging
- POSIX-compatible shell script for reliability

## Tech Stack
- **Language**: Bash (POSIX-compatible)
- **Image Processing**: ImageMagick (magick binary)
- **Automation**: macOS LaunchAgent
- **Logging**: File-based logging to /tmp/

## Constraints & Requirements
- Full Disk Access permissions required for launchd
- ImageMagick installed via Homebrew at /opt/homebrew/bin/magick
- launchd environment lacks interactive shell PATH
- Must use full binary paths (no Homebrew PATH access)
- POSIX shell syntax only (no bash arrays or [[]] conditionals)

## Success Metrics
- Screenshots automatically compressed within 5 seconds of capture
- Compression ratio: 85-90% file size reduction typical
- Zero manual intervention required
- Reliable logging for debugging

## Key Learnings
- QueueDirectories more reliable than WatchPaths for LaunchAgent file monitoring
- Time-based file identification (5-second window) more reliable than modification time
- launchd environment significantly different from interactive terminal
- Simple solutions outperform complex state tracking approaches
