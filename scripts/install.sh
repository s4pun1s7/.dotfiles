#!/bin/bash

# Dotfiles Install Script
#
# Deploys the tracked configs as symlinks and, on Linux, builds the suckless
# tools. Configs are split into three sets:
#
#   shared  - works on both Fedora and macOS (editor, tmux, alacritty)
#   linux   - X11 rice: dwm, dunst, picom, guake, tray applets
#   macos   - anything mac specific
#
# See README.md for the repo layout and THEME.md for the shared palette.

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CONFIG_HOME="${XDG_CONFIG_HOME:-$HOME/.config}"

case "$(uname -s)" in
    Linux)  OS=linux ;;
    Darwin) OS=macos ;;
    *)      OS=unknown ;;
esac

# Symlink tables: "source-in-repo:target-in-home"
LINKS_SHARED=(
    "home/.vimrc:$HOME/.vimrc"
    "config/nvim/init.vim:$CONFIG_HOME/nvim/init.vim"
    "config/tmux:$CONFIG_HOME/tmux"
    "config/alacritty:$CONFIG_HOME/alacritty"
)

LINKS_LINUX=(
    "config/dunst:$CONFIG_HOME/dunst"
    "config/picom:$CONFIG_HOME/picom"
    "config/flameshot:$CONFIG_HOME/flameshot"
    "config/volumeicon:$CONFIG_HOME/volumeicon"
    "config/htop:$CONFIG_HOME/htop"
    "config/Thunar:$CONFIG_HOME/Thunar"
)

# yabai + skhd give macOS dwm-style tiling on the Alt modkey
LINKS_MACOS=(
    "config/yabai:$CONFIG_HOME/yabai"
    "config/skhd:$CONFIG_HOME/skhd"
)

command_exists() {
    command -v "$1" >/dev/null 2>&1
}

check_root() {
    if [[ $EUID -eq 0 ]]; then
        print_error "This script should not be run as root"
        exit 1
    fi
}

# Link one repo path into place, backing up whatever is already there
link_one() {
    local src="$DOTFILES/$1"
    local dest="$2"

    if [[ ! -e "$src" ]]; then
        print_warning "Missing in repo, skipping: $1"
        return
    fi

    # Already pointing at the right place
    if [[ "$(readlink "$dest" 2>/dev/null)" == "$src" ]]; then
        return
    fi

    mkdir -p "$(dirname "$dest")"

    if [[ -e "$dest" || -L "$dest" ]]; then
        if [[ -L "$dest" ]]; then
            rm -f "$dest"
        else
            mv "$dest" "$dest.backup-$(date +%Y%m%d%H%M%S)"
            print_warning "Backed up existing $dest"
        fi
    fi

    ln -s "$src" "$dest"
    print_success "Linked $1 -> $dest"
}

