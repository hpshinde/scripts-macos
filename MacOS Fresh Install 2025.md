# MacOS Fresh Install 2025

[![Pinned](https://img.shields.io/badge/pinned-true-lightpink)]()
[![Tags](https://img.shields.io/badge/tags-sw.mac.tip-blue)]()
[![Date](https://img.shields.io/badge/date-06--04--2025-green)]()

#sw.mac.tip

## Pre-Install Backups

- Scripts
- Ubersicht widgets located at: `~/Library/Application Support/Übersicht/widgets/`
- AutoCad PGP file `~/Library/Application Support/Autodesk/AutoCAD 2024/R24.3/roaming/@en@/Support/acadUser.pgp`
- SKP Plugins & Templates
- hosts file at: `/etc/hosts`
- ==🔴NOT YET UPDATED FOR SONOMA==: [mackup](https://github.com/lra/mackup) – Keep your application settings in sync (OS X/Linux)
  - Config: `[storage] engine = icloud`
  - In Terminal: `mackup backup`

## Apps to Install

On a fresh install, run:

```bash
softwareupdate --all --install --force
```

This will install any updates. Then:

```bash
sudo spctl --master-disable
```

### Essential Applications

- Little Snitch 4 [ 34R2ARNAE2-715M6-ZBP4R7KHJN ]

- Microsoft NTFS for Mac by Paragon Software 
  - S/n: N6I23T-1RDHKD-JATASK-GHCNAI-3834BH
  - GUID: 7520B38F-7C3F-5BED-928E-3C8EDE528C62
  - Alternative keys: kajqac-0nIpna-wapfeb or Pedxy8-vadzar-xohhix 
  - Account: thestox@yahoo.com
  - Download after login: [MyParagon](https://my.paragon-software.com)

- nvAlt (sync to simple note)

- Hosts File → [GasMask](https://github.com/2ndalpha/gasmask) - Hosts file manager for OS X
  - Gas Mask stores your custom hosts files in `~/Library/Gas Mask` directory

- Change DNS Server
  - Cloudflare DNS servers: `1.1.1.1`, `1.0.0.1`
  - Google DNS servers: `8.8.8.8` and `8.8.4.4`
  - OpenDNS servers: `208.67.222.222` and `208.67.220.220`
  - [NameBench](https://code.google.com/archive/p/namebench/downloads) — personalized DNS server recommendations based on your browsing history
  - `sudo discoveryutil udnsflushcaches`

### Homebrew

Install [Homebrew](https://brew.sh/)

```bash
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

This will also install Command Line Tools for Xcode

If that fails, then:

```bash
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```

#### Essential Homebrew Commands

`brew install exiftool terminal-notifier tag ffmpeg node`

`brew list`

`brew search <search term>` will list the possible packages that you can install. `brew search post` will return multiple packages that are available to install that have post in their name.

`brew info <package name>` will display some basic information about the package in question

#### Recommended Brew Cask Apps

```bash
brew install hazel \
  pearcleaner \
  swiftbar \
  photostickies \
  google-drive \
  hammerspoon \
  karabiner-elements \
  fluor \
  keka \
  flowvision \
  skim \
  sublime-text \
  p7zip \
  transmission \
  easyfind \
  zotero
```

**Note**: For Hammerspoon, "InfoOffice" font is required. Otherwise, replace the font-name in spoon.

### Optional Homebrew Packages

```bash
brew install pandoc pandoc-citeproc wget imagemagick
brew install wifi-password  # More useful on laptop. To get the password for the WiFi you're currently logged onto: just type: wifi-password in terminal.
```

### Homebrew Maintenance Commands

- `brew list` (Shows all of your installed packages)
- `brew search [package]` (Lists all available formulae)
- `brew upgrade --cask` (Update casks)
- `brewup` (Custom alias for update/upgrade)

#### Quick Look Plugins (Most are now incompatible with Sonoma. Please verify online prior to installing them)

```bash
brew install --cask qlcolorcode qlstephen qlImageSize qlvideo qlmarkdown quicklook-json qlprettypatch quicklook-pfm quicklook-csv quicklook-pat webpquicklook suspicious-package
```

#### Markdown Editors

`brew install --cask zettlr` Or, Typora

#### Additional Tools

- [Rclick](https://github.com/wflixu/RClick)

### Git and GitHub Configuration

To install: `brew install git`

When done, to test that it installed properly:

```bash
git --version
which git  # Should output /usr/local/bin/git
```

Next, define your Git user (should be the same name and email you use for [GitHub](https://github.com/)):

```bash
git config --global user.name "hpshinde"
git config --global user.email "hshinde@gmx.com"
```

They will get added to your `.gitconfig` file.

To cache your credentials:

```bash
git config --global credential.helper osxkeychain
```

#### GitHub Tips

**To refresh a git folder from Mac**:

```bash
git add . && git commit -m "Add existing file" && git push origin master
```

**Remove files from GitHub folder**:

```bash
git checkout master && git rm -r . && git commit -m "Remove duplicated directory" && git push origin master
```

**Refresh offline copy from GitHub repo**:

```bash
git pull && git fetch && git status
```

## Additional Applications

### Window Management

- Magnet Pro or alternatives:
  - [Spectacle](https://github.com/eczarny/spectacle)
  - Amethyst: `brew install --cask amethyst`
  - BTT

### Utilities

- TagSpaces
- Image Viewers: 
  - [FlowVision](https://github.com/netdcy/FlowVision): `brew install flowvision`
  - Phoenix Slides

- [Music Decoy](https://lowtechguys.com/musicdecoy/) - Stop launching the Music app when pressing ▶ Play
  
  Configure to launch another app:
  ```bash
  defaults write com.apple.MusicDecoy mediaAppPath /Applications/Spotify.app
  ```
  
  Reset configuration:
  ```bash
  defaults delete com.apple.MusicDecoy mediaAppPath
  ```

- [Startup Folder](https://lowtechguys.com/startupfolder/) - Run anything at startup
- Hazel
- Onyx
- BreakTimer (FOSS): `brew install breaktimer`
- [PhotoStickies](https://www.devontechnologies.com/apps/freeware) (*Must-have*)
- [EasyFind](https://www.devontechnologies.com/apps/freeware)

### Mac App Store

- Palua or [Fluor](https://fluorapp.net/)
- iThoughtsX
- Popclip
- Yoink
- Duplicate Photos Finder
- Toolbox Pro & Actions
- [Web(cache)Browser](https://apps.apple.com/in/app/web-cache-browser/id432802024)

### Safari Extensions

- Ghostery
- SafariMarkdownLinker
- **1Blocker**
- **Hush**

### Additional Software

- [noTunes](https://discussions.apple.com/thread/255144771) - Prevent iTunes/Apple Music from launching
- [Ice](https://github.com/jordanbaird/Ice) - Powerful menu bar manager like Bartender
- [BetterTouchTool](https://folivora.ai/)
  - **IMPORTANT**: Before installing any preset, export your current settings via "Manage Presets"
- Amazon Music
- DEVONthink Pro
  - If "damaged" error: `xattr -d com.apple.quarantine /path/to/app.app`
- Drafts or iA Writer
- AutoCAD
- SketchUp
- Lulu Firewall
- Chrome extension: [Turbo Downloader for Instagram](https://chromewebstore.google.com/detail/turbo-downloader-for-inst/cpgaheeihidjmolbakklolchdplenjai) (Works in Opera)

## Text Editors

- [Notenik](https://apps.apple.com/in/app/notenik/id1465997984)
- [CotEditor](https://coteditor.com/)
- Visual Studio Code
  - [Guide: Build an amazing Markdown editor](https://thisdavej.com/build-an-amazing-markdown-editor-using-visual-studio-code-and-pandoc/)
  - Recommended VS Code Extensions:
    - [Settings Sync](https://marketplace.visualstudio.com/items?itemName=Shan.code-settings-sync)
    - [Bracket Pair Colorizer](https://marketplace.visualstudio.com/items?itemName=CoenraadS.bracket-pair-colorizer)
    - [Auto Close Tag](https://marketplace.visualstudio.com/items?itemName=formulahendry.auto-close-tag)
    - [Markdown All in One](https://marketplace.visualstudio.com/items?itemName=yzhang.markdown-all-in-one)
    - [Markdown Helper](https://marketplace.visualstudio.com/items?itemName=joshbax.mdhelper)
    - [markdownlint](https://marketplace.visualstudio.com/items?itemName=DavidAnson.vscode-markdownlint)
    - [Pandoc](https://marketplace.visualstudio.com/items?itemName=DougFinke.vscode-pandoc)
    - [Markdown Paste Image](https://marketplace.visualstudio.com/items?itemName=telesoho.vscode-markdown-paste-image)
    - [Markdown Table Prettify](https://marketplace.visualstudio.com/items?itemName=darkriszty.markdown-table-prettify)
    - [Markdown Navigation](https://marketplace.visualstudio.com/items?itemName=AlanWalk.markdown-navigation)
    - [Markdown Shortcuts](https://marketplace.visualstudio.com/items?itemName=mdickin.markdown-shortcuts)
    - [Hemingway Markdown](https://marketplace.visualstudio.com/items?itemName=hemingway-md.hemingway-md)
    - [VSNotes](https://marketplace.visualstudio.com/items?itemName=patricklee.vsnotes)
    - [Unotes](https://marketplace.visualstudio.com/items?itemName=ryanmcalister.Unotes)
  - [OpenInCode](https://github.com/sozercan/OpenInCode)

## Command Line Tools Update

```bash
softwareupdate --all --install --force
```

If that doesn't show updates:

```bash
sudo rm -rf /Library/Developer/CommandLineTools
sudo xcode-select --install
```

## Optional Apps

- Alt for Spotlight: [Flashlight](http://flashlight.nateparrott.com/)
- [Quickwords](https://quickwords.co/) - Open-source alternative to Text Expander
- [Dupe Guru](https://dupeguru.voltaicideas.net): `brew install dupeguru`
- [Manta](https://www.getmanta.app) - Flexible invoicing desktop app
- Sindre Sorhus Apps:
  - [Shareful](https://sindresorhus.com/shareful)
  - [Folder Peek](https://sindresorhus.com/folder-peek)
  - [Command X](https://sindresorhus.com/command-x)
- [HuggingChat macOS](https://github.com/huggingface/chat-macOS) - AI conversation for desktop
- [1Piece](https://app1piece.com) - Multifunctional App for Mac


## Optional: Terminal Configuration

Edit `~/.bash_profile` or `~/.zshrc`:

```bash
nano ~/.bash_profile
```

Append these lines:

```bash
alias ls='ls -GFh'
alias showall='defaults write com.apple.finder AppleShowAllFiles YES; killall Finder'
alias hideall='defaults write com.apple.finder AppleShowAllFiles NO; killall Finder'
alias cleanup='sudo periodic daily weekly monthly'
alias brewup='brew update; brew upgrade; brew upgrade --cask; brew cleanup -s; brew doctor'
alias exiftool='/usr/local/bin/exiftool'
alias shutdownnow='sudo shutdown -r now'
export LC_ALL=en_US.UTF-8
```

Save & Exit, then do:

```bash
source .zshrc
```

## Optional: Configure bash_profile (This is OLD)

```bash
sudo nano ~/.bash_profile
```

Add this content:

```bash
export PATH="/usr/local/sbin:$PATH"
export PATH=/usr/local/sbin:/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin
[ -f /usr/local/etc/bash_completion ] && . /usr/local/etc/bash_completion
export PS1="\[\033[36m\]\u\[\033[m\]@\[\033[32m\]\h:\[\033[33;1m\]\w\[\033[m\]\$ "
export CLICOLOR=1
export LSCOLORS=ExFxBxDxCxegedabagacad
alias ls='ls -GFh'
alias showfiles='defaults write com.apple.finder AppleShowAllFiles YES; killall Finder'
alias hidefiles='defaults write com.apple.finder AppleShowAllFiles NO; killall Finder'
alias cleanup='sudo periodic daily weekly monthly'
alias brewup='brew update; brew upgrade; brew cleanup; brew doctor; brew upgrade --cask'
alias exiftool='/usr/local/bin/exiftool'
alias shutdownnow='sudo shutdown -r now'
export LC_ALL=en_US.UTF-8
export PATH="/usr/local/opt/python@3.8/bin:$PATH"
export NVM_DIR="/Volumes/Data/.nvm"
[ -s "$NVM_DIR/nvm.sh" ] && . "$NVM_DIR/nvm.sh"  # This loads nvm
```

Save & Exit, then do:

```bash
source .bash_profile
```
