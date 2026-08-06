#!/bin/bash

# Branch Setup Script
# This script helps create and setup platform-specific branches

set -e

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

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "This script helps create and setup platform-specific branches"
    echo ""
    echo "Options:"
    echo "  -h, --help          Show this help message"
    echo "  -c, --create        Create both linux and ios branches"
    echo "  -l, --linux         Create linux branch only"
    echo "  -i, --ios           Create ios branch only"
    echo ""
    echo "Examples:"
    echo "  $0 -c               # Create both branches"
    echo "  $0 -l               # Create linux branch only"
    echo "  $0 -i               # Create ios branch only"
}

# Function to create linux branch
create_linux_branch() {
    print_status "Creating linux branch..."
    
    # Check if branch already exists
    if git show-ref --verify --quiet refs/heads/linux; then
        print_warning "Linux branch already exists"
        return 0
    fi
    
    # Create branch from master
    git checkout -b linux master 2>/dev/null || git checkout -b linux
    
    # Update README for Linux branch
    cat > README.md << 'EOFREADME'
# .dotfiles

**Branch: Linux** - This branch contains Linux-specific configurations

This repository contains my personal dotfiles and custom builds of suckless tools as git submodules:

- [dwm](dwm/) - dynamic window manager
- [st](st/) - simple terminal
- [slstatus](slstatus/) - status bar utility

## Setup

Clone with submodules (Linux branch):

```sh
git clone -b linux --recursive https://github.com/s4pun1s7/.dotfiles.git
```

To update submodules:

```sh
git submodule update --init --recursive
```

Run the installation script:

```sh
./scripts/install.sh
```

## Usage

Each submodule contains its own README and build instructions. See the respective folders for details.

### Scripts
Custom scripts are in the `scripts/` directory. See `install.sh` for automated setup.

## Project Status

- All submodules are tracked and updated regularly.
- Custom patches and configuration are maintained in this repo.
- Linux-specific tools: dwm (window manager), st (terminal), slstatus (status bar)
- Installation uses apt package manager for Debian/Ubuntu-based systems

## Branches

This repository maintains separate branches for different operating systems:

- **linux** - Linux-specific configurations (this branch)
- **ios** - iOS/macOS-specific configurations

To switch to iOS/macOS configurations:

```sh
git checkout ios
```
EOFREADME
    
    # Commit changes
    git add README.md
    git commit -m "Update Linux branch README with branch information" || true
    
    print_success "Linux branch created successfully"
    print_status "Linux branch contains:"
    print_status "  - dwm, st, slstatus (suckless tools)"
    print_status "  - apt-based installation script"
    print_status "  - X11 dependencies"
    print_status "  - Linux-specific autostart scripts"
}

