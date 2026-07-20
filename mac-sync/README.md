# Mac M4 Dotfiles Sync

This folder contains tools and configurations for synchronizing dotfiles to a new Mac M4 installation after running the main `mac-m4-flutter-setup.sh` script.

## 📁 Contents

### Configuration Files
- **SYNC_CHECKLIST.md** - Comprehensive checklist of all syncable items and their status
- **bat-macos.sh** - macOS version of battery status script for tmux
- **autostart-macos.plist** - LaunchD configuration template for autostart on login
- **startup-macos.sh** - User startup script for running autostart tasks
- **mac-sync-dotfiles.sh** - Automated sync script to deploy all configurations

### Source Configurations (from parent directory)
- **../.vimrc** - Vim editor configuration
- **../.tmux/.tmux.conf** - Tmux terminal multiplexer configuration
- **../.config/nvim/init.vim** - Neovim configuration

## 🚀 Quick Start

### 1. Initial System Setup
First, run the main setup script on a fresh Mac M4:

```bash
cd ~/.dotfiles
./scripts/mac-m4-flutter-setup.sh
```

This will install:
- Xcode Command Line Tools
- Homebrew
- Flutter SDK
- Development tools (tmux, vim, ranger, mc, htop, etc.)
- oh-my-zsh with plugins

### 2. Sync Dotfiles Configuration
After the initial setup, sync your preferred configurations:

```bash
cd ~/.dotfiles/mac-sync
chmod +x mac-sync-dotfiles.sh
./mac-sync-dotfiles.sh
```

#### Available Options
```bash
# Sync all configurations
./mac-sync-dotfiles.sh --all

# Sync specific configurations
./mac-sync-dotfiles.sh --vim      # Vim only
./mac-sync-dotfiles.sh --tmux     # Tmux only
./mac-sync-dotfiles.sh --neovim   # Neovim only
./mac-sync-dotfiles.sh --scripts  # Scripts only

# Show what's available
./mac-sync-dotfiles.sh --summary
```

### 3. Enable Autostart (Optional)
To run startup tasks on login:

```bash
# Edit the plist to use your username
sed -i '' 's/YOURNAME/'"$(whoami)"'/g' autostart-macos.plist

# Install LaunchAgent
mkdir -p ~/Library/LaunchAgents
cp autostart-macos.plist ~/Library/LaunchAgents/com.user.autostart.plist
chmod 644 ~/Library/LaunchAgents/com.user.autostart.plist

# Load and enable
launchctl load ~/Library/LaunchAgents/com.user.autostart.plist
```

## 📋 Synced Configurations

### Vim Configuration
**Source:** `../.vimrc`  
**Target:** `~/.vimrc`

Features:
- Line numbers and relative line numbers
- Syntax highlighting
- Mouse support
- System clipboard integration
- Tab configuration (4 spaces)
- Search highlighting

Usage:
```bash
vim ~/.vimrc  # Edit after syncing
```

### Tmux Configuration
**Source:** `../.tmux/.tmux.conf`  
**Target:** `~/.tmux.conf`

Key bindings:
- **Prefix:** `Alt+Q` (M-q)
- **Horizontal split:** `h`
- **Vertical split:** `v`
- **Kill pane:** `x`
- **Next window:** `n`
- **Fullscreen:** `f`
- **Pane resize:** `M-k/j/h/l`
- **Pane navigation:** `M-k/j/h/l`

Usage:
```bash
# Reload after changes
tmux source ~/.tmux.conf

# List key bindings
tmux list-keys
```

### Neovim Configuration
**Source:** `../.config/nvim/init.vim`  
**Target:** `~/.config/nvim/init.vim`

This configuration sources the main .vimrc for consistency.

Installation (if needed):
```bash
brew install neovim
```

## 🔧 Custom Scripts

### Battery Status Script (bat-macos.sh)
Displays battery percentage and charging status for tmux status bar.

**Deployment:**
```bash
# Already deployed by sync script to ~/.tmux/bat-macos.sh
# Edit .tmux.conf to use it:
# set -g status-right '... #(~/.tmux/bat-macos.sh) ...'
```

**Status indicators:**
- `⚡` - Charging
- `🟢` - Good battery (>50%)
- `🟡` - Medium battery (20-50%)
- `🔴` - Low battery (<20%)