link_configs() {
    print_status "Linking shared configs..."
    for entry in "${LINKS_SHARED[@]}"; do
        link_one "${entry%%:*}" "${entry#*:}"
    done

    if [[ "$OS" == linux ]]; then
        print_status "Linking Linux configs..."
        for entry in "${LINKS_LINUX[@]}"; do
            link_one "${entry%%:*}" "${entry#*:}"
        done
    elif [[ "$OS" == macos && ${#LINKS_MACOS[@]} -gt 0 ]]; then
        print_status "Linking macOS configs..."
        for entry in "${LINKS_MACOS[@]}"; do
            link_one "${entry%%:*}" "${entry#*:}"
        done
    fi
}

# Guake keeps its settings in dconf, not in a config file
setup_guake() {
    [[ "$OS" == linux ]] || return 0

    if command_exists dconf && command_exists guake; then
        print_status "Applying guake settings..."
        "$DOTFILES/guake/apply.sh"
    else
        print_warning "guake or dconf not installed, skipping guake settings"
    fi
}

# dwm's autostart patch runs this on session start
setup_autostart() {
    [[ "$OS" == linux ]] || return 0

    print_status "Setting up dwm autostart..."
    mkdir -p "$HOME/.local/share/dwm"
    link_one "scripts/autostart.sh" "$HOME/.local/share/dwm/autostart.sh"
}

install_dependencies() {
    if [[ "$OS" != linux ]]; then
        print_warning "Dependency install only covers Fedora, skipping"
        return 0
    fi

    print_status "Checking and installing dependencies..."

    local missing_packages=()

    command_exists make || missing_packages+=("make")
    command_exists gcc || missing_packages+=("gcc")
    pkg-config --exists x11 2>/dev/null || missing_packages+=("libX11-devel")
    pkg-config --exists xft 2>/dev/null || missing_packages+=("libXft-devel")
    pkg-config --exists xinerama 2>/dev/null || missing_packages+=("libXinerama-devel")
    pkg-config --exists fontconfig 2>/dev/null || missing_packages+=("fontconfig-devel")

    if [[ ${#missing_packages[@]} -gt 0 ]]; then
        print_status "Installing missing packages: ${missing_packages[*]}"
        sudo dnf install -y "${missing_packages[@]}"
    else
        print_success "All dependencies are already installed"
    fi
}

build_component() {
    local component=$1

    print_status "Building $component..."

    if [[ ! -d "$DOTFILES/$component" ]]; then
        print_warning "$component directory not found, skipping"
        return 0
    fi

    (
        cd "$DOTFILES/$component"
        make clean >/dev/null 2>&1 || true
        make -j"$(nproc)"
        sudo make install
    ) || {
        print_error "Failed to build or install $component"
        return 1
    }

    print_success "$component installed"
}

build_suckless() {
    if [[ "$OS" != linux ]]; then
        print_warning "Suckless tools are Linux only, skipping build"
        return 0
    fi

    for component in dwm st slstatus; do
        build_component "$component"
    done

    print_status "Installing start-dwm session wrapper..."
    sudo install -m 755 "$DOTFILES/scripts/start-dwm.sh" /usr/local/bin/start-dwm
    print_success "start-dwm installed"
}

update_system() {
    if [[ "$OS" != linux ]]; then
        print_warning "System update only covers Fedora, skipping"
        return 0
    fi
    print_status "Updating system packages..."
    sudo dnf upgrade -y
    print_success "System updated"
}

cleanup() {
    print_status "Cleaning up build artifacts..."
    for component in dwm st slstatus; do
        if [[ -d "$DOTFILES/$component" ]]; then
            (cd "$DOTFILES/$component" && make clean >/dev/null 2>&1) || true
        fi
    done
    print_success "Cleanup completed"
}

show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help          Show this help message"
    echo "  -u, --update        Update system packages first"
    echo "  -c, --clean         Clean build artifacts before building"
    echo "  -d, --dependencies  Install dependencies only"
    echo "  -l, --links         Link configuration files only"
    echo "  -b, --build         Build and install suckless tools only"
    echo ""
    echo "Examples:"
    echo "  $0                  # Full installation"
    echo "  $0 -l               # Re-link configs after moving files around"
    echo "  $0 -b               # Rebuild dwm/st/slstatus after a config change"
}

main() {
    local update_system_flag=false
    local clean_flag=false
    local dependencies_only=false
    local links_only=false
    local build_only=false

    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)         show_usage; exit 0 ;;
            -u|--update)       update_system_flag=true; shift ;;
            -c|--clean)        clean_flag=true; shift ;;
            -d|--dependencies) dependencies_only=true; shift ;;
            -l|--links)        links_only=true; shift ;;
            -b|--build)        build_only=true; shift ;;
            *)
                print_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done

    check_root
    print_status "Installing dotfiles for $OS from $DOTFILES"

    if [[ "$OS" == unknown ]]; then
        print_error "Unsupported platform: $(uname -s)"
        exit 1
    fi

    if [[ "$links_only" == true ]]; then
        link_configs
        setup_guake
        setup_autostart
        print_success "Configuration linked"
        exit 0
    fi

    if [[ "$update_system_flag" == true ]]; then
        update_system
    fi

    install_dependencies

    if [[ "$dependencies_only" == true ]]; then
        print_success "Dependencies installation completed"
        exit 0
    fi

    if [[ "$clean_flag" == true ]]; then
        cleanup
    fi

    if [[ "$build_only" == true ]]; then
        build_suckless
        print_success "Build completed"
        exit 0
    fi

    build_suckless
    link_configs
    setup_guake
    setup_autostart

    print_success "Installation completed successfully!"
    print_status "Log out and back into the dwm session to pick up a new dwm build"
}

main "$@"
