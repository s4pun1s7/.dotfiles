# .dotfiles

This repository contains my personal dotfiles and custom builds of suckless tools as git submodules:

- [dwm](dwm/) - dynamic window manager
- [st](st/) - simple terminal
- [slstatus](slstatus/) - status bar utility

## Setup

Clone with submodules:

```sh
git clone --recursive https://github.com/s4pun1s7/.dotfiles.git
```

To update submodules:

```sh
git submodule update --init --recursive
```

## Usage

Each submodule contains its own README and build instructions. See the respective folders for details.

### Scripts
Custom scripts are in the `scripts/` directory. See `install.sh` for automated setup.

## Project Status

- All submodules are tracked and updated regularly.
- Custom patches and configuration are maintained in this repo.
