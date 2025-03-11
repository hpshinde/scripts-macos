#!/usr/bin/env bash

# Force bash execution
if [ -z "$BASH_VERSION" ]; then
    exec bash "$0" "$@"
    exit
fi

# Configuration
SCRIPT_DIR="/Users/data/Scripts"
LOG_DIR="${SCRIPT_DIR}/tmp"
LOGFILE="${LOG_DIR}/cleanup_log.txt"
STATUS_FILE="${LOG_DIR}/swiftbar_script_status.txt"

# Status symbols
SUCCESS_SYMBOL="✅ All Cleaned"
FAILURE_SYMBOL="⛔️ Cleaning Failed"

# Create log directory if it doesn't exist
mkdir -p "${LOG_DIR}"

# Function to log messages
log_message() {
    local timestamp=$(date +"%Y-%m-%d %H:%M:%S")
    echo "${timestamp} - $1" >> "${LOGFILE}"
}

# Function to update status
update_status() {
    echo "$1" > "${STATUS_FILE}"
}

# Function to send macOS terminal notifications
send_notification() {
    if command -v terminal-notifier &> /dev/null; then
        terminal-notifier -title "Cleanup Script" -message "$1"
    else
        log_message "WARNING: terminal-notifier not installed. Notification not sent."
    fi
}

# Function to check sudo access
check_sudo_access() {
    if ! sudo -n true 2>/dev/null; then
        log_message "ERROR: sudo access required. Add to sudoers using visudo."
        update_status "${FAILURE_SYMBOL}"
        send_notification "Cleanup failed: sudo access required."
        return 1
    fi
    return 0
}

# Function to safely remove files
safe_remove() {
    local target="$1"
    local description="$2"
    
    log_message "Cleaning ${description}..."
    
    if [[ -e "${target}" ]]; then
        if sudo rm -rf "${target}"/* 2>/dev/null; then
            log_message "Successfully cleaned ${description}."
        else
            log_message "WARNING: Failed to clean some files in ${description}."
        fi
    else
        log_message "INFO: ${description} directory not found or is empty."
    fi
}

# Function to run periodic maintenance
run_periodic_maintenance() {
    log_message "Running system maintenance scripts..."
    
    if sudo periodic daily weekly monthly; then
        log_message "System maintenance completed successfully."
        return 0
    else
        log_message "ERROR: System maintenance failed."
        return 1
    fi
}

# Function to find and remove specific files recursively
find_and_remove_recursively() {
    local directory="$1"
    local filename="$2"
    local description="$3"
    
    log_message "Recursively searching for ${filename} files in ${description}..."
    
    # Count files first
    local count=$(find "${directory}" -type f -name "${filename}" | wc -l)
    count=$(echo "${count}" | tr -d '[:space:]')
    
    if [[ "${count}" -gt 0 ]]; then
        if find "${directory}" -type f -name "${filename}" -exec sudo rm -f {} \; 2>/dev/null; then
            log_message "Successfully removed ${count} ${filename} files from ${description}."
        else
            log_message "WARNING: Failed to remove some ${filename} files from ${description}."
        fi
    else
        log_message "INFO: No ${filename} files found in ${description}."
    fi
}

# Function to clean old log files
clean_old_logs() {
    local directory="$1"
    local days="$2"
    local description="$3"
    
    log_message "Cleaning logs older than ${days} days in ${description}..."
    
    if [[ -d "${directory}" ]]; then
        local count=$(find "${directory}" -type f -mtime +${days} | wc -l)
        count=$(echo "${count}" | tr -d '[:space:]')
        
        if [[ "${count}" -gt 0 ]]; then
            if find "${directory}" -type f -mtime +${days} -exec sudo rm -f {} \; 2>/dev/null; then
                log_message "Successfully removed ${count} old log files from ${description}."
            else
                log_message "WARNING: Failed to remove some old log files from ${description}."
            fi
        else
            log_message "INFO: No log files older than ${days} days found in ${description}."
        fi
    else
        log_message "INFO: ${description} directory not found."
    fi
}

# Directories to clean - easy to add more folders
declare -A CLEANUP_DIRS
# Format: CLEANUP_DIRS[description]="path"
CLEANUP_DIRS["Trash"]="/Users/data/.Trash"
CLEANUP_DIRS["User cache"]="${HOME}/Library/Caches"
CLEANUP_DIRS["color-swatches"]="/Users/data/Scripts/tmp/color-swatches"

# Directories to search for specific files
declare -A SEARCH_DIRS
# Format: SEARCH_DIRS[description]="path:filename"
SEARCH_DIRS["Documents"]="/Users/data/Documents:plot.log"

# Directories for old log cleaning. With the age-based approach, we only remove older logs that are typically no longer needed for day-to-day system operation
declare -A OLD_LOG_DIRS
# Format: OLD_LOG_DIRS[description]="path:days"
OLD_LOG_DIRS["System logs"]="/Library/Logs:30"
OLD_LOG_DIRS["User logs"]="${HOME}/Library/Logs:30"
OLD_LOG_DIRS["System logs (/var/log)"]="/var/log:30"
OLD_LOG_DIRS["System logs (/private/var/log)"]="/private/var/log:30"

# Main cleanup function
perform_cleanup() {
    local error_occurred=0
    
    # Check for sudo access first
    check_sudo_access || return 1
    
    # Clean directories
    for desc in "${!CLEANUP_DIRS[@]}"; do
        safe_remove "${CLEANUP_DIRS[$desc]}" "$desc"
    done
    
    # Find and remove specific files
    for desc in "${!SEARCH_DIRS[@]}"; do
        IFS=':' read -r dir filename <<< "${SEARCH_DIRS[$desc]}"
        find_and_remove_recursively "$dir" "$filename" "$desc"
    done
    
    # Clean old log files
    for desc in "${!OLD_LOG_DIRS[@]}"; do
        IFS=':' read -r dir days <<< "${OLD_LOG_DIRS[$desc]}"
        clean_old_logs "$dir" "$days" "$desc"
    done
    
    # Run periodic maintenance
    run_periodic_maintenance || error_occurred=1
    
    # Check for overall success
    if [[ ${error_occurred} -eq 0 ]]; then
        log_message "Cleanup completed successfully."
        update_status "${SUCCESS_SYMBOL}"
        send_notification "Cleanup completed successfully."
        return 0
    else
        log_message "Cleanup completed with errors. Check log for details."
        update_status "${FAILURE_SYMBOL}"
        send_notification "Cleanup completed with errors. Check logs for details."
        return 1
    fi
}

# Main execution
{
    log_message "Cleanup started."
    send_notification "Cleanup process started."
    
    perform_cleanup
    exit_code=$?
    
    exit ${exit_code}
} &