# Function to create ios branch
create_ios_branch() {
    print_status "Creating ios branch..."
    
    # Check if branch already exists
    if git show-ref --verify --quiet refs/heads/ios; then
        print_warning "iOS branch already exists"
        return 0
    fi
    
    # Create branch from master
    git checkout -b ios master 2>/dev/null || git checkout -b ios
    
    # Remove Linux-specific components
    print_status "Removing Linux-specific components..."
    
    # Remove Linux-specific submodules (if they exist)
    if [ -d "dwm" ]; then
        git rm -rf dwm 2>/dev/null || rm -rf dwm
    fi
    if [ -d "st" ]; then
        git rm -rf st 2>/dev/null || rm -rf st
    fi
    if [ -d "slstatus" ]; then
        git rm -rf slstatus 2>/dev/null || rm -rf slstatus
    fi
    
    # Create iOS/macOS-specific install script
    cat > scripts/install-macos.sh << 'EOFINSTALL'
#!/bin/bash

# macOS Dotfiles Install Script
# This script installs and updates dotfiles for macOS

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to check if Homebrew is installed
check_homebrew() {
    if ! command -v brew >/dev/null 2>&1; then
        print_status "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    else
        print_success "Homebrew is already installed"
    fi
}

# Function to install packages
install_packages() {
    print_status "Installing packages..."
    
    brew bundle --file=- <<EOF
# Taps
tap "homebrew/cask-fonts"

# CLI tools
brew "git"
brew "vim"
brew "tmux"
brew "neovim"
brew "ripgrep"
brew "fzf"

# Applications
cask "iterm2"
cask "visual-studio-code"
EOF
    
    print_success "Packages installed"
}

# Function to setup dotfiles
setup_dotfiles() {
    print_status "Setting up dotfiles..."
    
    # Vim configuration
    if [ -f ".vimrc" ]; then
        ln -sf "$(pwd)/.vimrc" ~/.vimrc
        print_success "Vim configuration linked"
    fi
    
    # Tmux configuration
    if [ -f ".tmux/.tmux.conf" ]; then
        mkdir -p ~/.tmux
        cp .tmux/.tmux.conf ~/.tmux/
        print_success "Tmux configuration copied"
    fi
}

main() {
    print_status "Starting macOS dotfiles installation..."
    
    check_homebrew
    install_packages
    setup_dotfiles
    
    print_success "Installation completed successfully!"
}

main "$@"
EOFINSTALL
    
    chmod +x scripts/install-macos.sh
    
    # Update README for iOS branch
    cat > README.md << 'EOFREADME'
# .dotfiles

**Branch: iOS/macOS** - This branch contains iOS/macOS-specific configurations

This repository contains my personal dotfiles optimized for macOS.

## Setup

Clone the repository:

```sh
git clone -b ios https://github.com/s4pun1s7/.dotfiles.git
cd .dotfiles
```

Run the installation script:

```sh
./scripts/install-macos.sh
```

## Contents

- `.vimrc` - Vim configuration
- `.tmux/.tmux.conf` - Tmux configuration
- `scripts/install-macos.sh` - Automated installation script for macOS

## Requirements

- macOS 10.14 or later
- Homebrew (will be installed automatically if not present)

## Branches

This repository maintains separate branches for different operating systems:

- **linux** - Linux-specific configurations
- **ios** - iOS/macOS-specific configurations (this branch)

To switch to Linux configurations:

```sh
git checkout linux
```
EOFREADME
    
    # Commit changes
    git add -A
    git commit -m "Configure iOS/macOS branch with Homebrew-based installation" || true
    
    print_success "iOS branch created and configured successfully"
    print_status "iOS branch contains:"
    print_status "  - Homebrew-based installation"
    print_status "  - macOS-specific install script"
    print_status "  - Removed Linux-specific tools (dwm, st, slstatus)"
}

# Main function
main() {
    local create_all=false
    local create_linux=false
    local create_ios=false
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_usage
                exit 0
                ;;
            -c|--create)
                create_all=true
                shift
                ;;
            -l|--linux)
                create_linux=true
                shift
                ;;
            -i|--ios)
                create_ios=true
                shift
                ;;
            *)
                print_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    # If no flags specified, show usage
    if [[ "$create_all" == false && "$create_linux" == false && "$create_ios" == false ]]; then
        show_usage
        exit 0
    fi
    
    # Get current branch to return to it later
    current_branch=$(git branch --show-current)
    
    # Create branches
    if [[ "$create_all" == true || "$create_linux" == true ]]; then
        create_linux_branch
    fi
    
    if [[ "$create_all" == true || "$create_ios" == true ]]; then
        create_ios_branch
    fi
    
    # Return to original branch
    if [[ -n "$current_branch" ]]; then
        git checkout "$current_branch"
        print_status "Returned to $current_branch branch"
    fi
    
    print_success "Branch setup completed!"
    print_status ""
    print_status "Available branches:"
    git branch -a | grep -E '(linux|ios)' || true
    print_status ""
    print_status "To switch branches:"
    print_status "  git checkout linux  # For Linux systems"
    print_status "  git checkout ios    # For iOS/macOS systems"
    print_status ""
    print_status "NOTE: You may need to push these branches to the remote repository:"
    print_status "  git push origin linux"
    print_status "  git push origin ios"
}

# Run main function
main "$@"
