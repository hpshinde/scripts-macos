# Essential Scripts for MacOS (Sonoma+):

## Cleanup Script: Either Run Independantly, or With SwiftBar 

To make your cleanup script work without password prompts, you'll need to add a specific entry to your sudoers file. This will allow the script to execute sudo commands without requiring a password.
Here's what you need to add to your sudoers file:
`username ALL=(ALL) NOPASSWD: /bin/rm, /usr/sbin/periodic`
Replace username with your actual macOS username (the same one that appears in your path `/Users/data/` - so likely `data`).
To safely edit the sudoers file:
1. Open Terminal
2. Run sudo visudo (this opens the sudoers file in a safe editor)
3. Navigate to the end of the file
4. Press `i` to enter Insert mode, and Add the line above (with your username)
5. Save and exit (in vi/vim, press `ESC`, then type `:wq` and press Enter)
⠀This configuration grants your user the ability to run the specific commands used in your script (rm and periodic) without a password prompt. It's more secure than giving blanket sudo access because it limits the commands that can be run without a password.
If your script uses any other commands with sudo, you should add those to the NOPASSWD line as well.

**Note:** For cleanup to work, upgrade bash to ver. 5+ ... See: [How To Upgrade your Bash Version on Mac OS?](https://www.shell-tips.com/mac/upgrade-bash/#gsc.tab=0)

## Cleanup and Eject Script for USB Drives - Use with Caution

Steps to Create the Finder Quick Action

1. Open Automator (Cmd + Space, type Automator, hit Enter).
2. Choose "Quick Action" as the document type.
3. Set "Workflow receives current" to Files or Folders.
4. Set "in" to Finder.
5. Drag "Run Shell Script" from the actions panel into the workflow.
6. Set:
   1. Shell: /bin/zsh
   2. Pass input: as arguments
7. Replace default script with the `usb-cleanup-script.txt`
8. Save the workflow as "USB Cleanup & Eject".
9. Go to System Settings → Privacy & Security → Full Disk Access, then add Automator and Finder. Navigate to and select both:
   * /System/Library/CoreServices/Finder.app
   * /Applications/Automator.app
10. Try it: Right-click a USB drive → Quick Actions → USB Cleanup & Eject.

### Settings: Security Permissions
- Full Disk Access to bash. (Be careful!! First try giving FDA to Terminal, instead)
- To get location of bash and fswatch, in terminal do: `which bash` and `which fswatch`.
