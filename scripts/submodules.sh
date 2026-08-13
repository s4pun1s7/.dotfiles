#!/bin/bash

# Submodule helper for dwm / st / slstatus.
#
#   ./scripts/submodules.sh status          show branch, dirt and push state
#   ./scripts/submodules.sh sync            pull each submodule's tracked branch
#   ./scripts/submodules.sh push "message"  commit dirty submodules, push them,
#                                           then bump the pointers here
#
# Submodules are committed with the message you pass, never a generic one, and
# nothing is committed without you seeing the diffstat first.

set -e

RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status()  { echo -e "${BLUE}[INFO]${NC} $1"; }
print_success() { echo -e "${GREEN}[SUCCESS]${NC} $1"; }
print_warning() { echo -e "${YELLOW}[WARNING]${NC} $1"; }
print_error()   { echo -e "${RED}[ERROR]${NC} $1"; }

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SUBMODULES=(dwm st slstatus)

cmd_status() {
    for sub in "${SUBMODULES[@]}"; do
        echo ""
        print_status "$sub"
        git -C "$DOTFILES/$sub" status -sb | head -1
        local dirt
        dirt="$(git -C "$DOTFILES/$sub" status --porcelain)"
        if [[ -n "$dirt" ]]; then
            echo "$dirt"
        else
            echo "  clean"
        fi
    done

    echo ""
    print_status "pointers in .dotfiles"
    git -C "$DOTFILES" submodule status
}

cmd_sync() {
    for sub in "${SUBMODULES[@]}"; do
        print_status "Pulling $sub..."
        if [[ -n "$(git -C "$DOTFILES/$sub" status --porcelain)" ]]; then
            print_warning "$sub has local changes, skipping pull"
            continue
        fi
        git -C "$DOTFILES/$sub" pull --rebase --quiet && print_success "$sub up to date"
    done
}

cmd_push() {
    local message="$1"

    if [[ -z "$message" ]]; then
        print_error "A commit message is required: $0 push \"what changed\""
        exit 1
    fi

    for sub in "${SUBMODULES[@]}"; do
        if [[ -z "$(git -C "$DOTFILES/$sub" status --porcelain)" ]]; then
            print_status "$sub: nothing to commit"
        else
            print_status "$sub changes:"
            git -C "$DOTFILES/$sub" status --short
            git -C "$DOTFILES/$sub" add -A
            git -C "$DOTFILES/$sub" commit -q -m "$message"
            print_success "$sub committed"
        fi

        if [[ -n "$(git -C "$DOTFILES/$sub" log '@{u}..' --oneline 2>/dev/null)" ]]; then
            git -C "$DOTFILES/$sub" push
            print_success "$sub pushed"
        fi
    done

    if [[ -n "$(git -C "$DOTFILES" status --porcelain "${SUBMODULES[@]}")" ]]; then
        git -C "$DOTFILES" add "${SUBMODULES[@]}"
        git -C "$DOTFILES" commit -q -m "Update submodule pointers: $message"
        print_success "Submodule pointers updated in .dotfiles (not pushed)"
    else
        print_status "Submodule pointers already current"
    fi
}

case "${1:-status}" in
    status) cmd_status ;;
    sync)   cmd_sync ;;
    push)   cmd_push "${2:-}" ;;
    *)
        print_error "Unknown command: $1"
        echo "Usage: $0 [status|sync|push \"message\"]"
        exit 1
        ;;
esac
