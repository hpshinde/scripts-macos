# Backing Up Custom LaunchAgents and LaunchDaemons

## 1️⃣ Identify Your Custom Plists
The two main locations for user and system-wide launchd services are:

- User LaunchAgents (For per-user jobs, no sudo required)
  `~/Library/LaunchAgents/`
- System-wide LaunchAgents (Affect all users, require sudo)
  `/Library/LaunchAgents/`
- System-wide LaunchDaemons (Background services, require sudo)
  `/Library/LaunchDaemons/`

To list only the .plist files you added, use:
```
ls -l ~/Library/LaunchAgents/
ls -l /Library/LaunchAgents/
ls -l /Library/LaunchDaemons/
```
---
## 2️⃣ Create a Backup Folder
To store your backups:
`mkdir -p ~/Backups/launchdplists`
---
## 3️⃣ Copy Plists to Backup Folder
Copy only the files you added (to avoid system defaults):

```
cp ~/Library/LaunchAgents/.plist ~/Backups/launchdplists/
sudo cp /Library/LaunchAgents/.plist ~/Backups/launchdplists/
sudo cp /Library/LaunchDaemons/.plist ~/Backups/launchdplists/
```
---
## 4️⃣ Backup with Timestamps
To create a versioned backup:
```
TIMESTAMP=$(date +%Y%m%d-%H%M%S)
mkdir -p ~/Backups/launchdplists$TIMESTAMP
cp ~/Library/LaunchAgents/.plist ~/Backups/launchdplists$TIMESTAMP/
sudo cp /Library/LaunchAgents/.plist ~/Backups/launchdplists$TIMESTAMP/
sudo cp /Library/LaunchDaemons/.plist ~/Backups/launchdplists$TIMESTAMP/
```
---
## 5️⃣ Automate the Backup (Optional)
To schedule automatic backups using launchd, create a new plist file in `~/Library/LaunchAgents/` (e.g., `com.user.launchdbackup.plist`) with the following content:
```
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>Label</key>
    <string>com.user.launchdbackup</string>
    <key>ProgramArguments</key>
    <array>
        <string>/Users/data/Scripts/backup_launchd.sh</string>
    </array>
    <key>StartCalendarInterval</key>
    <dict>
        <key>Hour</key>
        <integer>3</integer>
        <key>Minute</key>
        <integer>0</integer>
    </dict>
    <key>RunAtLoad</key>
    <true/>
</dict>
</plist>

```

Then load it:
`launchctl load ~/Library/LaunchAgents/com.user.launchdbackup.plist`
---
## 6️⃣ Verify Backups
Check if the files exist in your backup folder:

`ls -l ~/Backups/launchdplists/`
---

