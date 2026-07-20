#!/bin/bash

# macOS M4 Flutter Development Environment Setup Script
# This script sets up a brand new Mac M4 with Flutter and essential development tools
# Installs: Flutter, tmux, ohmyzsh, mc, ranger, vim, htop, and related dependencies

set -euo pipefail  # Exit on error, undefined vars, pipe failures

# Enable error trapping with better debugging
trap 'handle_error $? $LINENO' ERR
trap 'handle_interrupt' INT TERM

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
LOG_FILE="${HOME}/.mac-flutter-setup.log"
FLUTTER_DIR="${HOME}/Development/flutter"
MAX_RETRIES=3
RETRY_DELAY=2
MIN_DISK_SPACE_MB=5000  # Minimum 5GB free disk space

# Error handling
handle_error() {
    local exit_code=$1
    local line_no=$2
    print_error "Script failed at line $line_no with exit code $exit_code"
    print_error "Check log file: $LOG_FILE"
    exit "$exit_code"
}

# Interrupt handler
handle_interrupt() {
    print_warning "Script interrupted by user"
    exit 130
}

# Log output
log_message() {
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] $*" >> "$LOG_FILE"
}

# Retry function for network operations
retry_command() {
    local max_attempts=$1
    shift
    local attempt=1

    while [[ $attempt -le $max_attempts ]]; do
        print_status "Attempt $attempt/$max_attempts: $*"
        if "$@"; then
            return 0
        fi

        if [[ $attempt -lt $max_attempts ]]; then
            local delay=$((RETRY_DELAY * attempt))
            print_warning "Command failed, retrying in ${delay}s..."
            sleep "$delay"
        fi
        ((attempt++))
    done

    print_error "Command failed after $max_attempts attempts: $*"
    return 1
}

# Check internet connectivity
check_internet() {
    print_status "Checking internet connectivity..."
    if ! ping -c 1 -W 2 8.8.8.8 >/dev/null 2>&1; then
        print_error "No internet connection detected"
        return 1
    fi
    print_success "Internet connection verified"
    return 0
}

# Check available disk space
check_disk_space() {
    print_status "Checking available disk space..."
    local available_mb=$(df / | awk 'NR==2 {print int($4/1024)}')

    if [[ $available_mb -lt $MIN_DISK_SPACE_MB ]]; then
        print_error "Insufficient disk space. Required: ${MIN_DISK_SPACE_MB}MB, Available: ${available_mb}MB"
        return 1
    fi
    print_success "Disk space check passed (${available_mb}MB available)"
    return 0
}

# Validate command output
validate_install() {
    local cmd=$1
    local name=$2

    if ! command_exists "$cmd"; then
        print_error "Failed to install $name: $cmd not found"
        return 1
    fi
    print_success "$name installed and verified"
    return 0
}

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
    local cmd=$1
    if ! command -v "$cmd" >/dev/null 2>&1; then
        return 1
    fi
    return 0
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
        if ! brew --version; then
            print_error "Homebrew installation appears corrupted"
            return 1
        fi
    else
        print_status "Installing Homebrew..."

        # Verify curl is available
        if ! command_exists curl; then
            print_error "curl is required but not found"
            return 1
        fi

        # Download and execute installer with error checking
        local install_script
        install_script=$(mktemp) || { print_error "Failed to create temp file"; return 1; }
        trap "rm -f '$install_script'" RETURN

        if ! retry_command $MAX_RETRIES curl -fsSL \
            https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh \
            -o "$install_script"; then
            print_error "Failed to download Homebrew installer"
            return 1
        fi

        # Verify script was downloaded
        if [[ ! -s "$install_script" ]]; then
            print_error "Downloaded installer script is empty"
            return 1
        fi

        # Execute installer
        if ! /bin/bash "$install_script"; then
            print_error "Homebrew installation failed"
            return 1
        fi

        # Add Homebrew to PATH for Apple Silicon
        if [[ -d "/opt/homebrew/bin" ]]; then
            export PATH="/opt/homebrew/bin:$PATH"
            print_success "Homebrew installed and added to PATH"
        else
            print_warning "Homebrew path not found, installation may have failed"
            return 1
        fi

        # Verify installation
        if ! validate_install brew "Homebrew"; then
            return 1
        fi
    fi
}

