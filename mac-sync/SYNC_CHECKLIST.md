# Mac M4 Setup Sync Checklist

This checklist tracks configuration files and tools from the dotfiles repository that can be synced to a new Mac M4 installation using the `mac-m4-flutter-setup.sh` script.

## ✅ Ready to Sync - Configuration Files

### Editor Configurations
- [x] **.vimrc** (Main Vim configuration)
  - Location: `../.vimrc`
  - Target: `~/.vimrc`
  - Status: Already installed by setup script
  - Features: Line numbers, relative numbers, syntax highlighting, mouse support, clipboard integration
  - Action: Deploy as-is

- [x] **.config/nvim/init.vim** (Neovim configuration)
  - Location: `../.config/nvim/init.vim`
  - Target: `~/.config/nvim/init.vim`
  - Status: Sources .vimrc, compatible with Mac
  - Action: Deploy as-is (requires neovim installation)

### Terminal Configurations
- [x] **.tmux/.tmux.conf** (Tmux configuration)
  - Location: `../.tmux/.tmux.conf`
  - Target: `~/.tmux.conf`
  - Status: Installed by setup script
  - Features: Custom keybindings (M-q prefix), pane navigation, split controls, status bar
  - Action: Deploy as-is

### Shell Configurations
- [ ] **.zshrc** (Zsh shell configuration)
  - Location: NOT PRESENT IN REPO
  - Target: `~/.zshrc`
  - Status: Created by oh-my-zsh during setup
  - Recommendation: Create template for post-setup customization
  - Action: Create template with common aliases and functions

- [ ] **.oh-my-zsh/custom/** (oh-my-zsh customizations)
  - Location: NOT PRESENT IN REPO
  - Target: `~/.oh-my-zsh/custom/`
  - Status: Plugins installed by setup script
  - Action: Document installed plugins, create custom theme/alias files as needed

---

## 🔧 Utilities & Scripts

### Available Scripts
- [x] **bat.sh** (Battery status display)
  - Location: `../scripts/bat.sh`
  - Purpose: Display battery info for tmux status bar
  - Status: Works on Mac (uses acpi, may need adjustment for macOS)
  - Action: Create macOS version using `pmset` and `ioreg`

- [x] **autostart.sh** (Autostart configuration)
  - Location: `../scripts/autostart.sh`
  - Purpose: Auto-start applications
  - Status: Linux-specific (systemd-based)
  - Action: Create macOS equivalent using launchd

- [x] **install.sh** (Linux installation script)
  - Location: `../scripts/install.sh`
  - Purpose: Linux dotfiles installation (dwm, st, slstatus)
  - Status: Linux-specific (apt-based)
  - Action: Reference only, Mac setup is separate

---

## 🎯 Submodules (Not Directly Applicable to Mac)

### Suckless Tools (Linux-specific)
- ❌ **dwm** (Dynamic Window Manager)
  - Status: X11-based, not available on macOS
  - Alternative: Consider Yabai or other macOS window managers

- ❌ **st** (Simple Terminal)
  - Status: X11-based, not available on macOS
  - Alternative: Use native macOS terminal or iTerm2

- ❌ **slstatus** (Status bar utility)
  - Status: X11-based, not available on macOS
  - Alternative: Use macOS system menu bar applications

---

## 📋 Sync Implementation Plan

### Phase 1: Core Configuration Sync (Done in setup script)
- [x] Deploy .vimrc to ~/.vimrc
- [x] Deploy .tmux/.tmux.conf to ~/.tmux.conf
- [x] Create basic vim config during setup
- [ ] Add option to sync .config/nvim/init.vim if neovim is installed

### Phase 2: Shell Enhancement (Post-setup)
- [ ] Create .zshrc template with custom aliases and functions
- [ ] Document oh-my-zsh plugin configuration
- [ ] Add function library for common tasks
- [ ] Create environment setup for development tools

### Phase 3: Utility Scripts (macOS Versions Needed)
- [ ] Create macOS version of bat.sh using pmset
- [ ] Create macOS launchd configuration for autostart
- [ ] Create utility scripts for common Mac development tasks
- [ ] Add tmux integration scripts

### Phase 4: Documentation & Automation
- [ ] Create sync automation script (mac-sync-dotfiles.sh)
- [ ] Document all synced configurations
- [ ] Create customization templates
- [ ] Add setup verification checklist

---

## 🚀 Usage After Installation

### Manual Sync
```bash
# Sync vim configuration
cp .vimrc ~/.vimrc

# Sync tmux configuration
cp .tmux/.tmux.conf ~/.tmux.conf

# Sync neovim configuration
mkdir -p ~/.config/nvim
cp .config/nvim/init.vim ~/.config/nvim/init.vim
```

### Automated Sync (To Be Created)
```bash
./scripts/mac-sync-dotfiles.sh
```

---

## 📝 Notes & Recommendations

### Compatibility Considerations
1. **bat.sh** - Uses `acpi` (Linux). Create macOS version using:
   - `pmset -g batt` for battery info
   - `ioreg -r -k DesiredBrightness` for brightness

2. **autostart.sh** - Uses systemd (Linux). Use macOS launchd with:
   - `~/Library/LaunchAgents/` for user-specific launches
   - `~/Library/LaunchDaemons/` for system-wide launches

3. **Terminal Integration** - Consider creating:
   - iTerm2 profiles
   - Terminal.app profiles
   - Shell initialization scripts

### Future Enhancements
- [ ] Create color scheme manager for vim/tmux consistency
- [ ] Add font configuration management
- [ ] Create keybinding documentation for cross-tool usage
- [ ] Develop plugin synchronization for vim/neovim
- [ ] Create backup and restore utilities

### Security Considerations
- No sensitive data should be stored in dotfiles
- Ensure scripts have proper permissions
- Review all synced configurations before deployment
- Keep backup of existing configurations

---

## 📊 Status Summary

| Category | Total | Ready | Pending | N/A |
|----------|-------|-------|---------|-----|
| Config Files | 3 | 3 | 0 | 0 |
| Scripts | 3 | 1 | 2 | 0 |
| Submodules | 3 | 0 | 0 | 3 |
| **TOTAL** | **9** | **4** | **2** | **3** |

