# How to set up hosts file daily script execution at a preset time (say, 8:30PM) using launchd on your macOS system

1. Create Your Script
2. Make the script executable: `chmod +x daily_script.sh`
3. Create a Launch Agent Plist File: Create a new file named `com.yourname.daily_script.plist` (replace yourname with a unique identifier) in a text editor. See attached .plist file for example, or use it as-is. [launchd_plists.zip](launchd_plists.zip)<!-- {"embed":"true"} -->
4. Move the plist file to the `~/Library/LaunchAgents` directory:
   1. `mkdir ~/Library/LaunchAgents`
   2. `mv com.yourname.daily_script.plist ~/Library/LaunchAgents/`
5. Verify the Launch Agent is loaded: `launchctl unload ~/Library/LaunchAgents/com.user.hox_hosts.plist`
6. Restart the mac