# Function to install Xcode Command Line Tools
install_xcode_cli() {
    print_section "Installing Xcode Command Line Tools"

    if xcode-select -p >/dev/null 2>&1; then
        print_success "Xcode Command Line Tools are already installed"
        if ! xcode-select --version; then
            print_error "Xcode installation appears corrupted"
            return 1
        fi
    else
        print_status "Installing Xcode Command Line Tools..."
        if ! xcode-select --install; then
            print_error "Failed to initiate Xcode installation"
            return 1
        fi

        print_status "Waiting for Xcode installation to complete..."
        print_warning "This may take several minutes. Please complete the installation when prompted."

        # Wait for installation to complete (with timeout)
        local timeout=0
        local max_timeout=1800  # 30 minutes
        while [[ $timeout -lt $max_timeout ]]; do
            if xcode-select -p >/dev/null 2>&1; then
                print_success "Xcode Command Line Tools installed successfully"
                return 0
            fi
            sleep 5
            ((timeout += 5))
        done

        print_error "Xcode installation timed out after 30 minutes"
        return 1
    fi
}

# Function to install Java (required for Android development)
install_java() {
    print_section "Installing Java"

    if command_exists java; then
        print_success "Java is already installed"
        if ! java -version 2>&1; then
            print_error "Java appears to be broken"
            return 1
        fi
    else
        print_status "Installing OpenJDK 17..."

        if ! brew install openjdk@17; then
            print_error "Failed to install OpenJDK 17"
            return 1
        fi

        if ! validate_install java "Java"; then
            return 1
        fi

        # Create symlink for java
        print_status "Creating Java symlink..."
        if [[ ! -d /opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk ]]; then
            print_error "OpenJDK installation directory not found"
            return 1
        fi

        if ! sudo ln -sfn /opt/homebrew/opt/openjdk@17/libexec/openjdk.jdk \
            /Library/Java/JavaVirtualMachines/openjdk-17.jdk; then
            print_warning "Failed to create symlink, but Java should still work"
        fi

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
        if ! flutter --version; then
            print_error "Flutter appears to be corrupted"
            return 1
        fi

        print_status "Running 'flutter upgrade' to get the latest version..."
        if ! flutter upgrade; then
            print_warning "Flutter upgrade failed, continuing with current version"
        fi
        return 0
    fi

    print_status "Installing Flutter..."

    # Create development directory
    print_status "Creating development directory..."
    if ! mkdir -p ~/Development; then
        print_error "Failed to create ~/Development directory"
        return 1
    fi

    # Check if Flutter directory already exists
    if [[ -d "$FLUTTER_DIR" ]]; then
        print_warning "Flutter directory already exists at $FLUTTER_DIR"
        read -p "Do you want to reinstall Flutter? (y/n) " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            print_status "Skipping Flutter installation"
            return 0
        fi
        print_status "Backing up existing Flutter installation..."
        if ! mv "$FLUTTER_DIR" "${FLUTTER_DIR}.backup.$(date +%s)"; then
            print_error "Failed to backup existing Flutter installation"
            return 1
        fi
    fi

    # Verify git is available
    if ! command_exists git; then
        print_error "git is required but not found"
        return 1
    fi

    # Clone Flutter repository with retry logic
    print_status "Cloning Flutter repository..."
    if ! retry_command $MAX_RETRIES git clone https://github.com/flutter/flutter.git -b stable "$FLUTTER_DIR"; then
        print_error "Failed to clone Flutter repository"
        return 1
    fi

    # Verify Flutter installation
    if [[ ! -d "$FLUTTER_DIR/bin" ]]; then
        print_error "Flutter bin directory not found after clone"
        return 1
    fi

    # Add Flutter to PATH
    export PATH="$PATH:$FLUTTER_DIR/bin"

    # Update shell profiles
    print_status "Updating shell profiles..."
    local flutter_path_line="export PATH=\"\$PATH:\$HOME/Development/flutter/bin\""

    if [[ -f ~/.zprofile ]]; then
        if ! grep -q "flutter/bin" ~/.zprofile; then
            echo "$flutter_path_line" >> ~/.zprofile
            print_status "Added Flutter to ~/.zprofile"
        fi
    fi

    if [[ -f ~/.bash_profile ]]; then
        if ! grep -q "flutter/bin" ~/.bash_profile; then
            echo "$flutter_path_line" >> ~/.bash_profile
            print_status "Added Flutter to ~/.bash_profile"
        fi
    fi

    # Verify Flutter installation
    if ! validate_install flutter "Flutter"; then
        return 1
    fi

    print_success "Flutter installed successfully"
}

