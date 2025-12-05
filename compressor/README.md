# Screenshot Compressor

## Overview
Automated screenshot compression tool for macOS that monitors your Screenshots folder and compresses new PNG files on capture.

**Author:** Claude Haiku 4.5  
**Created:** Saturday, November 29, 2025 at 10:58 IST  
**Last Updated:** Saturday, November 29, 2025 at 10:58 IST

## Purpose
This script automatically reduces the file size of screenshots taken on macOS, which helps minimize token usage when passing images to Large Language Models (LLMs). Smaller file sizes mean lower token consumption and more efficient API usage.

## Files
- `compress-screenshots.sh` - Main compression script
- `com.deepak.screenshot-compressor.plist` - LaunchAgent configuration file
- `README.md` - This documentation file

## Installation

### Prerequisites
- macOS
- ImageMagick (install via Homebrew: `brew install imagemagick`)

### Setup Steps

1. **Make the script executable:**
   ```bash
   chmod +x /Users/deepak/code/scripts/compressor/compress-screenshots.sh
   ```

2. **Copy the plist to LaunchAgents:**
   ```bash
   cp /Users/deepak/code/scripts/compressor/com.deepak.screenshot-compressor.plist ~/Library/LaunchAgents/
   ```

3. **Load the LaunchAgent:**
   ```bash
   launchctl load ~/Library/LaunchAgents/com.deepak.screenshot-compressor.plist
   ```

## How It Works
- The LaunchAgent watches `/Users/deepak/Documents/Screenshots` for new files
- When a PNG screenshot is detected, the script compresses it automatically
- Compression settings:
  - Quality: 85%
  - Resize: 75% of original dimensions
  - Output format: PNG

## Logging
The script logs compression activity to:
- `stdout`: `/tmp/screenshot-compressor.log`
- `stderr`: `/tmp/screenshot-compressor-error.log`

View logs with:
```bash
tail -f /tmp/screenshot-compressor.log
```

## Managing the Agent

### Check if running
```bash
launchctl list | grep screenshot-compressor
```

### Stop the agent
```bash
launchctl unload ~/Library/LaunchAgents/com.deepak.screenshot-compressor.plist
```

### Restart the agent
```bash
launchctl unload ~/Library/LaunchAgents/com.deepak.screenshot-compressor.plist
launchctl load ~/Library/LaunchAgents/com.deepak.screenshot-compressor.plist
```

## Customization
To adjust compression settings, edit `compress-screenshots.sh`:
- Line 41: Change `-quality 85` for different quality levels
- Line 41: Change `-resize 75%` for different resize percentages

## Troubleshooting

**ImageMagick not found:**
```bash
brew install imagemagick
```

**LaunchAgent not running:**
Check the error log:
```bash
cat /tmp/screenshot-compressor-error.log
```

**Manual test:**
Run the script directly to test:
```bash
bash /Users/deepak/code/scripts/compressor/compress-screenshots.sh
```
