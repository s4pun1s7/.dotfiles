#!/bin/bash

# macOS Dotfiles Sync Script
# Syncs configuration files from dotfiles repository to a new Mac M4
# Usage: ./mac-sync-dotfiles.sh [OPTIONS]

set -euo pipefail

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m'

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOTFILES_ROOT="$(dirname "$SCRIPT_DIR")"
LOG_FILE="$HOME/.dotfiles-sync.log"
BACKUP_SUFFIX=".backup.$(date +%s)"

# Error handling
handle_error() {
    local line=$1
    print_error "Error at line $line"
    print_error "Check log: $LOG_FILE"
    exit 1
}

trap 'handle_error $LINENO' ERR

# Utility functions
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [INFO] $1" >> "$LOG_FILE"
}

print_success() {
    echo -e "${GREEN}[OK]${NC} $1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [OK] $1" >> "$LOG_FILE"
}

print_warning() {
    echo -e "${YELLOW}[WARN]${NC} $1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [WARN] $1" >> "$LOG_FILE"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] [ERROR] $1" >> "$LOG_FILE"
}

print_section() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════${NC}"
    echo -e "${CYAN}  $1${NC}"
    echo -e "${CYAN}═══════════════════════════════════════${NC}"
}

# Backup existing file
backup_file() {
    local file=$1
    if [[ -f "$file" ]] || [[ -L "$file" ]]; then
        local backup_file="${file}${BACKUP_SUFFIX}"
        if cp -p "$file" "$backup_file"; then
            print_status "Backed up: $file → $backup_file"
        else
            print_error "Failed to backup: $file"
            return 1
        fi
    fi
}

# Deploy configuration file
deploy_config() {
    local src=$1
    local dest=$2
    local description=$3

    print_status "Deploying: $description"

    # Check source exists
    if [[ ! -f "$src" ]]; then
        print_error "Source not found: $src"
        return 1
    fi

    # Create destination directory
    local dest_dir
    dest_dir=$(dirname "$dest")
    if [[ ! -d "$dest_dir" ]]; then
        if mkdir -p "$dest_dir"; then
            print_status "Created directory: $dest_dir"
        else
            print_error "Failed to create directory: $dest_dir"
            return 1
        fi
    fi

    # Backup existing destination
    if [[ -f "$dest" ]] || [[ -L "$dest" ]]; then
        if ! backup_file "$dest"; then
            return 1
        fi
    fi

    # Deploy file
    if cp -p "$src" "$dest"; then
        print_success "Deployed: $description → $dest"
        return 0
    else
        print_error "Failed to deploy: $description"
        return 1
    fi
}

# Deploy symlink
deploy_symlink() {
    local src=$1
    local dest=$2
    local description=$3

    print_status "Symlinking: $description"

    # Check source exists
    if [[ ! -f "$src" ]]; then
        print_error "Source not found: $src"
        return 1
    fi

    # Create destination directory
    local dest_dir
    dest_dir=$(dirname "$dest")
    if [[ ! -d "$dest_dir" ]]; then
        if mkdir -p "$dest_dir"; then
            print_status "Created directory: $dest_dir"
        else
            print_error "Failed to create directory: $dest_dir"
            return 1
        fi
    fi

    # Backup existing destination
    if [[ -f "$dest" ]] || [[ -L "$dest" ]]; then
        if ! backup_file "$dest"; then
            return 1
        fi
    fi

    # Create symlink
    if ln -sf "$src" "$dest"; then
        print_success "Symlinked: $description → $dest"
        return 0
    else
        print_error "Failed to create symlink: $description"
        return 1
    fi
}

# Sync vim configuration
sync_vim() {
    print_section "Syncing Vim Configuration"

    local vim_src="$DOTFILES_ROOT/.vimrc"
    if deploy_config "$vim_src" "$HOME/.vimrc" "Vim configuration"; then
        print_success "Vim configuration synced"
    else
        print_warning "Failed to sync Vim configuration"
    fi
}

# Sync tmux configuration
sync_tmux() {
    print_section "Syncing Tmux Configuration"

    local tmux_src="$DOTFILES_ROOT/.tmux/.tmux.conf"
    if deploy_config "$tmux_src" "$HOME/.tmux.conf" "Tmux configuration"; then
        print_success "Tmux configuration synced"
    else
        print_warning "Failed to sync Tmux configuration"
    fi
}

# Sync neovim configuration
sync_neovim() {
    print_section "Syncing Neovim Configuration"

    if ! command -v nvim &>/dev/null; then
        print_warning "Neovim not installed, skipping nvim config"
        return 0
    fi

    local nvim_src="$DOTFILES_ROOT/.config/nvim/init.vim"
    if deploy_config "$nvim_src" "$HOME/.config/nvim/init.vim" "Neovim configuration"; then
        print_success "Neovim configuration synced"
    else
        print_warning "Failed to sync Neovim configuration"
    fi
}