# Function to install development tools
install_dev_tools() {
    print_section "Installing Development Tools"

    local tools=("tmux" "ranger" "mc" "vim" "htop" "git" "curl" "wget" "ripgrep" "fzf" "bat" "exa")
    local failed_tools=()

    for tool in "${tools[@]}"; do
        if command_exists "$tool"; then
            print_success "$tool is already installed"
        else
            print_status "Installing $tool..."
            if brew install "$tool"; then
                if validate_install "$tool" "$tool"; then
                    print_success "$tool installation verified"
                else
                    failed_tools+=("$tool")
                fi
            else
                print_warning "Failed to install $tool, continuing..."
                failed_tools+=("$tool")
            fi
        fi
    done

    if [[ ${#failed_tools[@]} -gt 0 ]]; then
        print_warning "Failed to install: ${failed_tools[*]}"
        print_warning "You may need to install these manually later"
    else
        print_success "All development tools installed successfully"
    fi
}

# Function to install and configure oh-my-zsh
install_ohmyzsh() {
    print_section "Installing and Configuring oh-my-zsh"

    # Check if zsh is available
    if ! command_exists zsh; then
        print_error "zsh is not installed"
        return 1
    fi

    # Check if Zsh is the default shell
    if [[ "$SHELL" != *"zsh"* ]]; then
        print_status "Changing default shell to Zsh..."
        if ! chsh -s /bin/zsh; then
            print_error "Failed to change default shell"
            return 1
        fi
        print_success "Default shell changed to Zsh. Please restart your terminal."
    fi

    # Install oh-my-zsh if not already installed
    if [[ -d ~/.oh-my-zsh ]]; then
        print_success "oh-my-zsh is already installed"
    else
        print_status "Installing oh-my-zsh..."

        # Download and verify installer
        local install_script
        install_script=$(mktemp) || { print_error "Failed to create temp file"; return 1; }
        trap "rm -f '$install_script'" RETURN

        if ! retry_command $MAX_RETRIES curl -fsSL \
            https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh \
            -o "$install_script"; then
            print_error "Failed to download oh-my-zsh installer"
            return 1
        fi

        if ! sh "$install_script" "" --unattended; then
            print_error "oh-my-zsh installation failed"
            return 1
        fi

        if [[ ! -d ~/.oh-my-zsh ]]; then
            print_error "oh-my-zsh directory not found after installation"
            return 1
        fi

        print_success "oh-my-zsh installed successfully"
    fi

    # Install useful oh-my-zsh plugins
    print_status "Installing oh-my-zsh plugins..."

    # Verify plugins directory exists
    mkdir -p ~/.oh-my-zsh/custom/plugins

    # zsh-syntax-highlighting
    if [[ ! -d ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting ]]; then
        print_status "Installing zsh-syntax-highlighting..."
        if retry_command $MAX_RETRIES git clone https://github.com/zsh-users/zsh-syntax-highlighting.git \
            ~/.oh-my-zsh/custom/plugins/zsh-syntax-highlighting; then
            print_success "zsh-syntax-highlighting installed"
        else
            print_warning "Failed to install zsh-syntax-highlighting"
        fi
    else
        print_success "zsh-syntax-highlighting already installed"
    fi

    # zsh-autosuggestions
    if [[ ! -d ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions ]]; then
        print_status "Installing zsh-autosuggestions..."
        if retry_command $MAX_RETRIES git clone https://github.com/zsh-users/zsh-autosuggestions \
            ~/.oh-my-zsh/custom/plugins/zsh-autosuggestions; then
            print_success "zsh-autosuggestions installed"
        else
            print_warning "Failed to install zsh-autosuggestions"
        fi
    else
        print_success "zsh-autosuggestions already installed"
    fi
}

# Function to setup configuration files
setup_config_files() {
    print_section "Setting up Configuration Files"

    # Create .config directory if it doesn't exist
    if ! mkdir -p ~/.config; then
        print_error "Failed to create ~/.config directory"
        return 1
    fi

    # Setup Vim configuration
    if [[ -f ~/.vimrc ]]; then
        print_warning "~/.vimrc already exists, skipping"
    else
        print_status "Creating basic Vim configuration..."
        local vimrc_file=~/.vimrc
        if ! cat > "$vimrc_file" << 'EOF'
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
        then
            print_error "Failed to create Vim configuration"
            return 1
        fi
        print_success "Vim configuration created at ~/.vimrc"
    fi

    # Setup tmux configuration if dotfiles includes it
    if [[ -f ./.tmux/.tmux.conf ]]; then
        if [[ -L ~/.tmux.conf ]] || [[ -f ~/.tmux.conf ]]; then
            print_warning "~/.tmux.conf already exists, skipping"
        else
            print_status "Linking tmux configuration..."
            mkdir -p ~/.tmux
            if ! ln -sf "$(pwd)/.tmux/.tmux.conf" ~/.tmux.conf; then
                print_error "Failed to create tmux configuration symlink"
                return 1
            fi
            print_success "tmux configuration linked"
        fi
    fi
}

# Function to setup shell profile
setup_shell_profile() {
    print_section "Setting up Shell Profile"

    local zsh_rc=~/.zshrc

    if [[ ! -f "$zsh_rc" ]]; then
        print_warning "$zsh_rc not found, creating default oh-my-zsh config..."
        if ! touch "$zsh_rc"; then
            print_error "Failed to create $zsh_rc"
            return 1
        fi
    fi

    # Backup shell profile before modifications
    if ! cp "$zsh_rc" "${zsh_rc}.backup.$(date +%s)"; then
        print_warning "Failed to backup $zsh_rc"
    fi

    # Add helpful aliases
    if ! grep -q "alias ll=" "$zsh_rc"; then
        print_status "Adding useful aliases to $zsh_rc..."
        if ! cat >> "$zsh_rc" << 'EOF'

# Custom aliases
alias ll='ls -lah'
alias la='ls -A'
alias l='ls -CF'
alias cd..='cd ..'
alias mkdir='mkdir -p'
EOF
        then
            print_error "Failed to add aliases to $zsh_rc"
            return 1
        fi
        print_success "Aliases added"
    fi

    # Add development paths if needed
    if ! grep -q "Development/flutter" "$zsh_rc"; then
        print_status "Adding development paths to $zsh_rc..."
        if ! cat >> "$zsh_rc" << 'EOF'

# Flutter and Android Development
export PATH="$PATH:$HOME/Development/flutter/bin"
export ANDROID_SDK_ROOT=/opt/homebrew/share/android-sdk
export ANDROID_HOME=$ANDROID_SDK_ROOT
EOF
        then
            print_error "Failed to add development paths to $zsh_rc"
            return 1
        fi
        print_success "Development paths added"
    fi
}

# Function to configure oh-my-zsh plugins
configure_ohmyzsh_plugins() {
    print_section "Configuring oh-my-zsh Plugins"

    local zsh_rc=~/.zshrc

    if [[ ! -f "$zsh_rc" ]]; then
        print_warning "$zsh_rc not found, skipping plugin configuration"
        return 1
    fi

    # Update plugins list
    if grep -q "^plugins=" "$zsh_rc"; then
        print_status "Updating oh-my-zsh plugins in $zsh_rc..."
        if ! sed -i '' 's/^plugins=.*/plugins=(git brew extract zsh-syntax-highlighting zsh-autosuggestions colored-man-pages)/' "$zsh_rc"; then
            print_error "Failed to update plugins in $zsh_rc"
            return 1
        fi
        print_success "Plugins configured successfully"
    else
        print_warning "Could not find plugins configuration in $zsh_rc"
        print_status "Adding plugin configuration..."
        if ! cat >> "$zsh_rc" << 'EOF'

# Oh My Zsh Plugins
plugins=(git brew extract zsh-syntax-highlighting zsh-autosuggestions colored-man-pages)
EOF
        then
            print_error "Failed to add plugins configuration"
            return 1
        fi
    fi
}

# Function to run Flutter doctor
run_flutter_doctor() {
    print_section "Running Flutter Doctor"

    if command_exists flutter; then
        print_status "Running flutter doctor..."
        if flutter doctor; then
            print_success "Flutter doctor check passed"
        else
            print_warning "Flutter doctor found some issues - review above"
        fi
    else
        print_warning "Flutter not found in PATH, skipping flutter doctor"
        print_status "Run: source ~/.zshrc && flutter doctor"
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

        # Initialize log file
        : > "$LOG_FILE"
        log_message "Setup started"

        # Pre-flight checks
        print_section "Pre-flight Checks"
        check_macos || return 1
        check_internet || return 1
        check_disk_space || return 1

        # Step 1: Xcode CLI Tools
        print_section "Step 1/11: Xcode Command Line Tools"
        install_xcode_cli || return 1

        # Step 2: Homebrew
        print_section "Step 2/11: Homebrew Package Manager"
        install_homebrew || return 1

        # Step 3: Java
        print_section "Step 3/11: Java/OpenJDK"
        install_java || return 1

        # Step 4: Development Tools
        print_section "Step 4/11: Development Tools"
        install_dev_tools || return 1

        # Step 5: Flutter
        print_section "Step 5/11: Flutter SDK"
        install_flutter || return 1

        # Step 6: Oh-my-zsh
        print_section "Step 6/11: oh-my-zsh Shell Framework"
        install_ohmyzsh || return 1

        # Step 7: Configure oh-my-zsh plugins
        print_section "Step 7/11: Configuring oh-my-zsh Plugins"
        configure_ohmyzsh_plugins || return 1

        # Step 8: Setup configuration files
        print_section "Step 8/11: Configuration Files"
        setup_config_files || return 1

        # Step 9: Setup shell profile
        print_section "Step 9/11: Shell Profile Setup"
        setup_shell_profile || return 1

        # Step 10: Android SDK (optional prompt)
        print_section "Step 10/11: Android SDK (Optional)"
        install_android_sdk || true  # Optional, don't fail if user skips

        # Step 11: Run Flutter Doctor
        print_section "Step 11/11: Flutter Doctor Verification"
        run_flutter_doctor || true  # Doctor may report issues but installation is still valid

        log_message "Setup completed successfully"

        print_section "Setup Complete!"

        echo -e "${GREEN}✓ macOS M4 development environment is ready!${NC}"
        echo ""
        echo "Installed components:"
        echo "  ✓ Homebrew - Package manager"
        echo "  ✓ Xcode CLI Tools - Development tools"
        echo "  ✓ Java (OpenJDK 17) - Programming language"
        echo "  ✓ Flutter SDK - Mobile framework"
        echo "  ✓ Development tools - tmux, ranger, mc, vim, htop, ripgrep, fzf, bat, exa"
        echo "  ✓ oh-my-zsh - Shell framework with plugins"
        echo ""
        echo "Next steps:"
        echo "  1. Restart your terminal: exec zsh"
        echo "  2. Verify setup: flutter doctor"
        echo "  3. Configure IDE (VS Code, Android Studio, Xcode)"
        echo "  4. Create first project: flutter create my_app"
        echo ""
        echo "Log file: $LOG_FILE"
        echo ""
        echo "Documentation:"
        echo "  - Flutter: https://flutter.dev/docs"
        echo "  - Android Setup: https://flutter.dev/docs/get-started/install/macos#android-setup"
        echo "  - oh-my-zsh: https://ohmyz.sh/"
        echo "  - Homebrew: https://brew.sh"
    fi
}

# Run main function
main "$@"
