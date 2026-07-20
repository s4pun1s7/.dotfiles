#!/bin/bash
# Minimal Dotfiles Sync Script

set -euo pipefail
trap 'echo "❌ Error at line $LINENO"; exit 1' ERR

DOTFILES="${1:-.}"
LOG="${HOME}/.dotfiles-sync.log"
: > "$LOG"

# Colors
RED='\033[0;31m' GREEN='\033[0;32m' YELLOW='\033[1;33m' BLUE='\033[0;34m' NC='\033[0m'
log() { echo "[$(date +%T)] $*" >> "$LOG"; }
print() { echo -e "$1" | tee -a "$LOG"; }

# Backup and deploy file
deploy() {
    local src=$1 dst=$2 desc=$3
    [[ -f "$src" ]] || { print "${RED}❌ $desc: source not found${NC}"; return 1; }
    mkdir -p "$(dirname "$dst")"
    [[ -f "$dst" ]] && cp -p "$dst" "${dst}.backup.$(date +%s)"
    cp -p "$src" "$dst"
    print "${GREEN}✓ $desc${NC}"
}

main() {
    print "${BLUE}Syncing dotfiles...${NC}\n"

    cd "$DOTFILES" || exit 1

    # Sync configs
    deploy .vimrc ~/.vimrc "Vim config"
    deploy .tmux/.tmux.conf ~/.tmux.conf "Tmux config"
    [[ -f .config/nvim/init.vim ]] && deploy .config/nvim/init.vim ~/.config/nvim/init.vim "Neovim config"

    # Sync scripts
    deploy mac-sync/bat-macos.sh ~/.tmux/bat-macos.sh "Battery script"
    chmod +x ~/.tmux/bat-macos.sh

    print "\n${GREEN}✓ Sync complete${NC}"
    print "\nLog: $LOG"
}

main "$@"
