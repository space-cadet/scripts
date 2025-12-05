# System Patterns
*Created: 2025-12-05 15:18:31 IST*
*Last Updated: 2025-12-05 15:18:31 IST*

## Architecture Overview
The screenshot compression system uses event-driven architecture with macOS LaunchAgent as the event trigger.

## Design Patterns

### 1. File Monitoring Pattern
- **Approach**: QueueDirectories in LaunchAgent plist
- **Reason**: More reliable than WatchPaths for detecting file changes
- **Implementation**: Triggers script when ~/Screenshots directory changes

### 2. File Identification Pattern
- **Approach**: Time-based window (5-second scan)
- **Reason**: Simpler and more reliable than modification time tracking
- **Logic**: Find PNG files created within last 5 seconds, avoid reprocessing
- **Alternative Rejected**: Complex state file tracking, find command filters

### 3. Binary Path Handling Pattern
- **Approach**: Hardcoded full paths to all binaries
- **Reason**: launchd operates with minimal PATH environment (no Homebrew access)
- **Example**: `/opt/homebrew/bin/magick` instead of `magick`
- **Applied To**: All external commands in script

### 4. Shell Compatibility Pattern
- **Approach**: POSIX-compliant syntax only
- **Reason**: launchd uses basic sh, not bash
- **Restrictions**: No associative arrays, no [[]] conditionals, use [ ] instead
- **Benefits**: Ensures predictable behavior across shell environments

### 5. Logging Pattern
- **Approach**: Dual file logging (stdout and stderr redirection)
- **Output Files**: 
  - `/tmp/screenshot-compressor.log` - Standard output
  - `/tmp/screenshot-compressor-error.log` - Error output
- **Reason**: Troubleshoot launchd execution without access to system logs

## Operational Patterns

### Error Recovery
- Logging provides clear error trail for debugging
- Simple structure allows manual correction if needed
- Non-blocking design prevents LaunchAgent from getting stuck

### Performance Optimization
- 5-second window prevents processing overhead
- Compression settings balanced: 85% quality, 75% resize
- Asynchronous execution via LaunchAgent

## Anti-Patterns Avoided
- Complex state file tracking (error-prone)
- Modification time comparison (unreliable after compression)
- Bash-specific syntax (incompatible with launchd)
- Relative paths (error-prone without proper environment)
