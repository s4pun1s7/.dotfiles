# .dotfiles

This repository contains my personal dotfiles with platform-specific configurations maintained in separate branches.

## Branches

This repository uses different branches for different operating systems:

- **`linux`** - Linux-specific configurations including:
  - [dwm](dwm/) - dynamic window manager
  - [st](st/) - simple terminal  
  - [slstatus](slstatus/) - status bar utility
  - apt-based package installation
  - X11 dependencies
  - Linux-specific autostart scripts (picom, guake, slstatus)

- **`ios`** - iOS/macOS-specific configurations including:
  - Homebrew-based package installation
  - macOS-specific dotfiles
  - iTerm2/Alacritty configurations
  - macOS-specific automation scripts

### Setting Up Branches

To create the platform-specific branches, run:

```sh
./scripts/setup-branches.sh -c
```

This will create both `linux` and `ios` branches with their respective configurations.

### Switching Branches

To use the configurations for your operating system:

```sh
# For Linux
git checkout linux

# For iOS/macOS
git checkout ios
```

## Setup (Master Branch)

This master branch contains the common configuration files and the branch setup script.
Please checkout the appropriate branch for your operating system before installation.

### Linux Branch Setup

For Linux systems, checkout the linux branch:

```sh
git checkout linux
```

Then clone with submodules:

```sh
git clone --recursive https://github.com/s4pun1s7/.dotfiles.git
```

To update submodules:

```sh
git submodule update --init --recursive
./scripts/install.sh
```

### iOS/macOS Branch Setup

For macOS systems, checkout the ios branch:

```sh
git checkout ios
./scripts/install-macos.sh
```

## Usage

Each submodule contains its own README and build instructions. See the respective folders for details.

### Scripts
Custom scripts are in the `scripts/` directory. See `install.sh` for automated setup.

## Project Status

- All submodules are tracked and updated regularly.
- Custom patches and configuration are maintained in this repo.
