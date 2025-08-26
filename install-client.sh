#!/bin/bash
# Terminal Anywhere Client Installation Script
# One-command installation: curl -L https://raw.githubusercontent.com/scantrancher/terminal-anywhere/main/install-client.sh | bash

set -e

# Configuration
REPO_URL="https://raw.githubusercontent.com/scantrancher/terminal-anywhere/main"
BINARY_NAME="terminal_anywhere_client"
INSTALL_DIR="$HOME/.local/bin"
VERSION_URL="$REPO_URL/version.json"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Helper functions
print_info() { echo -e "${BLUE}ℹ${NC} $1"; }
print_success() { echo -e "${GREEN}✅${NC} $1"; }
print_warning() { echo -e "${YELLOW}⚠${NC} $1"; }
print_error() { echo -e "${RED}❌${NC} $1"; }

# Detect platform
detect_platform() {
    local os_type=$(uname -s | tr '[:upper:]' '[:lower:]')
    local arch_type=$(uname -m)
    
    case "$os_type" in
        linux*)
            case "$arch_type" in
                x86_64|amd64) echo "linux-x64" ;;
                aarch64|arm64) echo "unsupported" ;;  # Temporarily disabled
                *) echo "unsupported" ;;
            esac
            ;;
        darwin*)
            case "$arch_type" in
                x86_64) echo "macos-x64" ;;
                arm64) echo "macos-arm64" ;;  # M1/M2 Macs re-enabled
                *) echo "unsupported" ;;
            esac
            ;;
        *)
            echo "unsupported"
            ;;
    esac
}

# Check if binary exists and get download URL
get_download_url() {
    local platform=$1
    local binary_file="${BINARY_NAME}-${platform}"
    local url="https://raw.githubusercontent.com/scantrancher/terminal-anywhere/main/latest/${binary_file}"
    
    # Return the URL directly - let the download function handle validation
    echo "$url"
    return 0
}

# Download and install binary
install_binary() {
    local download_url=$1
    local platform=$2
    local temp_file="/tmp/${BINARY_NAME}"
    local final_path="${INSTALL_DIR}/${BINARY_NAME}"
    
    print_info "Downloading Terminal Anywhere Client..."
    
    # Create install directory
    mkdir -p "$INSTALL_DIR"
    
    # Download binary
    print_info "Downloading $BINARY_NAME..."
    if command -v curl >/dev/null 2>&1; then
        if ! curl -L -o "$temp_file" "$download_url"; then
            print_error "Download failed. Please check your internet connection and try again."
            print_info "URL: $download_url"
            exit 1
        fi
    elif command -v wget >/dev/null 2>&1; then
        if ! wget -O "$temp_file" "$download_url"; then
            print_error "Download failed. Please check your internet connection and try again."
            print_info "URL: $download_url"
            exit 1
        fi
    else
        print_error "Neither curl nor wget is available. Please install one of them."
        exit 1
    fi
    
    # Verify download
    if [ ! -f "$temp_file" ] || [ ! -s "$temp_file" ]; then
        print_error "Download failed or file is empty"
        exit 1
    fi
    
    # Move to install location and make executable
    mv "$temp_file" "$final_path"
    chmod +x "$final_path"
    
    print_success "Terminal Anywhere Client installed to: $final_path"
}

# Check if install directory is in PATH
check_path() {
    if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
        print_warning "Install directory $INSTALL_DIR is not in your PATH"
        print_info "Add this line to your ~/.bashrc or ~/.zshrc:"
        echo ""
        echo "    export PATH=\"\$PATH:$INSTALL_DIR\""
        echo ""
        print_info "Then reload your shell: source ~/.bashrc"
    fi
}

# Show usage instructions
show_usage() {
    print_success "Installation complete!"
    echo ""
    print_info "Usage:"
    echo "  # Connect to server"
    echo "  $BINARY_NAME ws://server-ip:7860/ws --token TOKEN"
    echo ""
    echo "  # Connect to localhost (no token needed)"
    echo "  $BINARY_NAME ws://127.0.0.1:7860/ws"
    echo ""
    echo "  # List available sessions"
    echo "  $BINARY_NAME list ws://server-ip:7860/ws --token TOKEN"
    echo ""
    echo "  # Resume a session"
    echo "  $BINARY_NAME resume ws://server-ip:7860/ws session-id --token TOKEN"
    echo ""
    echo "  # Show help"
    echo "  $BINARY_NAME --help"
    echo ""
    print_info "Exit controls:"
    echo "  - Double Ctrl+C (within 2 seconds): Disconnect from server"
    echo "  - Single Ctrl+C: Send interrupt to remote terminal"
    echo "  - Ctrl+D: Send EOF to remote terminal"
    echo ""
    print_info "Session sharing:"
    echo "  - Multiple clients can connect to the same session"
    echo "  - Sessions persist when clients disconnect"
    echo "  - Use partial session IDs for easier resume commands"
    echo ""
    print_info "Web terminal access:"
    echo "  - Local: http://server-ip:7860/terminal"
    echo "  - Network: http://server-ip:7860/terminal?token=TOKEN"
    echo "  - Resume: http://server-ip:7860/terminal?token=TOKEN&resume=session-id"
}

# Main installation process
main() {
    echo ""
    print_info "Terminal Anywhere Client Installer"
    echo "=================================="
    
    # Detect platform
    local platform=$(detect_platform)
    if [ "$platform" = "unsupported" ]; then
        print_error "Unsupported platform: $(uname -s) $(uname -m)"
        print_info "Supported platforms:"
        echo "  - Linux x64 (Intel/AMD)"
        echo "  - Linux ARM64 (Raspberry Pi, ARM servers)"
        echo "  - macOS x64 (Intel Mac)"
        echo "  - macOS ARM64 (Apple Silicon)"
        exit 1
    fi
    
    print_info "Detected platform: $platform"
    
    # Get download URL
    local download_url
    download_url=$(get_download_url "$platform")
    print_info "Downloading binary from: $download_url"
    
    # Check for existing installation
    if [ -f "${INSTALL_DIR}/${BINARY_NAME}" ]; then
        print_warning "Existing installation found. Updating..."
    fi
    
    # Install binary
    install_binary "$download_url" "$platform"
    
    # Check PATH
    check_path
    
    # Show usage
    show_usage
}

# Check for --help flag
if [ "$1" = "--help" ] || [ "$1" = "-h" ]; then
    echo "Terminal Anywhere Client Installer"
    echo ""
    echo "Usage: curl -L https://raw.githubusercontent.com/scantrancher/terminal-anywhere/main/install-client.sh | bash"
    echo ""
    echo "This script will:"
    echo "  1. Detect your platform (Linux/macOS, x64/ARM64)"
    echo "  2. Download the appropriate client binary"
    echo "  3. Install it to ~/.local/bin/terminal_anywhere_client"
    echo "  4. Make it executable"
    echo ""
    echo "Supported platforms:"
    echo "  - Linux x64 (Intel/AMD processors)"
    echo "  - Linux ARM64 (Raspberry Pi, ARM servers)"
    echo "  - macOS x64 (Intel Mac)"
    echo "  - macOS ARM64 (Apple Silicon Mac)"
    exit 0
fi

# Run main installation
main