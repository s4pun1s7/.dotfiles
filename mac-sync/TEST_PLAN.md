# Mac M4 Setup - Comprehensive Testing Plan

## Pre-Test Checklist

### System Requirements
- [ ] Mac M4 (or compatible Apple Silicon)
- [ ] macOS Monterey or later
- [ ] 5+ GB free disk space
- [ ] Internet connection
- [ ] Admin access (for sudo)
- [ ] Terminal/iTerm2 access

### Backup Before Testing
```bash
# Backup existing configs
cp ~/.vimrc ~/.vimrc.backup 2>/dev/null || true
cp ~/.tmux.conf ~/.tmux.conf.backup 2>/dev/null || true
cp ~/.zshrc ~/.zshrc.backup 2>/dev/null || true
cp -r ~/.oh-my-zsh ~/.oh-my-zsh.backup 2>/dev/null || true
```

---

## Test 1: Pre-Flight System Checks

### Objective
Verify the system is ready for installation

### Test Steps
```bash
# 1. Check macOS version
sw_vers
# Expected: macOS 12+ (Monterey or later)

# 2. Check M-series chip
uname -m
# Expected: arm64

# 3. Check free disk space
df -h / | awk 'NR==2 {print $4}'
# Expected: 5+ GB

# 4. Check internet connectivity
ping -c 1 8.8.8.8
# Expected: Successful ping response

# 5. Check curl availability
curl --version | head -1
# Expected: curl 7.x or higher

# 6. Check bash version
bash --version | head -1
# Expected: bash 5.0 or higher
```

### Expected Results
- ✅ macOS Monterey 12+
- ✅ arm64 (M-series)
- ✅ 5+ GB free space
- ✅ Internet working
- ✅ curl available
- ✅ bash 5.0+

---

## Test 2: Script Syntax Validation

### Objective
Ensure scripts have valid bash syntax

### Test Steps
```bash
# Test minimal setup script
bash -n ~/path/to/scripts/mac-m4-flutter-setup-minimal.sh
echo "Setup script: $?"

# Test minimal sync script
bash -n ~/path/to/mac-sync/mac-sync-dotfiles-minimal.sh
echo "Sync script: $?"

# Test original setup script
bash -n ~/path/to/scripts/mac-m4-flutter-setup.sh
echo "Original setup: $?"

# Test original sync script
bash -n ~/path/to/mac-sync/mac-sync-dotfiles.sh
echo "Original sync: $?"
```

### Expected Results
- ✅ Exit code 0 for all scripts
- ✅ No syntax errors
- ✅ No undefined variables

---

## Test 3: Minimal Setup Script - Dry Run

### Objective
Test the minimal setup script in a safe manner

### Test Steps
```bash
# Make script executable
chmod +x ~/path/to/scripts/mac-m4-flutter-setup-minimal.sh

# Run with debug output
bash -x ~/path/to/scripts/mac-m4-flutter-setup-minimal.sh 2>&1 | head -50

# Or run directly (this will INSTALL packages)
~/path/to/scripts/mac-m4-flutter-setup-minimal.sh
```

### What Gets Installed (Real Install)
1. Xcode CLI Tools (if needed)
2. Homebrew
3. Java/OpenJDK 17
4. Flutter SDK (stable)
5. Development tools: git, curl, tmux, vim, ranger, mc, htop, ripgrep, fzf, bat, exa
6. oh-my-zsh with plugins

### Expected Results
- ✅ Xcode installed or already present
- ✅ Homebrew operational
- ✅ All tools available: `which flutter`, `which tmux`, etc.
- ✅ Log file created: `~/.mac-flutter-setup.log`
- ✅ No errors in log

### Verification After Installation
```bash
# Check each tool
flutter --version
java -version
tmux -V
vim --version
ranger --version
mc --version
htop --version
rg --version
fzf --version
bat --version
exa --version

# Check shell
echo $SHELL
# Expected: /bin/zsh

# Check oh-my-zsh
ls -la ~/.oh-my-zsh/custom/plugins/
# Expected: zsh-autosuggestions, zsh-syntax-highlighting

# Check log
cat ~/.mac-flutter-setup.log | tail -20
```

---

## Test 4: Minimal Sync Script - Dry Run

### Objective
Test configuration synchronization

### Test Steps
```bash
# Make script executable
chmod +x ~/path/to/mac-sync/mac-sync-dotfiles-minimal.sh

# Run sync from dotfiles directory
cd ~/.dotfiles
~/path/to/mac-sync/mac-sync-dotfiles-minimal.sh
```

### Expected Results
- ✅ Vim config deployed: `~/.vimrc`
- ✅ Tmux config deployed: `~/.tmux.conf`
- ✅ Neovim config deployed: `~/.config/nvim/init.vim`
- ✅ Backups created: `~/.vimrc.backup.*`
- ✅ Battery script deployed: `~/.tmux/bat-macos.sh`
- ✅ Log file: `~/.dotfiles-sync.log`

