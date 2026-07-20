#!/bin/bash

# macOS M4 Flutter Development Environment Setup Script
# This script sets up a brand new Mac M4 with Flutter and essential development tools
# Installs: Flutter, tmux, ohmyzsh, mc, ranger, vim, htop, and related dependencies

set -e  # Exit on any error

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
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

print_section() {
    echo ""
    echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
    echo -e "${CYAN}  $1${NC}"
    echo -e "${CYAN}═══════════════════════════════════════════════════════${NC}"
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to check if running on macOS
check_macos() {
    if [[ "$OSTYPE" != "darwin"* ]]; then
        print_error "This script is designed for macOS only"
        exit 1
    fi

    # Check for Apple Silicon (M-series chip)
    if [[ $(uname -m) != "arm64" ]]; then
        print_warning "This script is optimized for Apple Silicon (M-series). You're running on $(uname -m)"
        read -p "Continue anyway? (y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    fi

    print_success "Running on macOS $(sw_vers -productVersion)"
}

# Function to install Homebrew if not installed
install_homebrew() {
    print_section "Installing Homebrew"

    if command_exists brew; then
        print_success "Homebrew is already installed"
        brew --version
    else
        print_status "Installing Homebrew..."
        /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

        # Add Homebrew to PATH for M1/M2/M3/M4
        if [[ -d "/opt/homebrew/bin" ]]; then
            export PATH="/opt/homebrew/bin:$PATH"
            print_success "Homebrew installed and added to PATH"
        fi
    fi
}

# Function to install Xcode Command Line Tools
install_xcode_cli() {
    print_section "Installing Xcode Command Line Tools"

    if xcode-select -p >/dev/null 2>&1; then
        print_success "Xcode Command Line Tools are already installed"
    else
        print_status "Installing Xcode Command Line Tools..."
        xcode-select --install
        print_status "Please complete the Xcode installation and re-run this script"
        exit 0
    fi
}

# Function to install Java (required for Android development)
install_java() {
    print_section "Installing Java"

    if command_exists java; then
        print_success "Java is already installed"
        java -version
    else
        print_status "Installing OpenJDK 17..."
        brew install openjdk@17

        # Create symlink for java
        sudo ln -sfn /opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk /Library/Java/JavaVirtualMachines/openjdk-17.jdk

        print_success "Java installed successfully"
    fi
}

# Function to install Android SDK (optional, for Android development)
install_android_sdk() {
    print_section "Setting up Android SDK"

    read -p "Do you want to install Android SDK for Android development? (y/n) " -n 1 -r
    echo

    if [[ $REPLY =~ ^[Yy]$ ]]; then
        if command_exists sdkmanager; then
            print_success "Android SDK is already installed"
        else
            print_status "Installing Android SDK via Homebrew..."
            brew install android-sdk

            # Set up Android SDK paths
            export ANDROID_SDK_ROOT=/opt/homebrew/share/android-sdk
            export ANDROID_HOME=$ANDROID_SDK_ROOT

            print_status "Android SDK path set to: $ANDROID_SDK_ROOT"
        fi
    else
        print_status "Skipping Android SDK installation"
    fi
}

# Function to install Flutter
install_flutter() {
    print_section "Installing Flutter"

    if command_exists flutter; then
        print_success "Flutter is already installed"
        flutter --version
        print_status "Running 'flutter upgrade' to get the latest version..."
        flutter upgrade
    else
        print_status "Installing Flutter..."

        # Create development directory
        mkdir -p ~/Development

        if [[ -d ~/Development/flutter ]]; then
            print_warning "Flutter directory already exists at ~/Development/flutter"
        else
            print_status "Cloning Flutter repository..."
            git clone https://github.com/flutter/flutter.git -b stable ~/Development/flutter
        fi

        # Add Flutter to PATH
        export PATH="$PATH:$HOME/Development/flutter/bin"

        # Update shell profile
        if [[ -f ~/.zprofile ]]; then
            if ! grep -q "flutter/bin" ~/.zprofile; then
                echo 'export PATH="$PATH:$HOME/Development/flutter/bin"' >> ~/.zprofile
                print_status "Added Flutter to ~/.zprofile"
            fi
        fi

        if [[ -f ~/.bash_profile ]]; then
            if ! grep -q "flutter/bin" ~/.bash_profile; then
                echo 'export PATH="$PATH:$HOME/Development/flutter/bin"' >> ~/.bash_profile
                print_status "Added Flutter to ~/.bash_profile"
            fi
        fi

        print_status "Running Flutter doctor..."
        flutter doctor
    fi
}

# Function to install development tools
install_dev_tools() {
    print_section "Installing Development Tools"

    local tools=("tmux" "ranger" "mc" "vim" "htop" "git" "curl" "wget" "ripgrep" "fzf" "bat" "exa")

    for tool in "${tools[@]}"; do
        if command_exists "$tool"; then
            print_success "$tool is already installed"
        else
            print_status "Installing $tool..."
            brew install "$tool"
        fi
    done
}

# Function to install and configure oh-my-zsh
install_ohmyzsh() {
    print_section "Installing and Configuring oh-my-zsh"

    # Check if Zsh is the default shell
    if [[ "$SHELL" != *"zsh"* ]]; then
        print_status "Changing default shell to Zsh..."
        chsh -s /bin/zsh
        print_success "Default shell changed to Zsh. Please restart your terminal."
    fi

    # Install oh-my-zsh if not already installed
    if [[ -d ~/.oh-my-zsh ]]; then
        print_success "oh-my-zsh is already installed"
    else
        print_status "Installing oh-my-zsh..."
        sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
        print_success "oh-my-zsh installed successfully"
    fi

    # Install useful oh-my-zsh plugins
    print_status "Installing oh-my-zsh plugins..."

    # zsh-syntax-highlighting
    if [[ ! -d ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting ]]; then
        git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
            ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting
        print_success "zsh-syntax-highlighting installed"
    fi

    # zsh-autosuggestions
    if [[ ! -d ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions ]]; then
        git clone https://github.com/zsh-users/zsh-autosuggestions \
            ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions
        print_success "zsh-autosuggestions installed"
    fi
}

# Function to setup configuration files
setup_config_files() {
    print_section "Setting up Configuration Files"

    # Create .config directory if it doesn't exist
    mkdir -p ~/.config

    # Setup Vim configuration
    if [[ -f ~/.vimrc ]]; then
        print_warning "~/.vimrc already exists, skipping"
    else
        print_status "Creating basic Vim configuration..."
        cat > ~/.vimrc << 'EOF'
" Basic Vim Configuration
set number              " Show line numbers
set relativenumber     " Show relative line numbers
set tabstop=4          " Number of spaces that a <Tab> counts for
set shiftwidth=4       " Number of spaces for autoindent
set expandtab          " Use spaces instead of tabs
set autoindent         " Copy indent from current line
set smartindent        " Smart autoindenting for C-like languages
set hlsearch           " Highlight search matches
set incsearch          " Incremental search
set ignorecase         " Case insensitive search
set smartcase          " Case sensitive if uppercase present
set backspace=indent,eol,start
set mouse=a            " Enable mouse support
set termguicolors      " Enable true color support
set background=dark    " Dark background
syntax enable          " Enable syntax highlighting
EOF
        print_success "Vim configuration created at ~/.vimrc"
    fi

    # Setup tmux configuration if dotfiles includes it
    if [[ -f ./.tmux/.tmux.conf ]] && [[ ! -f ~/.tmux.conf ]]; then
        print_status "Linking tmux configuration..."
        mkdir -p ~/.tmux
        ln -sf "$(pwd)/.tmux/.tmux.conf" ~/.tmux.conf
        print_success "tmux configuration linked"
    fi
}

# Function to setup shell profile
setup_shell_profile() {
    print_section "Setting up Shell Profile"

    local zsh_rc=~/.zshrc

    if [[ ! -f "$zsh_rc" ]]; then
        print_warning "$zsh_rc not found, skipping shell profile setup"
        return
    fi

    # Add helpful aliases
    if ! grep -q "alias ll=" "$zsh_rc"; then
        print_status "Adding useful aliases to $zsh_rc..."
        cat >> "$zsh_rc" << 'EOF'

# Custom aliases
alias ll='ls -lah'
alias la='ls -A'
alias l='ls -CF'
alias cd..='cd ..'
alias mkdir='mkdir -p'
EOF
        print_success "Aliases added"
    fi

    # Add development paths if needed
    if ! grep -q "Development/flutter" "$zsh_rc"; then
        print_status "Adding development paths to $zsh_rc..."
        cat >> "$zsh_rc" << 'EOF'

# Flutter and Android Development
export PATH="$PATH:$HOME/Development/flutter/bin"
export ANDROID_SDK_ROOT=/opt/homebrew/share/android-sdk
export ANDROID_HOME=$ANDROID_SDK_ROOT
EOF
        print_success "Development paths added"
    fi
}

# Function to configure oh-my-zsh plugins
configure_ohmyzsh_plugins() {
    print_section "Configuring oh-my-zsh Plugins"

    local zsh_rc=~/.zshrc

    if [[ ! -f "$zsh_rc" ]]; then
        print_warning "$zsh_rc not found, skipping plugin configuration"
        return
    fi

    # Update plugins list
    if grep -q "^plugins=" "$zsh_rc"; then
        print_status "Updating oh-my-zsh plugins in $zsh_rc..."
        sed -i '' 's/^plugins=.*/plugins=(git brew extract zsh-syntax-highlighting zsh-autosuggestions colored-man-pages)/' "$zsh_rc"
    else
        print_warning "Could not find plugins configuration in $zsh_rc"
    fi
}

# Function to run Flutter doctor
run_flutter_doctor() {
    print_section "Running Flutter Doctor"

    if command_exists flutter; then
        flutter doctor
    else
        print_warning "Flutter not found, skipping flutter doctor"
    fi
}

# Function to show usage
show_usage() {
    cat << EOF
Usage: $0 [OPTIONS]

macOS M4 Flutter Development Environment Setup Script

Options:
  -h, --help              Show this help message
  -a, --all               Run full setup (default)
  --brew                  Install Homebrew only
  --xcode                 Install Xcode CLI tools only
  --java                  Install Java only
  --flutter               Install Flutter only
  --tools                 Install development tools only
  --ohmyzsh               Install oh-my-zsh only
  --config                Setup configuration files only
  --doctor                Run Flutter doctor only
  --android               Install Android SDK

Examples:
  $0                      # Full installation
  $0 --flutter            # Install Flutter only
  $0 --all --android      # Full setup with Android SDK

EOF
}

# Main function
main() {
    local install_all=true
    local skip_list=()

    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_usage
                exit 0
                ;;
            --brew)
                install_all=false
                install_homebrew
                exit 0
                ;;
            --xcode)
                install_all=false
                install_xcode_cli
                exit 0
                ;;
            --java)
                install_all=false
                install_java
                exit 0
                ;;
            --flutter)
                install_all=false
                install_flutter
                exit 0
                ;;
            --tools)
                install_all=false
                install_dev_tools
                exit 0
                ;;
            --ohmyzsh)
                install_all=false
                install_ohmyzsh
                exit 0
                ;;
            --config)
                install_all=false
                setup_config_files
                exit 0
                ;;
            --doctor)
                install_all=false
                run_flutter_doctor
                exit 0
                ;;
            --android)
                install_android_sdk
                shift
                ;;
            -a|--all)
                install_all=true
                shift
                ;;
            *)
                print_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done

    if [[ "$install_all" == true ]]; then
        print_section "macOS M4 Flutter Development Environment Setup"

        # Check system
        check_macos

        # Step 1: Xcode CLI Tools
        install_xcode_cli

        # Step 2: Homebrew
        install_homebrew

        # Step 3: Java
        install_java

        # Step 4: Development Tools
        install_dev_tools

        # Step 5: Flutter
        install_flutter

        # Step 6: Oh-my-zsh
        install_ohmyzsh

        # Step 7: Configure oh-my-zsh plugins
        configure_ohmyzsh_plugins

        # Step 8: Setup configuration files
        setup_config_files

        # Step 9: Setup shell profile
        setup_shell_profile

        # Step 10: Android SDK (optional prompt)
        install_android_sdk

        # Step 11: Run Flutter Doctor
        run_flutter_doctor

        print_section "Setup Complete!"

        echo -e "${GREEN}✓ macOS M4 development environment is ready!${NC}"
        echo ""
        echo "Installed components:"
        echo "  ✓ Homebrew - Package manager"
        echo "  ✓ Xcode CLI Tools - Development tools"
        echo "  ✓ Java - Programming language"
        echo "  ✓ Flutter - Mobile framework"
        echo "  ✓ Development tools - tmux, ranger, mc, vim, htop, etc."
        echo "  ✓ oh-my-zsh - Shell framework"
        echo ""
        echo "Next steps:"
        echo "  1. Restart your terminal or run: source ~/.zshrc"
        echo "  2. Run 'flutter doctor' to verify setup"
        echo "  3. Configure IDE (VS Code, Android Studio, Xcode)"
        echo "  4. Create your first Flutter project: flutter create my_app"
        echo ""
        echo "Documentation:"
        echo "  - Flutter: https://flutter.dev/docs"
        echo "  - Android Setup: https://flutter.dev/docs/get-started/install/macos#android-setup"
        echo "  - oh-my-zsh: https://ohmyz.sh/"
    fi
}

# Run main function
main "$@"
