# Branch Structure Documentation

This document explains the branch structure of this dotfiles repository.

## Overview

This repository maintains separate branches for different operating systems to accommodate platform-specific configurations and tools.

## Branches

### `master` / `main`
The default branch that contains:
- Common configuration files (`.vimrc`, `.tmux/.tmux.conf`)
- Branch setup automation script (`scripts/setup-branches.sh`)
- Documentation about the branch structure

This branch serves as the starting point. Users should checkout the appropriate platform-specific branch for their system.

### `linux`
Linux-specific branch containing:
- **Suckless tools** (as git submodules):
  - `dwm` - Dynamic window manager
  - `st` - Simple terminal
  - `slstatus` - Status bar utility
- **Installation script**: `scripts/install.sh`
  - Uses `apt` package manager (Debian/Ubuntu)
  - Installs X11 development libraries
  - Builds and installs suckless tools
- **Autostart script**: `scripts/autostart.sh`
  - Launches picom (compositor)
  - Launches guake (terminal)
  - Launches slstatus (status bar)
- **Build dependencies**: X11, Xft, Xinerama, Fontconfig

**Target systems**: Debian, Ubuntu, and other apt-based Linux distributions

### `ios`
iOS/macOS-specific branch containing:
- **Installation script**: `scripts/install-macos.sh`
  - Uses Homebrew package manager
  - Installs CLI tools (git, vim, tmux, neovim, ripgrep, fzf)
  - Installs GUI applications (iTerm2, VS Code)
  - Sets up dotfiles
- **No Linux-specific tools**: The dwm, st, and slstatus submodules are removed
- **macOS-friendly setup**: Optimized for macOS 10.14+

**Target systems**: macOS, potentially iOS (with adaptations)

## Usage

### Initial Setup

1. Clone the repository:
   ```sh
   git clone https://github.com/s4pun1s7/.dotfiles.git
   cd .dotfiles
   ```

2. Create platform-specific branches (if they don't exist remotely):
   ```sh
   ./scripts/setup-branches.sh -c
   ```

3. Checkout the branch for your platform:
   ```sh
   # For Linux
   git checkout linux
   
   # For macOS
   git checkout ios
   ```

4. Run the installation script:
   ```sh
   # Linux
   ./scripts/install.sh
   
   # macOS
   ./scripts/install-macos.sh
   ```

### Switching Between Branches

You can switch between branches at any time:

```sh
# Switch to Linux configuration
git checkout linux

# Switch to macOS configuration
git checkout ios

# Return to master branch
git checkout master
```

### Updating

To update your dotfiles:

```sh
# Update the repository
git pull

# For Linux branch with submodules
git submodule update --init --recursive

# Run the installation script again if needed
./scripts/install.sh  # or ./scripts/install-macos.sh for macOS
```

## Branch Management

### Creating Branches Locally

The `scripts/setup-branches.sh` script automates branch creation:

```sh
# Create both branches
./scripts/setup-branches.sh -c

# Create only Linux branch
./scripts/setup-branches.sh -l

# Create only iOS branch
./scripts/setup-branches.sh -i
```

### Pushing Branches to Remote

After creating branches locally, you may want to push them:

```sh
git push origin linux
git push origin ios
```

## Adding Platform-Specific Configurations

### For Linux Branch

1. Checkout the linux branch:
   ```sh
   git checkout linux
   ```

2. Add your configurations or modify existing ones

3. Commit your changes:
   ```sh
   git add .
   git commit -m "Add/Update Linux-specific configuration"
   git push origin linux
   ```

### For iOS/macOS Branch

1. Checkout the ios branch:
   ```sh
   git checkout ios
   ```

2. Add your configurations or modify existing ones

3. Commit your changes:
   ```sh
   git add .
   git commit -m "Add/Update macOS-specific configuration"
   git push origin ios
   ```

### For Common Configurations

If you have configurations that are common to all platforms:

1. Add them to the master branch
2. Cherry-pick or merge them into specific branches as needed

## Key Differences

| Feature | Linux Branch | iOS Branch |
|---------|-------------|-----------|
| Window Manager | dwm | Native macOS |
| Terminal | st | iTerm2 |
| Status Bar | slstatus | Native macOS |
| Package Manager | apt | Homebrew |
| Installation Script | install.sh | install-macos.sh |
| X11 Dependencies | ✓ | ✗ |
| Git Submodules | ✓ (dwm, st, slstatus) | ✗ |

## Troubleshooting

### Branches Not Found

If the linux or ios branches don't exist:
1. Make sure you've fetched all remote branches: `git fetch --all`
2. Create them locally using the setup script: `./scripts/setup-branches.sh -c`

### Submodule Issues (Linux)

If submodules are not initializing:
```sh
git submodule update --init --recursive
```

### Homebrew Not Found (macOS)

The install-macos.sh script will install Homebrew automatically if it's not present.

## Future Enhancements

Potential improvements for the branch structure:
- Add support for other Linux distributions (Arch, Fedora, etc.)
- Add Windows/WSL branch
- Automate branch synchronization for common files
- Add CI/CD for testing installations on different platforms
