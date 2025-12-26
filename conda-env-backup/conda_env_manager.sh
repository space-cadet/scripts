#!/bin/bash

# Interactive Conda Environment Backup and Restore Manager
# Works with both working and broken conda installations

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$SCRIPT_DIR/backups"
BACKUP_FILE="$BACKUP_DIR/conda_environments_$(date +%Y%m%d_%H%M%S).txt"
ENV_LIST_FILE="$BACKUP_DIR/environment_list.txt"

# Create backup directory if it doesn't exist
mkdir -p "$BACKUP_DIR"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if conda is available and working
check_conda() {
    if command -v conda &> /dev/null; then
        # Test if conda actually works
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

# Function to get conda info (fallback to manual inspection)
get_conda_info() {
    print_info "Collecting conda installation information..."
    
    echo "# Conda Environment Backup" > "$BACKUP_FILE"
    echo "# Generated on: $(date)" >> "$BACKUP_FILE"
    echo "# System: $(uname -a)" >> "$BACKUP_FILE"
    echo "" >> "$BACKUP_FILE"
    
    if check_conda; then
        echo "## Conda Installation Info" >> "$BACKUP_FILE"
        conda info >> "$BACKUP_FILE" 2>&1
        echo "" >> "$BACKUP_FILE"
        
        echo "## Conda Configuration" >> "$BACKUP_FILE"
        conda config --show >> "$BACKUP_FILE" 2>&1
        echo "" >> "$BACKUP_FILE"
        print_success "Conda information collected and saved to $BACKUP_FILE"
    else
        echo "## Conda Status" >> "$BACKUP_FILE"
        echo "Conda is not working properly or not installed" >> "$BACKUP_FILE"
        echo "" >> "$BACKUP_FILE"
        print_warning "Conda information collection skipped - conda not working"
    fi
}

# Function to list environments by inspecting filesystem (fallback method)
list_environments_manual() {
    local conda_root="${CONDA_ROOT:-$HOME/miniconda3}"
    if [ ! -d "$conda_root/envs" ]; then
        conda_root="/opt/miniconda3"
    fi
    if [ ! -d "$conda_root/envs" ]; then
        conda_root="/usr/local/miniconda3"
    fi
    
    if [ -d "$conda_root/envs" ]; then
        print_info "Found conda environments directory: $conda_root/envs"
        ls -1 "$conda_root/envs" | grep -v "^\..*" > "$ENV_LIST_FILE" 2>/dev/null
        
        if [ -s "$ENV_LIST_FILE" ]; then
            print_success "Found $(wc -l < "$ENV_LIST_FILE" | tr -d ' ') environments:"
            while IFS= read -r env; do
                if [ -n "$env" ] && [ "$env" != "base" ]; then
                    echo "  - $env"
                fi
            done < "$ENV_LIST_FILE"
        else
            print_warning "No custom environments found in $conda_root/envs"
            echo "" > "$ENV_LIST_FILE"
        fi
    else
        print_error "Could not find conda environments directory"
        echo "" > "$ENV_LIST_FILE"
    fi
}

# Function to list environments
list_environments() {
    if check_conda; then
        print_info "Listing conda environments (using conda)..."
        # conda env list can include entries where the "name" column is actually a full path
        # (e.g. /Users/.../.julia/conda/...). These aren't normal named envs and break downstream logic.
        conda env list |
            grep -v "#" |
            awk '{print $1}' |
            grep -v "^base$" |
            grep -v "/" > "$ENV_LIST_FILE" 2>/dev/null
        
        if [ ! -s "$ENV_LIST_FILE" ]; then
            print_warning "No custom environments found"
            echo "" > "$ENV_LIST_FILE"
        else
            print_success "Found $(wc -l < "$ENV_LIST_FILE" | tr -d ' ') custom environments:"
            while IFS= read -r env; do
                if [ -n "$env" ]; then
                    echo "  - $env"
                fi
            done < "$ENV_LIST_FILE"
        fi
    else
        print_info "Listing conda environments (manual inspection)..."
        list_environments_manual
    fi
}

# Returns 0 if $1 (env name) is present in the remaining args.
# Compatible with bash 3.x (no associative arrays).
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

# Function to backup environment packages manually
backup_environment_manual() {
    local env_name="$1"
    local conda_root="${CONDA_ROOT:-$HOME/miniconda3}"
    local env_path="$conda_root/envs/$env_name"
    
    if [ ! -d "$env_path" ]; then
        print_error "Environment directory not found: $env_path"
        return 1
    fi
    
    print_info "Manually backing up environment: $env_name"
    
    echo "" >> "$BACKUP_FILE"
    echo "### Environment: $env_name (Manual Backup)" >> "$BACKUP_FILE"
    echo "# Exported on: $(date)" >> "$BACKUP_FILE"
    echo "# Environment path: $env_path" >> "$BACKUP_FILE"
    
    # List Python version
    if [ -f "$env_path/bin/python" ]; then
        echo "# Python version:" >> "$BACKUP_FILE"
        "$env_path/bin/python" --version 2>> "$BACKUP_FILE" || echo "# Could not determine Python version" >> "$BACKUP_FILE"
    fi
    
    # List packages from conda-meta
    if [ -d "$env_path/conda-meta" ]; then
        echo "" >> "$BACKUP_FILE"
        echo "# Installed packages (from conda-meta):" >> "$BACKUP_FILE"
        ls "$env_path/conda-meta"/*.json 2>/dev/null | xargs -n 1 basename | sed 's/\.json$//' | sort >> "$BACKUP_FILE" 2>/dev/null
    fi
    
    # List pip packages if pip exists
    if [ -f "$env_path/bin/pip" ]; then
        echo "" >> "$BACKUP_FILE"
        echo "# Pip packages:" >> "$BACKUP_FILE"
        "$env_path/bin/pip" list --format=freeze 2>/dev/null >> "$BACKUP_FILE" || echo "# Could not list pip packages" >> "$BACKUP_FILE"
    fi
}

# Function to backup all environments
backup_environments() {
    local requested_envs=("$@")
    get_conda_info
    list_environments
    
    if [ ! -s "$ENV_LIST_FILE" ]; then
        print_warning "No environments to backup"
        return 0
    fi
    
    print_info "Backing up environment specifications..."
    
    echo "## Environment Specifications" >> "$BACKUP_FILE"
    
    # If no envs were requested via args, prompt interactively.
    if [ ${#requested_envs[@]} -eq 0 ]; then
        local selected
        selected="$(prompt_select_envs_from_file "Select environments to BACKUP:" "$ENV_LIST_FILE")"
        local sel_rc=$?
        if [ $sel_rc -ne 0 ]; then
            print_info "Backup cancelled"
            return 0
        fi
        if [ -n "$selected" ]; then
            # shellcheck disable=SC2206
            requested_envs=($selected)
        fi
    fi

    while IFS= read -r env; do
        if [ -n "$env" ]; then
            if [ ${#requested_envs[@]} -gt 0 ] && ! env_in_list "$env" "${requested_envs[@]}"; then
                continue
            fi
            if check_conda; then
                print_info "Exporting environment: $env"
                echo "" >> "$BACKUP_FILE"
                echo "### Environment: $env" >> "$BACKUP_FILE"
                echo "# Exported on: $(date)" >> "$BACKUP_FILE"
                
                # Try to export as YAML first
                if conda env export -n "$env" >> "$BACKUP_FILE" 2>/dev/null; then
                    echo "# Successfully exported as YAML" >> "$BACKUP_FILE"
                else
                    print_warning "Failed to export $env as YAML, using manual method"
                    backup_environment_manual "$env"
                fi
            else
                backup_environment_manual "$env"
            fi
        fi
    done < "$ENV_LIST_FILE"
    
    print_success "Environment backup completed!"
    print_info "Backup saved to: $BACKUP_FILE"
    print_info "Environment list saved to: $ENV_LIST_FILE"
}

# Function to restore environments from manual backup
restore_manual_backup() {
    local backup_file="$1"
    
    print_info "Restoring from manual backup: $(basename "$backup_file")"
    print_warning "Manual restoration requires you to recreate environments manually"
    print_info "The backup contains package lists that you can use as reference"
    
    # Show summary of what's in the backup
    echo ""
    echo "Environments found in backup:"
    grep "^### Environment:" "$backup_file" | sed 's/^### Environment: //' | sed 's/ (Manual Backup)//'
    
    echo ""
    print_info "To restore manually:"
    print_info "1. Create new environments with appropriate Python versions"
    print_info "2. Install packages from the backup file using conda/pip"
    print_info "3. Refer to the detailed package lists in: $backup_file"
    
    echo ""
    read -p "Would you like to view the backup file now? (y/N): " view_backup
    if [[ "$view_backup" =~ ^[Yy]$ ]]; then
        echo ""
        echo "=== Backup File Contents ==="
        cat "$backup_file"
        echo "=== End of Backup File ==="
    fi
}

# Function to restore environments
restore_environments() {
    local requested_envs=("$@")
    # List available backup files
    print_info "Available backup files:"
    backup_files=($(ls -1 "$BACKUP_DIR"/conda_environments_*.txt 2>/dev/null))
    
    if [ ${#backup_files[@]} -eq 0 ]; then
        print_warning "No backup files found in $BACKUP_DIR"
        return 1
    fi
    
    for i in "${!backup_files[@]}"; do
        echo "$((i+1)). $(basename "${backup_files[$i]}")"
    done
    
    echo ""
    read -p "Select backup file (1-${#backup_files[@]}): " selection
    
    if ! [[ "$selection" =~ ^[0-9]+$ ]] || [ "$selection" -lt 1 ] || [ "$selection" -gt ${#backup_files[@]} ]; then
        print_error "Invalid selection"
        return 1
    fi
    
    selected_backup="${backup_files[$((selection-1))]}"
    print_info "Selected backup: $(basename \"$selected_backup\")"
    
    # Ask for confirmation
    echo ""
    read -p "Do you want to restore environments from this backup? (y/N): " confirm
    
    if [[ ! "$confirm" =~ ^[Yy]$ ]]; then
        print_info "Restore cancelled"
        return 0
    fi
    
    if check_conda; then
        print_info "Starting environment restoration using conda..."
        print_warning "This will create new environments. Existing environments with the same names will be overwritten."
        
        # If no envs were requested via args, prompt interactively from what exists in the backup file.
        if [ ${#requested_envs[@]} -eq 0 ]; then
            local tmp_envs
            tmp_envs="/tmp/conda_env_manager_envs_$$.txt"
            extract_envs_from_backup "$selected_backup" "$tmp_envs"
            local selected
            selected="$(prompt_select_envs_from_file "Select environments to RESTORE:" "$tmp_envs")"
            local sel_rc=$?
            rm -f "$tmp_envs"
            if [ $sel_rc -ne 0 ]; then
                print_info "Restore cancelled"
                return 0
            fi
            if [ -n "$selected" ]; then
                # shellcheck disable=SC2206
                requested_envs=($selected)
            fi
        fi
        
        # Extract and create environments
        current_env=""
        in_yaml_block=false
        yaml_content=""
        
        while IFS= read -r line; do
            # Skip header information
            if [[ "$line" == "## Environment Specifications" ]]; then
                continue
            fi
            
            if [[ "$line" == "### Environment: "* ]] && [[ ! "$line" == *"(Manual Backup)"* ]]; then
                # Save previous environment if exists
                if [ -n "$current_env" ] && [ -n "$yaml_content" ]; then
                    if [ ${#requested_envs[@]} -eq 0 ] || env_in_list "$current_env" "${requested_envs[@]}"; then
                        restore_single_environment "$current_env" "$yaml_content"
                    fi
                fi
                
                # Start new environment
                current_env="${line#### Environment: }"
                current_env="${current_env% (Manual Backup)}"  # Remove manual backup indicator
                yaml_content=""
                in_yaml_block=false
                print_info "Processing environment: $current_env"
            elif [[ "$line" == "name: "* ]] && [ -n "$current_env" ]; then
                in_yaml_block=true
                yaml_content="$line\n"
            elif [ "$in_yaml_block" = true ] && [ -n "$current_env" ]; then
                yaml_content+="$line\n"
            fi
        done < "$selected_backup"
        
        # Save last environment
        if [ -n "$current_env" ] && [ -n "$yaml_content" ]; then
            if [ ${#requested_envs[@]} -eq 0 ] || env_in_list "$current_env" "${requested_envs[@]}"; then
                restore_single_environment "$current_env" "$yaml_content"
            fi
        fi
        
        print_success "Environment restoration completed!"
    else
        restore_manual_backup "$selected_backup"
    fi
}

# Function to restore a single environment
restore_single_environment() {
    local env_name="$1"
    local yaml_content="$2"
    
    if [ -z "$env_name" ] || [ -z "$yaml_content" ]; then
        return 1
    fi
    
    local temp_yaml="/tmp/conda_env_${env_name}_$$.yml"
    
    # Write YAML content to temporary file
    echo -e "$yaml_content" > "$temp_yaml"
    
    # Check if environment already exists
    if conda env list | grep -q "^$env_name\s"; then
        print_warning "Environment '$env_name' already exists"
        read -p "Do you want to remove it first? (y/N): " remove_confirm
        if [[ "$remove_confirm" =~ ^[Yy]$ ]]; then
            print_info "Removing existing environment: $env_name"
            conda env remove -n "$env_name" -y
        else
            print_info "Skipping environment: $env_name"
            rm -f "$temp_yaml"
            return 0
        fi
    fi
    
    # Create environment from YAML
    print_info "Creating environment: $env_name"
    if conda env create -f "$temp_yaml"; then
        print_success "Successfully created environment: $env_name"
    else
        print_error "Failed to create environment: $env_name"
        print_info "You may need to create it manually and install packages"
    fi
    
    # Clean up
    rm -f "$temp_yaml"
}

# Function to show help
show_help() {
    echo "Conda Environment Manager"
    echo "======================="
    echo ""
    echo "Usage: $0 [option] [environment_names...]"
    echo ""
    echo "Options:"
    echo "  backup [env1 env2 ...]  - Create backup of specified environments (or all if none specified)"
    echo "  restore [env1 env2 ...] - Restore specified environments from backup (or all if none specified)"
    echo "  list                    - List current conda environments"
    echo "  info                    - Show conda installation information"
    echo "  help                    - Show this help"
    echo ""
    echo "Interactive Mode:"
    echo "  Run without arguments for interactive mode where you can select"
    echo "  which environments to backup or restore from a menu."
    echo ""
    echo "Selection UI:"
    echo "  If 'fzf' is installed, selection uses an interactive list (up/down + space to toggle)."
    echo "  Otherwise, selection falls back to numeric input."
    echo ""
    echo "Works with both working and broken conda installations."
    echo "Backups are stored in: $BACKUP_DIR"
}

# Function for interactive mode
interactive_mode() {
    print_info "Conda Environment Manager - Interactive Mode"
    echo ""
    # Show conda status
    if check_conda; then
        print_success "Conda is working properly"
    else
        print_warning "Conda is not working properly - using manual methods"
    fi
    
    echo ""
    while true; do
        echo "What would you like to do?"
        echo "1. Create backup (select environments)"
        echo "2. Restore (select environments)"
        echo "3. List current environments"
        echo "4. Show conda information"
        echo "5. Exit"
        echo ""
        
        read -p "Enter your choice (1-5): " choice
        echo ""
        
        case $choice in
            1)
                backup_environments
                echo ""
                ;;
            2)
                restore_environments
                echo ""
                ;;
            3)
                list_environments
                echo ""
                ;;
            4)
                get_conda_info
                echo ""
                ;;
            5)
                print_info "Goodbye!"
                exit 0
                ;;
            *)
                print_error "Invalid choice. Please enter 1-5."
                echo ""
                ;;
        esac
    done
}

# Prompt user to select environments from a file containing one env per line.
# Prints selected env names (space-separated) to stdout.
prompt_select_envs_from_file() {
    local title="$1"
    local list_file="$2"

    if [ ! -s "$list_file" ]; then
        echo ""
        return 0
    fi

    # Prefer fzf for an interactive multi-select UI.
    # - up/down to navigate
    # - space to toggle selection
    # - enter to accept
    # Same note: stdout isn't a TTY under command substitution.
    if command -v fzf >/dev/null 2>&1 && [ -r /dev/tty ] && [ -w /dev/tty ]; then
        printf '%s\n' "$title" 1>&2
        cat "$list_file" |
            fzf --multi \
                --prompt="Select envs (space toggles, enter confirms): " \
                --height=10 \
                --layout=reverse \
                --no-clear \
                --border=none \
                --info=inline \
                --bind="space:toggle" \
                --bind="tab:toggle" \
                --bind="ctrl-a:select-all" \
                --bind="ctrl-d:deselect-all" \
                --exit-0 |
            tr '\n' ' ' |
            sed 's/[[:space:]]\+$//'
        echo ""
        return 0
    fi

    echo "$title"
    echo "Enter env numbers separated by spaces (e.g. '1 3 5'), or press Enter for ALL."
    echo ""

    local i=0
    local env
    while IFS= read -r env; do
        [ -n "$env" ] || continue
        i=$((i+1))
        echo "$i. $env"
    done < "$list_file"

    echo ""
    local selection
    read -p "Selection (Enter for ALL): " selection

    if [ -z "$selection" ]; then
        # All
        tr '\n' ' ' < "$list_file" | sed 's/[[:space:]]\+$//'
        echo ""
        return 0
    fi

    local out=""
    for i in $selection; do
        env="$(awk "NR==$i {print}" "$list_file" 2>/dev/null)"
        if [ -n "$env" ]; then
            out="$out $env"
        fi
    done
    echo "${out# }"
}

# Extract environment names from a backup file (both YAML and manual backups).
# Writes them (one per line) to the file path provided as $2.
extract_envs_from_backup() {
    local backup_file="$1"
    local out_file="$2"

    grep '^### Environment:' "$backup_file" |
        sed 's/^### Environment: //' |
        sed 's/ (Manual Backup)$//' |
        sed 's/[[:space:]]\+$//' > "$out_file" 2>/dev/null
}

# Main execution
main() {
    case "${1:-}" in
        backup)
            shift
            backup_environments "$@"
            ;;
        restore)
            shift
            restore_environments "$@"
            ;;
        list)
            list_environments
            ;;
        info)
            get_conda_info
            ;;
        help|--help|-h)
            show_help
            ;;
        "")
            interactive_mode
            ;;
        *)
            print_error "Unknown option: $1"
            show_help
            exit 1
            ;;
    esac
}

# Run main function
main "$@"
