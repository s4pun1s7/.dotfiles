#!/bin/bash
# macOS M4 Flutter Setup - Minimal Edition

set -euo pipefail
trap 'echo "❌ Error at line $LINENO"; exit 1' ERR
trap 'echo "⚠️  Interrupted"; exit 130' INT TERM

: "${HOME:?}" "${LOG_FILE:=${HOME}/.mac-flutter-setup.log}"
: > "$LOG_FILE"

# Colors
RED='\033[0;31m' GREEN='\033[0;32m' YELLOW='\033[1;33m' BLUE='\033[0;34m' NC='\033[0m'
print() { echo -e "$1" | tee -a "$LOG_FILE"; }
log() { printf "[%s] %s\n" "$(date +%T)" "$*" >> "$LOG_FILE"; }

# Utilities
cmd_exists() { command -v "$1" &>/dev/null; }
retry() { for i in $(seq 1 3); do "$@" && return || sleep $((i*2)); done; return 1; }

# Pre-flight checks
check_sys() {
    [[ "$OSTYPE" == darwin* ]] || { print "${RED}❌ macOS only${NC}"; exit 1; }
    [[ $(uname -m) == arm64 ]] || print "${YELLOW}⚠️  Not M-series${NC}"
    (( $(df / | awk 'NR==2 {print $4}') / 1024 > 5000 )) || { print "${RED}❌ Need 5GB free${NC}"; exit 1; }
    ping -c 1 -W 2 8.8.8.8 &>/dev/null || { print "${RED}❌ No internet${NC}"; exit 1; }
}

# Install functions
install_xcode() {
    if xcode-select -p &>/dev/null; then
        print "${GREEN}✓ Xcode CLI${NC}"
    else
        print "${BLUE}→ Installing Xcode CLI...${NC}"
        xcode-select --install
        until xcode-select -p &>/dev/null; do sleep 5; done
        print "${GREEN}✓ Xcode CLI installed${NC}"
    fi
}

install_brew() {
    if cmd_exists brew; then
        print "${GREEN}✓ Homebrew${NC}"
    else
        print "${BLUE}→ Installing Homebrew...${NC}"
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
        export PATH="/opt/homebrew/bin:$PATH"
        print "${GREEN}✓ Homebrew installed${NC}"
    fi
}

install_tools() {
    local tools=("git" "curl" "java" "flutter" "tmux" "vim" "ranger" "mc" "htop" "ripgrep" "fzf" "bat" "exa")
    print "${BLUE}→ Installing tools...${NC}"

    # Java special case
    if ! cmd_exists java; then
        brew install openjdk@17
        sudo ln -sfn /opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk-17.jdk
    fi

    # Flutter special case
    if ! cmd_exists flutter; then
        mkdir -p ~/Development
        retry git clone --depth 1 -b stable https://github.com/flutter/flutter.git ~/Development/flutter
        export PATH="$PATH:$HOME/Development/flutter/bin"
    fi

    # Other tools via brew
    for tool in "${tools[@]}"; do
        [[ "$tool" == "java" || "$tool" == "flutter" ]] && continue
        cmd_exists "$tool" || brew install "$tool"
    done
    print "${GREEN}✓ Tools installed${NC}"
}

install_zsh() {
    if cmd_exists zsh; then
        print "${GREEN}✓ Zsh${NC}"
    else
        brew install zsh
    fi

    if [[ "$SHELL" != *"zsh"* ]]; then
        chsh -s /bin/zsh
    fi

    if [[ ! -d ~/.oh-my-zsh ]]; then
        print "${BLUE}→ Installing oh-my-zsh...${NC}"
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    fi

    # Plugins
    for plugin in zsh-syntax-highlighting zsh-autosuggestions; do
        [[ -d ~/.oh-my-zsh/custom/plugins/$plugin ]] || \
            retry git clone https://github.com/zsh-users/$plugin ~/.oh-my-zsh/custom/plugins/$plugin
    done

    # Update plugins in .zshrc
    sed -i '' 's/^plugins=.*/plugins=(git brew zsh-syntax-highlighting zsh-autosuggestions)/' ~/.zshrc

    print "${GREEN}✓ Zsh setup${NC}"
}

setup_configs() {
    print "${BLUE}→ Configuring environment...${NC}"

    # Vim config
    [[ -f ~/.vimrc ]] || cp .vimrc ~/.vimrc

    # Tmux config
    [[ -f ~/.tmux.conf ]] || ln -sf "$(pwd)/.tmux/.tmux.conf" ~/.tmux.conf

    # Shell profile updates
    for rc in ~/.zprofile ~/.bash_profile; do
        [[ -f "$rc" ]] && grep -q "flutter/bin" "$rc" || {
            echo 'export PATH="$PATH:$HOME/Development/flutter/bin"' >> "$rc"
            echo 'export ANDROID_SDK_ROOT=/opt/homebrew/share/android-sdk' >> "$rc"
        }
    done

    print "${GREEN}✓ Configs applied${NC}"
}

# Main
main() {
    print "${BLUE}╔═══════════════════════════════════════════════════════╗${NC}"
    print "${BLUE}║  macOS M4 Flutter Setup${NC}"
    print "${BLUE}╚═══════════════════════════════════════════════════════╝${NC}\n"

    check_sys
    install_xcode
    install_brew
    install_tools
    install_zsh
    setup_configs

    print "\n${GREEN}✓ Setup complete!${NC}"
    print "\n${BLUE}Next steps:${NC}"
    print "  1. Restart terminal: exec zsh"
    print "  2. Verify: flutter doctor"
    print "  3. Log: cat $LOG_FILE"
}

main "$@"
