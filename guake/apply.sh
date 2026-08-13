#!/bin/bash

# Guake configuration apply/dump script
# Guake stores its settings in dconf (/apps/guake/), not in a config file,
# so guake.dconf is the tracked snapshot of the theme.

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

GUAKE_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DCONF_FILE="$GUAKE_DIR/guake.dconf"
DCONF_PATH="/apps/guake/"

show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help    Show this help message"
    echo "  -d, --dump    Dump the current guake settings back into guake.dconf"
    echo ""
    echo "With no options the tracked settings are loaded into dconf."
}

apply_config() {
    if [[ ! -f "$DCONF_FILE" ]]; then
        print_error "guake.dconf not found"
        exit 1
    fi

    print_status "Loading guake settings into $DCONF_PATH..."
    dconf load "$DCONF_PATH" < "$DCONF_FILE"
    print_success "Guake settings applied"

    if pgrep -f '/usr/bin/guake' >/dev/null; then
        print_warning "Guake is running; restart it (guake --restart) to hide the tab bar"
    fi
}

dump_config() {
    print_status "Dumping $DCONF_PATH into guake.dconf..."
    dconf dump "$DCONF_PATH" > "$DCONF_FILE"
    print_success "Guake settings dumped"
}

main() {
    if ! command -v dconf >/dev/null 2>&1; then
        print_error "dconf not found, install it first"
        exit 1
    fi

    case "${1:-}" in
        -h|--help)
            show_usage
            ;;
        -d|--dump)
            dump_config
            ;;
        "")
            apply_config
            ;;
        *)
            print_error "Unknown option: $1"
            show_usage
            exit 1
            ;;
    esac
}

main "$@"
