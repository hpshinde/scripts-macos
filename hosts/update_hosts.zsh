#!/bin/zsh

# Define paths
HOSTS_FILE="/etc/hosts"
BACKUP_DIR="/Users/data/Scripts/hosts"
BACKUP_FILE="$BACKUP_DIR/hosts.backup.$(date +%Y%m%d-%H%M%S)"
CUSTOM_HOSTS="/Users/data/Scripts/hosts/myhosts.txt"
TEMP_HOSTS="/private/tmp/hosts_downloaded"
FILTERED_HOSTS="/private/tmp/hosts_filtered"

# Online hosts list options
URL_UNIFIED="https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling-porn-social/hosts"
URL_NOHOX="https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling-social/hosts"

# List of social media platforms to exclude
EXCLUDE_PLATFORMS=("Whatsapp" "Instagram" "Reddit" "Pinterest")

# Function to send macOS notifications
notify() {
    osascript -e "display notification \"$1\" with title \"Hosts Updater\""
}

# Prompt user for which online list to download
echo "Choose the online hosts list to download:"
echo "1) Unified (fakenews + gambling + porn + social)"
echo "2) noHoX (fakenews + gambling + social)"
echo -n "Enter choice (1 or 2): "
read -r CHOICE


# Determine which URL to use
if [[ "$CHOICE" == "1" ]]; then
    ONLINE_HOSTS_URL="$URL_UNIFIED"
    LIST_NAME="Unified"
elif [[ "$CHOICE" == "2" ]]; then
    ONLINE_HOSTS_URL="$URL_NOHOX"
    LIST_NAME="noHoX"
else
    echo "❌ Invalid choice. Exiting."
    notify "❌ Error: Invalid choice. No update performed."
    # Display macOS notification
    osascript -e 'display notification "... No update performed." with title "❌ Error: Invalid choice"'
    exit 1
fi

echo "Downloading latest $LIST_NAME hosts file..."

# Backup current hosts file
echo "Backing up existing hosts file to $BACKUP_FILE..."
sudo cp "$HOSTS_FILE" "$BACKUP_FILE"

# Download the selected online hosts list
curl -fsSL --retry 5 --retry-delay 2 "$ONLINE_HOSTS_URL" -o "$TEMP_HOSTS"

# Check if the download was successful
if [[ ! -s "$TEMP_HOSTS" ]]; then
    notify "❌ Error: Failed to download $LIST_NAME hosts file."
    echo "❌ Error: Failed to download hosts file."
    # Display macOS notification
    osascript -e 'display notification "... Run Script Again" with title "❌ Error: Failed to download hosts file."'
    exit 1
fi

echo "Download complete. Processing file..."
sleep 1  # Short delay to ensure file operations work smoothly

# Create a copy for filtering
cp "$TEMP_HOSTS" "$FILTERED_HOSTS"

# Remove sections related to excluded platforms
for PLATFORM in "${EXCLUDE_PLATFORMS[@]}"; do
    echo "Removing entries for: $PLATFORM"
    sed -i.bak "/^# $PLATFORM/,/^#/d" "$FILTERED_HOSTS"
done

# Ensure filtered hosts file is not empty
if [[ ! -s "$FILTERED_HOSTS" ]]; then
    notify "❌ Error: Filtering failed. Hosts file may be empty!"
    echo "❌ Error: Filtering failed. Hosts file may be empty!"
    exit 1
fi

# Merge filtered hosts file with custom entries
echo "Merging custom hosts entries..."
cat "$FILTERED_HOSTS" "$CUSTOM_HOSTS" | sudo tee "$HOSTS_FILE" > /dev/null

# Flush DNS cache
echo "Flushing DNS cache..."
sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder

# ✅ If everything is successful, notify the user
notify "✅ Hosts file updated successfully with $LIST_NAME!"

# Keep only the last 3 backups, delete older ones
echo "Cleaning up old backups..."
BACKUP_FILES=($(ls -t $BACKUP_DIR/hosts.backup.* 2>/dev/null))
if [[ ${#BACKUP_FILES[@]} -gt 3 ]]; then
    for file in ${BACKUP_FILES[@]:3}; do
        echo "Deleting old backup: $file"
        sudo rm -f "$file"
    done
fi

echo "✅ Hosts file update completed using $LIST_NAME!"
# Display macOS notification
osascript -e 'display notification "✅ Hosts file update completed." with title "$LIST_NAME!"'