### Verification After Sync
```bash
# Check configs exist
ls -la ~/.vimrc ~/.tmux.conf ~/.config/nvim/init.vim

# Check backups
ls -la ~/ | grep backup | head -5

# Check battery script
ls -la ~/.tmux/bat-macos.sh
# Should be executable

# Verify configs load
vim +':version' +:quit
tmux source ~/.tmux.conf

# Check log
cat ~/.dotfiles-sync.log
```

---

## Test 5: Configuration Testing

### Test Vim Configuration
```bash
# Open vim
vim ~/.vimrc

# Check settings
:set number?
# Expected: number

:set mouse?
# Expected: mouse=a

:set relativenumber?
# Expected: relativenumber

# Exit
:quit
```

### Test Tmux Configuration
```bash
# Start tmux session
tmux new-session -d -s test

# Check config loaded
tmux list-keys | head -10
# Should show configured keybindings

# Test split
tmux send-keys -t test "C-M-q" "h"
# Should create horizontal split

# Kill session
tmux kill-session -t test
```

### Test Shell Configuration
```bash
# Reload shell
exec zsh

# Check aliases
alias | grep -E "^alias (ll|la|mkdir)"
# Expected: custom aliases present

# Check PATH
echo $PATH | grep flutter
# Expected: Flutter path present

# Check Android SDK
echo $ANDROID_SDK_ROOT
# Expected: /opt/homebrew/share/android-sdk
```

---

## Test 6: Flutter Verification

### Objective
Ensure Flutter is fully functional

### Test Steps
```bash
# Check version
flutter --version

# Run doctor
flutter doctor

# Create test project
mkdir -p ~/test-flutter
cd ~/test-flutter
flutter create test_app
cd test_app

# Build for iOS
flutter build ios --release 2>&1 | head -20
# Expected: No critical errors

# Check supported platforms
flutter devices
```

### Expected Results
- ✅ Flutter version shown
- ✅ flutter doctor shows setup status
- ✅ Test project creates successfully
- ✅ No build errors
- ✅ Devices/simulators detected

---

## Test 7: Tool Integration Testing

### Test Git Integration
```bash
# Initialize test repo
mkdir ~/test-git
cd ~/test-git
git init
git config user.email "test@example.com"
git config user.name "Test User"

# Create test file
echo "test" > file.txt
git add file.txt
git commit -m "test commit"

# Check history
git log --oneline
```

### Test Tmux + Vim Integration
```bash
# Start tmux
tmux new-session -d -s dev -x 120 -y 40

# Open file in vim inside tmux
tmux send-keys -t dev "vim ~/.vimrc" Enter

# Navigate in vim
tmux send-keys -t dev ":" "set number" Enter

# Exit vim
tmux send-keys -t dev ":" "quit" Enter

# Kill session
tmux kill-session -t dev
```

### Test Ranger File Browser
```bash
# Test ranger
ranger ~/.dotfiles/scripts/

# Navigate folders (use arrow keys)
# Open a file with Enter
# Quit with 'q'
```

---

## Test 8: Error Recovery Testing

### Objective
Verify error handling and recovery mechanisms

### Test Steps
```bash
# 1. Test backup recovery
cp ~/.vimrc ~/.vimrc.broken
# Intentionally corrupt it
echo "invalid vim config" > ~/.vimrc

# 2. Run sync again (should backup the broken version)
cd ~/.dotfiles
./mac-sync/mac-sync-dotfiles-minimal.sh

# 3. Check backups
ls -lt ~/ | grep backup | head -3
# Should show multiple backup versions

# 4. Restore from backup
LATEST_BACKUP=$(ls -t ~/*.vimrc.backup.* 2>/dev/null | head -1)
cp "$LATEST_BACKUP" ~/.vimrc

# 5. Verify restoration
vim --version | head -5
```

### Test Missing Dependencies
```bash
# Temporarily hide a tool
mkdir -p ~/bin-backup
mv /usr/local/bin/tmux ~/bin-backup/ 2>/dev/null || true

# Try to run tmux (should fail gracefully)
tmux -V 2>&1
# Expected: command not found

# Restore
mv ~/bin-backup/tmux /usr/local/bin/ 2>/dev/null || true
```

---

## Test 9: Log File Verification

### Objective
Ensure logging works correctly

### Test Steps
```bash
# Check setup log
cat ~/.mac-flutter-setup.log | head -20
# Expected: Timestamped entries with each step

# Check sync log
cat ~/.dotfiles-sync.log | head -20
# Expected: Timestamped entries for each file synced

# Check for errors
grep -i error ~/.mac-flutter-setup.log
grep -i error ~/.dotfiles-sync.log
# Expected: No error messages (unless expected)

# File size check
ls -lh ~/.mac-flutter-setup.log ~/.dotfiles-sync.log
# Expected: Non-zero size files
```

---

## Test 10: Cleanup and Restoration

### Objective
Verify cleanup and restoration process