### Autostart Script (startup-macos.sh)
User startup script for running commands on login.

**Features:**
- Homebrew PATH setup
- Example: tmux session creation
- Example: Application autostart
- Custom command templates

**Customization:**
```bash
# Edit the script to add your autostart commands
nano ~/.config/autostart/startup.sh
```

**Example additions:**
```bash
# Start Dropbox
open ~/Applications/Dropbox.app

# Start development server
cd ~/Development/myapp
npm start > /tmp/myapp.log 2>&1 &

# Create tmux session
tmux new-session -d -s work
```

## 📝 Configuration Management

### Backup Strategy
The sync script automatically creates timestamped backups:
- Original file: `~/.vimrc`
- Backup: `~/.vimrc.backup.1721475600`

To restore a backup:
```bash
cp ~/.vimrc.backup.1721475600 ~/.vimrc
```

### Modification Workflow
1. Make changes to source files in `~/.dotfiles/`
2. Commit changes to git
3. Re-run sync script on other machines
4. Use backups if rollback is needed

### Tracking Changes
```bash
# See what sync script will do
./mac-sync-dotfiles.sh --summary

# Check backup files
ls -la ~/ | grep "\.backup\."

# Review sync log
cat ~/.dotfiles-sync.log
```

## 🔗 Integration Points

### With mac-m4-flutter-setup.sh
- Setup script installs basic vim and tmux configurations
- Sync script overrides with your preferred versions
- Both scripts maintain backup strategy

### With oh-my-zsh
- Sync script works alongside oh-my-zsh setup
- Shell profile (.zshrc) managed by oh-my-zsh
- Custom .zshrc template available in parent directory

### With Development Tools
- Vim: Full editing support for code
- Tmux: Terminal management for development
- Neovim: Modern vim alternative for advanced use

## 🐛 Troubleshooting

### Issue: Script fails with permission denied
```bash
chmod +x mac-sync-dotfiles.sh
./mac-sync-dotfiles.sh
```

### Issue: Configurations not loading
```bash
# Reload shell
source ~/.zshrc

# Reload tmux
tmux source ~/.tmux.conf

# Restart vim/neovim
```

### Issue: Backup files accumulating
```bash
# Clean old backups (keep recent 3)
ls -t ~/ | grep "\.backup\." | tail -n +4 | xargs rm -f
```

### Issue: LaunchAgent not working
```bash
# Check if loaded
launchctl list | grep com.user.autostart

# Check for errors
cat /tmp/autostart.err

# Reload if needed
launchctl unload ~/Library/LaunchAgents/com.user.autostart.plist
launchctl load ~/Library/LaunchAgents/com.user.autostart.plist
```

## 📚 Related Documentation

- **SYNC_CHECKLIST.md** - Detailed status of all configurations
- **../README.md** - Main dotfiles repository documentation
- **../scripts/mac-m4-flutter-setup.sh** - Initial Mac setup script

## 🤖 Automation Examples

### Sync on First Login
```bash
# Add to ~/.config/autostart/startup.sh
if [[ ! -f ~/.synced ]]; then
    ~/.dotfiles/mac-sync/mac-sync-dotfiles.sh --all
    touch ~/.synced
fi
```

### Keep Dotfiles Updated
```bash
# Add to ~/.config/autostart/startup.sh
cd ~/.dotfiles && git pull origin master
```

### Periodic Backup
```bash
# Add to crontab (edit with: crontab -e)
0 3 * * *  cp -r ~/.dotfiles ~/Backups/dotfiles-$(date +\%Y\%m\%d)
```

## 📞 Support & Customization

### Extending for Your Needs
1. Add new configuration files to mac-sync/
2. Update SYNC_CHECKLIST.md with new items
3. Add deployment logic to mac-sync-dotfiles.sh
4. Test thoroughly before committing

### Common Customizations
- **Color schemes:** Edit .vimrc colorscheme line
- **Keybindings:** Update .tmux.conf bindings
- **Aliases:** Add to ~/.config/autostart/startup.sh
- **Plugins:** Install via vim/neovim plugin managers

---

**Last Updated:** July 2026  
**Compatible with:** macOS Monterey or later on Apple Silicon (M1/M2/M3/M4)
