# T3: Conda Environment Backup System - Implementation Details
*Created: 2025-12-26 11:44:03 IST*
*Task: T3*

## Overview
Comprehensive conda environment backup and restoration system with interactive and non-interactive modes, supporting both functional and broken conda installations.

## Architecture

### Components
1. **conda_env_manager.sh** - Main script (621 lines)
2. **backups/** - Backup storage directory (gitignored)
3. **Built-in documentation** - Help system integrated into script

### Technology Stack
- Language: Bash (compatible with bash 3.x+)
- External Dependencies (optional): fzf (for enhanced UI)
- Conda: Works with both functional and broken installations
- Storage: Text-based YAML and manual backups

## Implementation Details

### Script Structure

#### Main Functions
1. **check_conda()** - Validates conda availability and functionality
2. **get_conda_info()** - Collects conda installation metadata
3. **list_environments()** - Lists environments (conda or manual)
4. **backup_environments()** - Creates environment backups
5. **restore_environments()** - Restores from backups
6. **interactive_mode()** - Menu-driven interface
7. **show_help()** - Built-in help system

#### Helper Functions
1. **list_environments_manual()** - Filesystem-based env discovery
2. **backup_environment_manual()** - Manual backup for broken conda
3. **restore_single_environment()** - Restores one environment
4. **restore_manual_backup()** - Manual restoration guide
5. **prompt_select_envs_from_file()** - Interactive env selection
6. **extract_envs_from_backup()** - Parses backup file for env names
7. **env_in_list()** - Checks env membership (bash 3.x compatible)

### Operating Modes

#### 1. Interactive Mode (Default)
**Invocation**: Run without arguments
```bash
./conda_env_manager.sh
```

**Features**:
- Menu-driven interface
- Shows conda status on startup
- 5 options: backup, restore, list, info, exit
- Loop until user exits
- Color-coded output

**Menu Flow**:
```
Conda Environment Manager - Interactive Mode
What would you like to do?
1. Create backup (select environments)
2. Restore (select environments)
3. List current environments
4. Show conda information
5. Exit
```

#### 2. Non-Interactive Mode
**Available Commands**:
```bash
./conda_env_manager.sh backup [env1 env2 ...]
./conda_env_manager.sh restore [env1 env2 ...]
./conda_env_manager.sh list
./conda_env_manager.sh info
./conda_env_manager.sh help
```

**Use Cases**:
- Automation scripts
- Scheduled backups
- CI/CD pipelines
- Remote execution

### Environment Selection UI

#### With fzf (Preferred)
**Features**:
- Multi-select interface
- Up/down arrow navigation
- Space/Tab to toggle selection
- Ctrl-A to select all
- Ctrl-D to deselect all
- Enter to confirm
- Visual feedback

**Requirements**:
- fzf installed (`brew install fzf` or equivalent)
- TTY available (readable/writable /dev/tty)

#### Without fzf (Fallback)
**Features**:
- Numbered list display
- Space-separated numeric input
- Enter for all environments
- Simple and portable

**Example**:
```
1. base-env
2. data-science
3. web-dev

Selection (Enter for ALL): 1 3
```

### Backup Mechanism

#### For Working Conda Installations
**Method**: YAML export using `conda env export`

**Format**:
```yaml
### Environment: env_name
# Exported on: 2025-12-26 11:44:03 IST
name: env_name
channels:
  - defaults
  - conda-forge
dependencies:
  - python=3.9
  - numpy=1.21
  - pip:
    - requests==2.26.0
```

**Storage**:
- File: `backups/conda_environments_YYYYMMDD_HHMMSS.txt`
- Contains all selected environments
- Timestamped for version tracking
- Includes conda info and configuration

#### For Broken Conda Installations
**Method**: Manual filesystem inspection

**Data Collected**:
1. Environment directory path
2. Python version (if available)
3. Package list from conda-meta/*.json
4. Pip package list (if pip available)

**Format**:
```
### Environment: env_name (Manual Backup)
# Exported on: 2025-12-26 11:44:03 IST
# Environment path: /Users/deepak/miniconda3/envs/env_name
# Python version: 3.9.7

# Installed packages (from conda-meta):
numpy-1.21.0-py39h_0
pandas-1.3.0-py39h_0

# Pip packages:
requests==2.26.0
beautifulsoup4==4.9.3
```

### Restoration Mechanism

#### For Working Conda Installations
**Method**: YAML-based restoration using `conda env create`

**Process**:
1. User selects backup file
2. User selects environments to restore
3. For each environment:
   - Check if already exists (prompt to remove)
   - Extract YAML from backup
   - Create temp YAML file
   - Run `conda env create -f temp.yml`
   - Clean up temp file

**Conflict Handling**:
- Prompts if environment exists
- Option to remove and recreate
- Option to skip existing

#### For Broken Conda Installations
**Method**: Manual restoration guide

**Process**:
1. Display environments in backup
2. Show manual restoration instructions
3. Option to view full backup file
4. User performs manual restoration

**Instructions Provided**:
1. Create new environments with appropriate Python versions
2. Install packages from backup file using conda/pip
3. Refer to detailed package lists in backup file

### Color-Coded Output

#### Color Scheme
```bash
RED='\033[0;31m'     # Errors
GREEN='\033[0;32m'   # Success
YELLOW='\033[1;33m'  # Warnings
BLUE='\033[0;34m'    # Info
NC='\033[0m'         # No Color
```

#### Message Functions
- **print_info()** - Blue [INFO] prefix
- **print_success()** - Green [SUCCESS] prefix
- **print_warning()** - Yellow [WARNING] prefix
- **print_error()** - Red [ERROR] prefix

### Fallback Mechanisms

#### Conda Detection Fallback
```bash
check_conda() {
    if command -v conda &> /dev/null; then
        if conda --version &> /dev/null; then
            return 0
        else
            print_warning "Conda command exists but is not working properly"
            return 1
        fi
    else
        print_warning "Conda is not installed or not in PATH"
        return 1
    fi
}
```

#### Environment Discovery Fallback
**Primary**: `conda env list`
**Fallback**: Filesystem inspection

**Search Paths**:
1. `$CONDA_ROOT/envs` (from environment variable)
2. `$HOME/miniconda3/envs`
3. `/opt/miniconda3/envs`
4. `/usr/local/miniconda3/envs`

### Bash 3.x Compatibility

#### No Associative Arrays
**Problem**: Bash 3.x lacks associative arrays
**Solution**: Custom `env_in_list()` function using iteration

```bash
env_in_list() {
    local needle="$1"
    shift
    local item
    for item in "$@"; do
        if [ "$item" = "$needle" ]; then
            return 0
        fi
    done
    return 1
}
```

#### No `readarray` or `mapfile`
**Problem**: Bash 3.x lacks array reading commands
**Solution**: While loops with IFS

```bash
while IFS= read -r env; do
    if [ -n "$env" ]; then
        echo "  - $env"
    fi
done < "$ENV_LIST_FILE"
```

## File Locations

### Script Files
- Main script: `/Users/deepak/code/scripts/conda-env-backup/conda_env_manager.sh`
- Backup directory: `/Users/deepak/code/scripts/conda-env-backup/backups/`

### Backup Files
- Pattern: `backups/conda_environments_YYYYMMDD_HHMMSS.txt`
- Environment list: `backups/environment_list.txt` (temporary)
- Temp files: `/tmp/conda_env_manager_envs_$$.txt`
- Temp YAML: `/tmp/conda_env_${env_name}_$$.yml`

### Version Control
- Script: Tracked in git
- Backups directory: Tracked (empty directory)
- Backup files: Ignored (.gitignore)

## Usage Examples

### Interactive Mode
```bash
./conda_env_manager.sh
# Follow menu prompts
```

### Backup All Environments
```bash
./conda_env_manager.sh backup
# Select environments interactively or press Enter for all
```

### Backup Specific Environments
```bash
./conda_env_manager.sh backup data-science web-dev
```

### Restore Environments
```bash
./conda_env_manager.sh restore
# Select backup file, then select environments
```

### Restore Specific Environments
```bash
./conda_env_manager.sh restore data-science
# Still needs to select backup file interactively
```

### List Environments
```bash
./conda_env_manager.sh list
```

### Show Conda Info
```bash
./conda_env_manager.sh info
```

### Show Help
```bash
./conda_env_manager.sh help
```

## Error Handling

### Conda Not Working
- Detects non-functional conda
- Automatically falls back to manual methods
- Displays warning but continues operation
- Provides helpful error messages

### Missing Dependencies
- Checks for fzf availability
- Falls back to numeric selection if missing
- No hard dependencies (fzf is optional enhancement)

### File Operations
- Validates backup file existence
- Checks environment directory existence
- Handles missing or corrupted backups gracefully
- Provides manual recovery instructions

### User Input
- Validates numeric selections
- Handles empty input (selects all)
- Validates backup file selection
- Confirms destructive operations

## Performance Characteristics

### Backup Performance
- Working conda: Fast (uses conda commands)
- Broken conda: Moderate (filesystem inspection)
- Multiple environments: Linear scaling
- Large environments: Depends on package count

### Restore Performance
- Depends on conda package download speed
- Network-dependent
- Can be slow for large environments
- Provides progress feedback

### Memory Usage
- Low (processes one environment at a time)
- No bulk loading of environments
- Temp files cleaned up automatically

## Security Considerations

### Backup Storage
- Backups contain environment specifications
- No sensitive data in YAML exports
- Backups excluded from version control
- Local storage only (no network transmission)

### File Permissions
- Uses default umask for backup files
- No special permission requirements
- Safe for multi-user systems

## Design Decisions

### Why Both Interactive and CLI Modes?
- Interactive: Better UX for manual use
- CLI: Necessary for automation
- Flexibility for different use cases

### Why Support Broken Conda?
- Recovery scenarios common
- Useful during conda migrations
- Helps troubleshoot installation issues
- Provides emergency backup capability

### Why fzf Integration?
- Significantly better UX
- Faster environment selection
- Visual feedback
- Multi-select capability
- Graceful fallback ensures compatibility

### Why Text-Based Backups?
- Human-readable
- Version control friendly
- Easy to inspect and modify
- Platform-independent
- No binary format dependencies

### Why Timestamped Backups?
- Version history
- Non-destructive (no overwriting)
- Easy to track changes
- Facilitates rollback scenarios

### Why Color-Coded Output?
- Improved readability
- Quick error identification
- Better user experience
- Standard terminal practice

## Known Limitations

### Current Limitations
1. **No Automated Scheduling**: Requires manual invocation or cron setup
2. **No Diff Functionality**: Can't compare backups
3. **No Compression**: Backup files stored as plain text
4. **Local Storage Only**: No cloud backup integration
5. **No Encryption**: Backups stored in plain text
6. **Single Backup Directory**: Can't specify alternative locations

### Conda-Specific Limitations
1. **Channel Order**: May not preserve exact channel priorities
2. **Build Strings**: May differ on restoration
3. **Platform-Specific**: Backups may not be cross-platform compatible
4. **Pip Packages**: May require manual intervention for complex pip installs

### Manual Backup Limitations
1. **No Version Pinning**: Exact versions may not be captured
2. **No Channel Info**: Channel information lost
3. **Manual Restoration**: Requires user intervention
4. **Incomplete Metadata**: May miss some package metadata

## Future Enhancements (Not Implemented)

### Potential Improvements
1. **Automated Scheduling**: Built-in cron job setup
2. **Backup Diff**: Compare two backup files
3. **Compression**: gzip backup files
4. **Cloud Integration**: S3, Google Drive, Dropbox sync
5. **Encryption**: Encrypt sensitive backups
6. **Config File**: External configuration file
7. **Backup Pruning**: Automatic old backup cleanup
8. **Cross-Platform Support**: Windows compatibility
9. **Docker Integration**: Backup conda in Docker containers
10. **Rollback**: Quick rollback to previous state

## Testing Strategy

### Manual Testing (Needed)
1. Test backup with working conda
2. Test backup with broken conda
3. Test restore with working conda
4. Test restore with broken conda
5. Test environment selection (fzf and fallback)
6. Test with no environments
7. Test with many environments
8. Test conflict handling (existing envs)
9. Test error scenarios (missing files, etc.)
10. Test interactive mode menu

### Test Scenarios
- Empty conda installation
- Single environment
- Multiple environments
- Broken conda installation
- Missing backup files
- Corrupted backup files
- Environment name conflicts
- Disk space issues
- Permission issues

## Troubleshooting

### Common Issues

**Conda Not Detected**:
- Check PATH environment variable
- Try absolute path to conda
- Check conda installation
- Review error log

**fzf Not Working**:
- Install fzf: `brew install fzf`
- Script falls back automatically
- Numeric selection works without fzf

**Backup File Not Found**:
- Check backups directory exists
- Verify file permissions
- Check backup file timestamp

**Restoration Fails**:
- Check conda is working
- Verify network connectivity (for package downloads)
- Check disk space
- Review conda error messages

### Debug Mode
No built-in debug mode, but can enable with:
```bash
bash -x ./conda_env_manager.sh
```

## Maintenance

### Regular Tasks
- Test backup/restore periodically
- Clean old backup files manually
- Update script for new conda versions
- Test with different conda distributions (miniconda, anaconda, miniforge)

### Code Quality
- 621 lines of well-commented code
- Comprehensive error handling
- Color-coded user feedback
- Modular function design
- Bash 3.x compatible
- No external hard dependencies
- Follows bash best practices

### Documentation
- Built-in help system (`--help`)
- Inline code comments
- Clear function naming
- Comprehensive error messages
- User-friendly prompts