# Deploy macOS-specific scripts
sync_scripts() {
    print_section "Syncing Utility Scripts"

    # Deploy macOS battery script
    local bat_script_src="$SCRIPT_DIR/bat-macos.sh"
    if [[ -f "$bat_script_src" ]]; then
        if deploy_config "$bat_script_src" "$HOME/.tmux/bat-macos.sh" "Battery script"; then
            chmod +x "$HOME/.tmux/bat-macos.sh"
            print_success "Battery script deployed and made executable"
        fi
    fi

    # Note: Update .tmux.conf to use bat-macos.sh instead of bat.sh
    print_warning "Remember to update .tmux.conf to use ~/.tmux/bat-macos.sh"
}

# Deploy startup configuration
sync_startup() {
    print_section "Syncing Startup Configuration"

    local startup_src="$SCRIPT_DIR/startup-macos.sh"
    if [[ -f "$startup_src" ]]; then
        if deploy_config "$startup_src" "$HOME/.config/autostart/startup.sh" "Autostart script"; then
            chmod +x "$HOME/.config/autostart/startup.sh"
            print_success "Autostart script deployed and made executable"
        fi
    else
        print_warning "Autostart script not found"
    fi
}

# Deploy launchd configuration
sync_launchd() {
    print_section "Syncing LaunchD Configuration"

    print_warning "LaunchD setup requires manual configuration"
    print_status "To enable autostart:"
    echo ""
    echo "1. Edit autostart-macos.plist:"
    echo "   - Replace YOURNAME with your actual macOS username"
    echo "   - Ensure startup.sh path is correct"
    echo ""
    echo "2. Install launch agent:"
    echo "   cp autostart-macos.plist ~/Library/LaunchAgents/com.user.autostart.plist"
    echo "   chmod 644 ~/Library/LaunchAgents/com.user.autostart.plist"
    echo ""
    echo "3. Load and start:"
    echo "   launchctl load ~/Library/LaunchAgents/com.user.autostart.plist"
    echo ""
}

# Show configuration summary
show_summary() {
    print_section "Sync Summary"

    echo ""
    echo "Configuration files synced:"
    echo "  ✓ Vim configuration: ~/.vimrc"
    echo "  ✓ Tmux configuration: ~/.tmux.conf"
    echo "  ✓ Neovim configuration: ~/.config/nvim/init.vim"
    echo ""
    echo "Backup files created:"
    echo "  → Files ending with .backup.TIMESTAMP"
    echo ""
    echo "Next steps:"
    echo "  1. Review and customize synced configurations"
    echo "  2. Restart terminal applications to load new configs"
    echo "  3. Run 'tmux source ~/.tmux.conf' to reload tmux"
    echo "  4. Run 'vim' and check :version for configuration"
    echo ""
    echo "Documentation:"
    echo "  - See SYNC_CHECKLIST.md for all available options"
    echo "  - Log file: $LOG_FILE"
    echo ""
}

# Show usage
show_usage() {
    cat << EOF
Usage: $0 [OPTIONS]

Sync dotfiles configuration to macOS

Options:
  -h, --help      Show this help message
  -a, --all       Sync all configurations (default)
  -v, --vim       Sync Vim only
  -t, --tmux      Sync Tmux only
  -n, --neovim    Sync Neovim only
  -s, --scripts   Sync scripts only
  --summary       Show what will be synced

Examples:
  $0              # Sync all configurations
  $0 --vim        # Sync Vim configuration only
  $0 --tmux       # Sync Tmux configuration only

EOF
}

# Main function
main() {
    local sync_all=true
    local sync_vim=false
    local sync_tmux=false
    local sync_neovim=false
    local sync_scripts=false

    # Initialize log file
    : > "$LOG_FILE"
    print_status "Starting dotfiles sync..."

    # Parse arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_usage
                exit 0
                ;;
            -a|--all)
                sync_all=true
                shift
                ;;
            -v|--vim)
                sync_all=false
                sync_vim=true
                shift
                ;;
            -t|--tmux)
                sync_all=false
                sync_tmux=true
                shift
                ;;
            -n|--neovim)
                sync_all=false
                sync_neovim=true
                shift
                ;;
            -s|--scripts)
                sync_all=false
                sync_scripts=true
                shift
                ;;
            --summary)
                echo "Dotfiles located at: $DOTFILES_ROOT"
                echo ""
                echo "Available configurations:"
                echo "  - .vimrc (Vim)"
                echo "  - .tmux/.tmux.conf (Tmux)"
                echo "  - .config/nvim/init.vim (Neovim)"
                exit 0
                ;;
            *)
                print_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done

    # Execute sync
    print_section "macOS Dotfiles Synchronization"

    if [[ "$sync_all" == true ]]; then
        sync_vim
        sync_tmux
        sync_neovim
        sync_scripts
        sync_startup
        sync_launchd
    else
        [[ "$sync_vim" == true ]] && sync_vim
        [[ "$sync_tmux" == true ]] && sync_tmux
        [[ "$sync_neovim" == true ]] && sync_neovim
        [[ "$sync_scripts" == true ]] && sync_scripts
    fi

    # Summary
    show_summary

    print_success "Sync completed! Check $LOG_FILE for details."
}

# Run main function
main "$@"
