#!/bin/bash

# Test Container Script for Dotfiles
# This script helps test the dotfiles installation in a container

set -e

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

# Function to show usage
show_usage() {
    echo "Usage: $0 [OPTIONS]"
    echo ""
    echo "Options:"
    echo "  -h, --help          Show this help message"
    echo "  -b, --build         Build the container"
    echo "  -r, --run           Run the container interactively"
    echo "  -t, --test          Run the install script in container"
    echo "  -c, --clean         Clean up containers and images"
    echo "  -f, --full          Build, run, and test in one command"
    echo ""
    echo "Examples:"
    echo "  $0 -b               # Build container"
    echo "  $0 -r               # Run container interactively"
    echo "  $0 -t               # Test install script"
    echo "  $0 -f               # Full test cycle"
}

# Function to check if Docker is available
check_docker() {
    if ! command -v docker >/dev/null 2>&1; then
        print_error "Docker is not installed or not in PATH"
        exit 1
    fi
    
    if ! command -v docker-compose >/dev/null 2>&1; then
        print_error "Docker Compose is not installed or not in PATH"
        exit 1
    fi
}

# Function to build container
build_container() {
    print_status "Building test container..."
    sudo docker-compose build
    print_success "Container built successfully"
}

# Function to run container interactively
run_container() {
    print_status "Starting interactive container session..."
    print_status "You can now test the install script manually"
    print_status "Type 'exit' to leave the container"
    sudo docker-compose run --rm dotfiles-test
}

# Function to test install script
test_install() {
    print_status "Running install script test..."
    
    # Run the install script with help first
    sudo docker-compose run --rm dotfiles-test ./scripts/install.sh -h
    
    print_status "Testing dependencies installation..."
    sudo docker-compose run --rm dotfiles-test ./scripts/install.sh -d
    
    print_status "Testing full installation..."
    sudo docker-compose run --rm dotfiles-test ./scripts/install.sh -c
    
    print_success "Install script test completed"
}

# Function to clean up
cleanup() {
    print_status "Cleaning up containers and images..."
    sudo docker-compose down --rmi all --volumes --remove-orphans
    sudo docker system prune -f
    print_success "Cleanup completed"
}

# Function to run full test cycle
full_test() {
    print_status "Running full test cycle..."
    build_container
    test_install
    print_success "Full test cycle completed"
}

# Main function
main() {
    local build_flag=false
    local run_flag=false
    local test_flag=false
    local clean_flag=false
    local full_flag=false
    
    # Parse command line arguments
    while [[ $# -gt 0 ]]; do
        case $1 in
            -h|--help)
                show_usage
                exit 0
                ;;
            -b|--build)
                build_flag=true
                shift
                ;;
            -r|--run)
                run_flag=true
                shift
                ;;
            -t|--test)
                test_flag=true
                shift
                ;;
            -c|--clean)
                clean_flag=true
                shift
                ;;
            -f|--full)
                full_flag=true
                shift
                ;;
            *)
                print_error "Unknown option: $1"
                show_usage
                exit 1
                ;;
        esac
    done
    
    # Check if Docker is available
    check_docker
    
    # If no flags provided, show usage
    if [[ "$build_flag" == false && "$run_flag" == false && "$test_flag" == false && "$clean_flag" == false && "$full_flag" == false ]]; then
        show_usage
        exit 0
    fi
    
    # Execute requested actions
    if [[ "$full_flag" == true ]]; then
        full_test
    else
        if [[ "$build_flag" == true ]]; then
            build_container
        fi
        
        if [[ "$run_flag" == true ]]; then
            run_container
        fi
        
        if [[ "$test_flag" == true ]]; then
            test_install
        fi
        
        if [[ "$clean_flag" == true ]]; then
            cleanup
        fi
    fi
}

# Run main function with all arguments
main "$@" 