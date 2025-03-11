#!/bin/bash

# Define paths
HOSTS_FILE="/etc/hosts"
BACKUP_FILE="/Users/data/Scripts/hosts/backups/hosts.backup.$(date +%Y%m%d-%H%M%S)"
CUSTOM_HOSTS="/Users/data/Scripts/hosts/myhosts.txt"
ONLINE_HOSTS_URL="https://raw.githubusercontent.com/StevenBlack/hosts/master/alternates/fakenews-gambling-porn-social/hosts"
TEMP_HOSTS="/private/tmp/hosts_downloaded"
FILTERED_HOSTS="/private/tmp/hosts_filtered"
LIST_NAME="FGPS Universal"

# List of social media platforms to exclude
EXCLUDE_PLATFORMS=("Whatsapp" "Instagram" "Reddit" "Pinterest")

# Backup current hosts file
echo "Backing up existing hosts file to $BACKUP_FILE..."
sudo cp "$HOSTS_FILE" "$BACKUP_FILE"

# Download the latest online hosts list (with error handling)
echo "Downloading latest hosts file..."
curl -fsSL --retry 5 --retry-delay 2 "$ONLINE_HOSTS_URL" -o "$TEMP_HOSTS"

# Check if the download was successful
if [[ ! -s "$TEMP_HOSTS" ]]; then
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
  echo "❌ Error: Filtering failed. Hosts file may be empty!"
  # Display macOS notification
  osascript -e 'display notification "... Hosts file may be empty!" with title "❌ Error: Filtering failed"'
  exit 1
fi

# Merge filtered hosts file with custom entries
echo "Merging custom hosts entries..."
cat "$FILTERED_HOSTS" "$CUSTOM_HOSTS" | sudo tee "$HOSTS_FILE" > /dev/null

# Flush DNS cache
echo "Flushing DNS cache..."
sudo dscacheutil -flushcache && sudo killall -HUP mDNSResponder

echo "✅ Hosts file update completed using $LIST_NAME!"
# Display macOS notification
osascript -e 'display notification "... using FGPS Universal" with title "✅ Hosts file Updated"'