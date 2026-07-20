# Mac M4 Setup - Quick Start Guide

A condensed reference for setting up a new Mac M4 with Flutter development environment and synced dotfiles.

## 📊 Setup Overview

```
Step 1: Run main setup script (30-45 minutes)
  └─ ~/scripts/mac-m4-flutter-setup.sh

Step 2: Sync dotfiles configuration (2-5 minutes)
  └─ ~/mac-sync/mac-sync-dotfiles.sh

Step 3: Customize & enable autostart (5-10 minutes)
  └─ ~/mac-sync/startup-macos.sh + LaunchAgent setup
```

---

## ⚡ Quick Commands

### Initial Mac Setup
```bash
# Clone dotfiles repository
git clone https://github.com/s4pun1s7/.dotfiles.git ~/.dotfiles
cd ~/.dotfiles

# Run setup script (installs Flutter, tools, and configurations)
./scripts/mac-m4-flutter-setup.sh

# Restart terminal
exec zsh
```

### Sync Configurations
```bash
# Navigate to mac-sync
cd ~/.dotfiles/mac-sync

# Sync all configurations (vim, tmux, neovim, scripts)
./mac-sync-dotfiles.sh

# Or sync specific items
./mac-sync-dotfiles.sh --vim      # Vim only
./mac-sync-dotfiles.sh --tmux     # Tmux only
./mac-sync-dotfiles.sh --neovim   # Neovim only
```

### Enable Autostart (Optional)
```bash
# Setup autostart on login
cd ~/.dotfiles/mac-sync
sed -i '' 's/YOURNAME/'"$(whoami)"'/g' autostart-macos.plist
mkdir -p ~/Library/LaunchAgents
cp autostart-macos.plist ~/Library/LaunchAgents/com.user.autostart.plist
launchctl load ~/Library/LaunchAgents/com.user.autostart.plist
```

---

## ✅ What Gets Installed

### Development Environment
- ✅ Xcode Command Line Tools
- ✅ Homebrew (M-series optimized)
- ✅ Flutter SDK (stable branch)
- ✅ Java/OpenJDK 17 (Android development)
- ✅ git, curl, wget

### Development Tools
- ✅ tmux (terminal multiplexer)
- ✅ vim (text editor)
- ✅ ranger (file browser)
- ✅ mc (midnight commander)
- ✅ htop (process monitor)
- ✅ ripgrep, fzf, bat, exa

### Shell & Terminal
- ✅ oh-my-zsh (shell framework)
- ✅ zsh-syntax-highlighting (plugin)
- ✅ zsh-autosuggestions (plugin)

### Configurations
- ✅ .vimrc (Vim configuration)
- ✅ .tmux.conf (Tmux configuration)
- ✅ .config/nvim/init.vim (Neovim configuration - optional)
- ✅ Shell aliases and environment setup

---

## 🎯 Key Bindings After Setup

### Tmux (Prefix: Alt+Q)
```
Alt+Q h      - Split horizontally
Alt+Q v      - Split vertically
Alt+Q x      - Kill pane
Alt+Q n      - Next window
Alt+Q f      - Fullscreen pane
Alt+Q r      - Reload config

# Without prefix (for pane navigation)
Alt+H/J/K/L  - Navigate between panes
```

### Vim
```
:set number          - Show line numbers
:set relativenumber  - Show relative line numbers
:set mouse=a         - Enable mouse
Ctrl+V              - Block select
```

---

## 📁 Important Paths

```
Dotfiles:           ~/.dotfiles/
Setup Scripts:      ~/.dotfiles/scripts/
Sync Tools:         ~/.dotfiles/mac-sync/
Flutter:            ~/Development/flutter
Vim Config:         ~/.vimrc
Tmux Config:        ~/.tmux.conf
Neovim Config:      ~/.config/nvim/init.vim
Zsh Config:         ~/.zshrc
Setup Log:          ~/.mac-flutter-setup.log
Sync Log:           ~/.dotfiles-sync.log
Autostart Log:      ~/.config/autostart/startup.log
Backups:            ~/ (*.backup.TIMESTAMP)
```

---

## 🔧 Post-Setup Customization

### Add Custom Aliases
Edit `~/.zshrc` and add:
```bash
alias ll='ls -lah'
alias dev='cd ~/Development'
alias dot='cd ~/.dotfiles'
```

### Customize Tmux
Edit `~/.tmux.conf`:
```bash
# Change prefix key (currently Alt+Q)
set-option -g prefix C-a

# Change colors
set -g status-bg colour236
```

### Customize Vim
Edit `~/.vimrc`:
```vim
" Change colorscheme
colorscheme desert

" Add line at 80 characters
set cc=80
```

### Add Autostart Programs
Edit `~/.config/autostart/startup.sh`:
```bash
# Start an application
open ~/Applications/Dropbox.app

# Or start a command
npm start &
```

---

## 🐛 Quick Troubleshooting

### Flutter not found after setup
```bash
# Reload shell
source ~/.zshrc

# Or restart terminal
exec zsh

# Verify installation
flutter --version
```

### Tmux config not loading
```bash
# Reload configuration
tmux source ~/.tmux.conf

# Restart tmux
tmux kill-server
```

### Vim colors look wrong
```bash
# Ensure 256 color support
echo $TERM

# Should output: xterm-256color or screen-256color
# If not, add to ~/.zshrc:
export TERM=xterm-256color
```

### Autostart not running
```bash
# Check if loaded
launchctl list | grep com.user.autostart

# Check logs
cat /tmp/autostart.log
cat /tmp/autostart.err

# Reload if needed
launchctl unload ~/Library/LaunchAgents/com.user.autostart.plist
launchctl load ~/Library/LaunchAgents/com.user.autostart.plist
```

---

## 📋 Checklist for Complete Setup

- [ ] Clone dotfiles repository
- [ ] Run `mac-m4-flutter-setup.sh` (wait for completion)
- [ ] Restart terminal or run `exec zsh`
- [ ] Run `flutter doctor` and fix any issues
- [ ] Run `mac-sync-dotfiles.sh` from `mac-sync/`
- [ ] Reload tmux config with `tmux source ~/.tmux.conf`
- [ ] Test vim by running `vim ~/.vimrc`
- [ ] (Optional) Setup autostart with LaunchAgent
- [ ] (Optional) Customize shell aliases in `~/.zshrc`
- [ ] (Optional) Install additional tools as needed

---

## 📚 Detailed Documentation

For more information, see:
- **SYNC_CHECKLIST.md** - Complete checklist with all options
- **README.md** - Full documentation for mac-sync folder
- **../README.md** - Main dotfiles repository documentation

---

## 🆘 Getting Help

### Check Logs
```bash
# Setup script log
cat ~/.mac-flutter-setup.log

# Sync script log
cat ~/.dotfiles-sync.log

# Autostart log
cat ~/.config/autostart/startup.log
```

### Manual Verification
```bash
# Check Flutter installation
flutter --version
flutter doctor

# Check tools installation
tmux -V
vim --version
ranger --version

# Check shell configuration
echo $SHELL
cat ~/.zshrc | grep -E "^(alias|export)" | head -20
```

### Restore from Backup
```bash
# List backups
ls -lt ~/ | grep "\.backup\." | head -10

# Restore a specific file
cp ~/.vimrc.backup.1721475600 ~/.vimrc
```

---

**Time to Complete:** 45-60 minutes total  
**Disk Space Required:** 5+ GB free  
**Internet Required:** Yes (downloads ~2-3 GB)

For issues, refer to full documentation in SYNC_CHECKLIST.md or README.md