### Test Steps
```bash
# 1. Clean up test installations
rm -rf ~/test-flutter ~/test-git ~/test-macos

# 2. Restore original configs (if backed up)
cp ~/.vimrc.backup ~/.vimrc 2>/dev/null || true
cp ~/.tmux.conf.backup ~/.tmux.conf 2>/dev/null || true
cp ~/.zshrc.backup ~/.zshrc 2>/dev/null || true

# 3. Reload shell
exec zsh

# 4. Verify system is clean
ls ~/ | grep backup | wc -l
# Should list number of backups (informational)

# 5. Check for orphaned processes
ps aux | grep -E "flutter|brew|git" | grep -v grep
# Should show minimal processes
```

---

## Test Results Template

### For Documentation
```markdown
## Mac M4 Setup - Test Results

**Test Date:** [DATE]
**macOS Version:** [VERSION]
**Hardware:** Mac M4 [Model]

### Pre-Flight Checks
- [ ] macOS Monterey+
- [ ] arm64 architecture
- [ ] 5+ GB free space
- [ ] Internet connectivity
- [ ] curl available
- [ ] bash 5.0+

### Script Testing
- [ ] Setup script syntax valid
- [ ] Sync script syntax valid
- [ ] Original setup syntax valid
- [ ] Original sync syntax valid

### Installation Testing
- [ ] Xcode installed
- [ ] Homebrew operational
- [ ] All tools installed
- [ ] oh-my-zsh configured
- [ ] Flutter verified

### Configuration Testing
- [ ] Vim config loads
- [ ] Tmux config loads
- [ ] Shell profile updated
- [ ] Aliases working
- [ ] Paths configured

### Verification
- [ ] flutter doctor passes
- [ ] All tools accessible
- [ ] No error messages
- [ ] Log files created
- [ ] Backups in place

### Issues Found
[List any issues discovered]

### Overall Status
[PASS/FAIL with notes]
```

---

## Known Issues & Solutions

### Issue 1: Xcode Installation Timeout
**Symptom:** Xcode installation hangs
**Solution:**
```bash
# Cancel and retry
xcode-select --reset
xcode-select --install
```

### Issue 2: Homebrew PATH Not Set
**Symptom:** `brew: command not found`
**Solution:**
```bash
export PATH="/opt/homebrew/bin:$PATH"
# Add to ~/.zshrc
echo 'export PATH="/opt/homebrew/bin:$PATH"' >> ~/.zshrc
```

### Issue 3: Flutter Binary Not Found
**Symptom:** `flutter: command not found`
**Solution:**
```bash
# Reload shell
exec zsh
# Or manually add to PATH
export PATH="$PATH:$HOME/Development/flutter/bin"
```

### Issue 4: Tmux Config Error
**Symptom:** `tmux: unknown option -- M`
**Solution:**
```bash
# Check tmux version
tmux -V
# Update if too old
brew upgrade tmux
# Reload config
tmux source ~/.tmux.conf
```

### Issue 5: Permission Denied on Script
**Symptom:** `bash: ./script.sh: Permission denied`
**Solution:**
```bash
chmod +x script.sh
./script.sh
```

---

## Performance Benchmarks

### Installation Time Expectations
- Xcode CLI Tools: 5-15 minutes
- Homebrew: 2-5 minutes
- All tools: 10-20 minutes
- oh-my-zsh: 1-2 minutes
- **Total:** 30-45 minutes

### Sync Time Expectations
- Configuration deployment: 30 seconds
- Backup creation: 10 seconds
- **Total:** ~1 minute

---

## Success Criteria

### All Tests Passing = ✅ Success
- [ ] All pre-flight checks pass
- [ ] Scripts syntax valid
- [ ] Installation completes without errors
- [ ] All tools installed and functional
- [ ] Configurations deployed correctly
- [ ] Flutter doctor shows no critical errors
- [ ] No unrecovered error messages
- [ ] Log files contain expected entries
- [ ] Backup/restore works correctly

### Known Limitations
- ⚠️ Android Emulator requires additional setup
- ⚠️ iOS development requires Xcode full installation (optional)
- ⚠️ Some tools may need additional configuration

---

## Reporting Test Results

### To Share Results
```bash
# Create test report
cat > ~/test-report.txt << 'EOF'
Date: $(date)
System: $(system_profiler SPHardwareDataType | grep "Chip")
macOS: $(sw_vers -productVersion)

Setup Log:
$(tail -20 ~/.mac-flutter-setup.log)

Sync Log:
$(tail -20 ~/.dotfiles-sync.log)

Tools Check:
$(which flutter java tmux vim ranger)

Flutter Doctor:
$(flutter doctor 2>&1 | head -20)
EOF

# Share the report
cat ~/test-report.txt
```

---

## Next Steps After Testing

1. **If all tests pass:**
   - Archive the test report
   - Consider the setup verified
   - Ready for production use

2. **If issues found:**
   - Document the issue
   - Check solutions above
   - Report specific error with logs

3. **For customization:**
   - Edit ~/.vimrc for vim preferences
   - Edit ~/.tmux.conf for tmux keybindings
   - Edit ~/.zshrc for shell aliases

---

**Test Plan Complete** ✅

This comprehensive test plan should guide you through validating both the minimal and original setup scripts on an actual Mac M4 system.
