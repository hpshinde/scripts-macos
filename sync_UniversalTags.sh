#!/bin/zsh

# Define the file paths
source_file1="/Users/data/Library/Mobile Documents/iCloud~co~fluder~fsnotes/Documents/nvAlt/Universal Tags.txt"
source_file2="/Users/data/Library/Mobile Documents/iCloud~is~workflow~my~workflows/Documents/BaseFiles/UniversalTags.txt"
backup_folder="/Users/data/Library/Mobile Documents/iCloud~is~workflow~my~workflows/Documents/BaseFiles"

# Define backup naming convention with timestamp
timestamp=$(date +%Y%m%d%H%M%S)
backup_file1="$backup_folder/UniversalTags_backup_1_$timestamp.txt"
backup_file2="$backup_folder/UniversalTags_backup_2_$timestamp.txt"

# Log file setup
log_file="$backup_folder/universal_tags_sync.log"
exec >> "$log_file" 2>&1  # Redirect stdout and stderr to log file
echo "------ Sync Started: $(date) ------"

# Dry-run mode (set to true for testing without making changes)
dry_run=false

# Function to send macOS notification
send_notification() {
    osascript -e "display notification \"$1\" with title \"Universal Tags Sync\""
}

# Check if source files exist
if [ ! -f "$source_file1" ] || [ ! -f "$source_file2" ]; then
    echo "Error: One or both source files are missing!"
    send_notification "Error: One or both source files are missing!"
    exit 1
fi

# Check last modified time of both files
mod_time1=$(stat -f "%m" "$source_file1")  # Last modified time for SourceFile1
mod_time2=$(stat -f "%m" "$source_file2")  # Last modified time for SourceFile2

# Determine which file was modified more recently
if [ "$mod_time1" -gt "$mod_time2" ]; then
    # File1 is more recently modified, so backup File2 (the one being overwritten)
    $dry_run || cp "$source_file2" "$backup_file2"
    # Now sync File1 to File2's location (overwriting File2)
    $dry_run || rsync -a "$source_file1" "$source_file2"
    echo "$(date): Synced SourceFile1 to SourceFile2 and backed up SourceFile2."
    send_notification "Updated SourceFile2 with latest changes from SourceFile1."
else
    # File2 is more recently modified, so backup File1 (the one being overwritten)
    $dry_run || cp "$source_file1" "$backup_file1"
    # Now sync File2 to File1's location (overwriting File1)
    $dry_run || rsync -a "$source_file2" "$source_file1"
    echo "$(date): Synced SourceFile2 to SourceFile1 and backed up SourceFile1."
    send_notification "Updated SourceFile1 with latest changes from SourceFile2."
fi

# Clean up old backups - keep only the last 3 backups
backup_count=$(ls -1 "$backup_folder" | grep -E "UniversalTags_backup_.*\.txt" | wc -l)

if [ "$backup_count" -gt 3 ]; then
    # Sort backups by timestamp and delete the oldest ones, keeping only 3
    find "$backup_folder" -name "UniversalTags_backup_*.txt" -print0 | xargs -0 ls -t | tail -n +4 | xargs -I {} $dry_run || rm "{}"
    echo "$(date): Deleted older backups, keeping only the last 3."
    send_notification "Deleted old backups, keeping only the latest 3."
fi

# Send final success notification
send_notification "Universal Tags sync completed successfully."
echo "------ Sync Completed Successfully: $(date) ------"
