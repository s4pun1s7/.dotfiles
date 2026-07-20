#!/bin/bash

# macOS Autostart Script
# This script runs at login and starts background applications/services
# Place this at: ~/.config/autostart/startup.sh

set -e

LOG_FILE="$HOME/.config/autostart/startup.log"
mkdir -p "$HOME/.config/autostart"

log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"
}

log_message "Autostart script initiated"

# Enable error logging
trap 'log_message "Error occurred at line $LINENO"' ERR

# ============================================
# Homebrew PATH Setup
# ============================================
if [[ -d /opt/homebrew/bin ]]; then
    export PATH="/opt/homebrew/bin:$PATH"
    log_message "Homebrew PATH configured"
fi

# ============================================
# Tmux Session Management
# ============================================
# Uncomment to auto-start tmux session
# if ! tmux has-session -t main 2>/dev/null; then
#     tmux new-session -d -s main
#     log_message "tmux session 'main' started"
# fi

# ============================================
# Application Autostart Examples
# ============================================

# Start Alfred (if installed)
# if command -v open >/dev/null; then
#     open -a Alfred
#     log_message "Alfred started"
# fi

# Start Dropbox (if installed)
# if [[ -d ~/Applications/Dropbox.app ]]; then
#     open ~/Applications/Dropbox.app
#     log_message "Dropbox started"
# fi

# Start Bartender (if installed)
# if [[ -d ~/Applications/Bartender\ 4.app ]]; then
#     open ~/Applications/Bartender\ 4.app
#     log_message "Bartender started"
# fi

# ============================================
# Custom Commands
# ============================================

# Example: Sync dotfiles (uncomment to enable)
# if [[ -d ~/Development/dotfiles ]]; then
#     cd ~/Development/dotfiles
#     git pull origin master 2>&1 | tail -1 >> "$LOG_FILE"
#     log_message "Dotfiles synced"
# fi

# Example: Start development server (uncomment to enable)
# if [[ -d ~/Development/myapp ]]; then
#     cd ~/Development/myapp
#     npm start > /tmp/myapp.log 2>&1 &
#     log_message "Development server started"
# fi

# ============================================
# Post-Startup Tasks
# ============================================

log_message "Autostart script completed"
