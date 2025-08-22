#!/bin/bash

# Dotfiles Install Script
# This script installs and updates all components of the dotfiles

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
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

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if we're running as root
check_root() {
    if [[ $EUID -eq 0 ]]; then
        print_error "This script should not be run as root"
        exit 1
    fi
}

# Function to install dependencies
install_dependencies() {
    print_status "Checking and installing dependencies..."
    
    # Check for required packages
    local missing_packages=()
    
    # Build tools
    if ! command_exists make; then
        missing_packages+=("build-essential")
    fi
    
    if ! command_exists gcc; then
        missing_packages+=("gcc")
    fi
    
    # X11 development
    if ! pkg-config --exists x11 2>/dev/null; then
        missing_packages+=("libx11-dev")
    fi
    
    if ! pkg-config --exists xft 2>/dev/null; then
        missing_packages+=("libxft-dev")
    fi
    
    if ! pkg-config --exists xinerama 2>/dev/null; then
        missing_packages+=("libxinerama-dev")
    fi
    
    # Fontconfig
    if ! pkg-config --exists fontconfig 2>/dev/null; then
        missing_packages+=("libfontconfig1-dev")
    fi
    
    # Install missing packages
    if [[ ${#missing_packages[@]} -gt 0 ]]; then
        print_status "Installing missing packages: ${missing_packages[*]}"
        sudo apt update
        sudo apt install -y "${missing_packages[@]}"
    else
        print_success "All dependencies are already installed"
    fi
}

# Function to build and install a component
build_component() {
    local component=$1
    local component_dir=$2
    
    print_status "Building $component..."
    
    if [[ ! -d "$component_dir" ]]; then
        print_error "$component directory not found"
        return 1
    fi
    
    cd "$component_dir"
    
    # Clean previous builds
    if [[ -f Makefile ]]; then
        make clean 2>/dev/null || true
    fi
    
    # Build
    if make -j$(nproc); then
        print_success "$component built successfully"
        
        # Install
        if sudo make install; then
            print_success "$component installed successfully"
        else
            print_error "Failed to install $component"
            return 1
        fi
    else
        print_error "Failed to build $component"
        return 1
    fi
    
    cd - >/dev/null
}

# Function to setup tmux configuration
setup_tmux() {
    print_status "Setting up tmux configuration..."
    
    # Create tmux config directory if it doesn't exist
    mkdir -p ~/.tmux
    
    # Copy tmux configuration
    if [[ -f .tmux/.tmux.conf ]]; then
        cp .tmux/.tmux.conf ~/.tmux/
        print_success "Tmux configuration copied"
    else
        print_warning "Tmux configuration not found"
    fi
    
    # Copy tmux scripts
    if [[ -f scripts/bat.sh ]]; then
        cp scripts/bat.sh ~/.tmux/
        chmod +x ~/.tmux/bat.sh
        print_success "Tmux scripts copied"
    fi
}

# Function to setup autostart script
setup_autostart() {
    print_status "Setting up autostart script..."
    
    # Create autostart directory if it doesn't exist
    mkdir -p ~/.config/autostart
    
    # Copy autostart script
    if [[ -f scripts/autostart.sh ]]; then
        cp scripts/autostart.sh ~/.config/autostart/
        chmod +x ~/.config/autostart/autostart.sh
        print_success "Autostart script copied"
    else
        print_warning "Autostart script not found"
    fi
}

# Function to create symlinks for configuration files
create_symlinks() {
    print_status "Creating configuration symlinks..."
    
    # Vim configuration
    if [[ -f .vimrc ]]; then
        ln -sf "$(pwd)/.vimrc" ~/.vimrc
        print_success "Vim configuration linked"
    fi
    
    # Git configuration (if exists)
    if [[ -f .gitconfig ]]; then
        ln -sf "$(pwd)/.gitconfig" ~/.gitconfig
        print_success "Git configuration linked"
    fi
}

# Function to update the system
update_system() {
    print_status "Updating system packages..."
    sudo apt update
    sudo apt upgrade -y
    print_success "System updated"
}

# Function to clean up old builds
cleanup() {
    print_status "Cleaning up build artifacts..."
    
    # Clean dwm
    if [[ -d dwm ]]; then
        cd dwm
        make clean 2>/dev/null || true
        cd - >/dev/null
    fi
    
    # Clean st
    if [[ -d st ]]; then
        cd st
        make clean 2>/dev/null || true
        cd - >/dev/null
    fi
    
    # Clean slstatus
    if [[ -d slstatus ]]; then
        cd slstatus
        make clean 2>/dev/null || true
        cd - >/dev/null
    fi
    
    print_success "Cleanup completed"
}

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help          Show this help message"
    echo "  -u, --update        Update system packages first"
    echo "  -c, --clean         Clean build artifacts before building"
    echo "  -d, --dependencies  Install dependencies only"
    echo "  -t, --tmux          Setup tmux configuration only"
    echo "  -a, --autostart     Setup autostart script only"
    echo "  -s, --symlinks      Create configuration symlinks only"
    echo ""
    echo "Examples:"
    echo "  $0                  # Full installation"
    echo "  $0 -u               # Update system and install"
    echo "  $0 -c               # Clean and install"
    echo "  $0 -d               # Install dependencies only"
}

# Main function
main() {
    local update_system_flag=false
    local clean_flag=false
    local dependencies_only=false
    local tmux_only=false
    local autostart_only=false
    local symlinks_only=false
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_usage
                exit 0
                ;;
            -u|--update)
                update_system_flag=true
                shift
                ;;
            -c|--clean)
                clean_flag=true
                shift
                ;;
            -d|--dependencies)
                dependencies_only=true
                shift
                ;;
            -t|--tmux)
                tmux_only=true
                shift
                ;;
            -a|--autostart)
                autostart_only=true
                shift
                ;;
            -s|--symlinks)
                symlinks_only=true
                shift
                ;;
            *)
                print_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    print_status "Starting dotfiles installation..."
    
    # Check if not running as root
    check_root
    
    # Update system if requested
    if [[ "$update_system_flag" == true ]]; then
        update_system
    fi
    
    # Install dependencies
    install_dependencies
    
    # Exit if only dependencies were requested
    if [[ "$dependencies_only" == true ]]; then
        print_success "Dependencies installation completed"
        exit 0
    fi
    
    # Clean if requested
    if [[ "$clean_flag" == true ]]; then
        cleanup
    fi
    
    # Setup tmux only if requested
    if [[ "$tmux_only" == true ]]; then
        setup_tmux
        print_success "Tmux setup completed"
        exit 0
    fi
    
    # Setup autostart only if requested
    if [[ "$autostart_only" == true ]]; then
        setup_autostart
        print_success "Autostart setup completed"
        exit 0
    fi
    
    # Create symlinks only if requested
    if [[ "$symlinks_only" == true ]]; then
        create_symlinks
        print_success "Symlinks creation completed"
        exit 0
    fi
    
    # Full installation
    print_status "Building and installing components..."
    
    # Build and install dwm
    if [[ -d dwm ]]; then
        build_component "dwm" "dwm"
    else
        print_warning "dwm directory not found, skipping"
    fi
    
    # Build and install st
    if [[ -d st ]]; then
        build_component "st" "st"
    else
        print_warning "st directory not found, skipping"
    fi
    
    # Build and install slstatus
    if [[ -d slstatus ]]; then
        build_component "slstatus" "slstatus"
    else
        print_warning "slstatus directory not found, skipping"
    fi
    
    # Setup tmux configuration
    setup_tmux
    
    # Setup autostart script
    setup_autostart
    
    # Create symlinks
    create_symlinks
    
    print_success "Installation completed successfully!"
    print_status "You may need to restart your session or run 'killall dwm' to see changes"
}

# Run main function with all arguments
main "$@" 