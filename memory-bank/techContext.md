# Technical Context
*Created: 2025-12-05 15:18:31 IST*
*Last Updated: 2025-12-05 15:18:31 IST*

## Implementation Environment

### macOS LaunchAgent Limitations
- Runs in limited shell environment (sh, not bash)
- Minimal PATH - no Homebrew binaries accessible by default
- No access to interactive shell configurations or aliases
- Requires Full Disk Access permission for certain directory access
- Different working directory than interactive terminal

### File Monitoring Approach
**Chosen**: QueueDirectories in plist configuration
- Monitors directory at path: `/Users/deepak/Screenshots/`
- Triggers on file system changes in target directory
- More reliable than WatchPaths for this use case
- Avoids race conditions with rapid file creation

### Compression Configuration
**ImageMagick Settings**:
- Quality: 85% (preserves visual quality while reducing size)
- Resize: 75% of original dimensions
- Format: PNG input, processed via magick
- Processing: Lossless optimization where possible

**File Identification**:
- Scans for PNG files created within last 5 seconds
- Prevents reprocessing of already-compressed files
- Uses `find` command with `-cmin` (change time in minutes)
- More reliable than tracking modification times

### Error Handling & Logging
**Log Locations**:
- Standard output: `/tmp/screenshot-compressor.log`
- Error output: `/tmp/screenshot-compressor-error.log`
- Both use append mode for historical tracking
- Timestamped entries for debugging

**Permission Requirements**:
- Full Disk Access for `/usr/libexec/launchd`
- Or specific folder permissions for Screenshots directory
- Grant through macOS System Settings > Privacy & Security

### Script Execution
**Script Path**: `/Users/deepak/code/scripts/compressor/compress-screenshots.sh`
**Invoked By**: LaunchAgent plist
**Execution Mode**: Non-blocking, asynchronous
**Error Behavior**: Logs errors but doesn't block LaunchAgent

## Key Dependencies
- Homebrew-installed ImageMagick: `/opt/homebrew/bin/magick`
- launchd: macOS native process manager
- bash/sh: Shell interpreter (POSIX-compatible)
- Standard Unix utilities: find, grep, test operators

## Known Issues & Resolutions
1. **Issue**: Permission denied accessing screenshots
   - **Resolution**: Grant Full Disk Access to launchd
   - **Path**: System Settings > Privacy & Security > Full Disk Access

2. **Issue**: ImageMagick binary not found
   - **Resolution**: Verify Homebrew installation and use full path
   - **Path**: `/opt/homebrew/bin/magick`

3. **Issue**: Bash-specific syntax failures
   - **Resolution**: Use POSIX shell syntax only
   - **Examples**: Use [ ] not [[]], use grep instead of arrays

4. **Issue**: Reprocessing same files repeatedly
   - **Resolution**: Time-based file identification with 5-second window
   - **Alternative**: Original approach (complex state tracking) abandoned
