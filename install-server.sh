#!/bin/bash
# Terminal Anywhere Server Installation Script
# One-command installation: curl -L https://raw.githubusercontent.com/scantrancher/terminal-anywhere/main/install-server.sh | bash

set -e

# Configuration
REPO_URL="https://raw.githubusercontent.com/scantrancher/terminal-anywhere/main"
BINARY_NAME="terminal_anywhere_server"
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
    # Use resolve/main for Git LFS files instead of raw/main
    local url="https://raw.githubusercontent.com/scantrancher/terminal-anywhere/main/latest/${binary_file}"
    
    # Check if URL is accessible
    if command -v curl >/dev/null 2>&1; then
        if curl -sL --head "$url" | head -n 1 | grep -q -E "(200 OK|302 Found)"; then
            echo "$url"
            return 0
        fi
    elif command -v wget >/dev/null 2>&1; then
        if wget -q --spider "$url"; then
            echo "$url"
            return 0
        fi
    fi
    
    return 1
}

# Download and install binary
install_binary() {
    local download_url=$1
    local platform=$2
    local temp_file="/tmp/${BINARY_NAME}"
    local final_path="${INSTALL_DIR}/${BINARY_NAME}"
    
    print_info "Downloading Terminal Anywhere Server..."
    
    # Create install directory
    mkdir -p "$INSTALL_DIR"
    
    # Download binary
    if command -v curl >/dev/null 2>&1; then
        curl -L -o "$temp_file" "$download_url"
    elif command -v wget >/dev/null 2>&1; then
        wget -O "$temp_file" "$download_url"
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
    
    print_success "Terminal Anywhere Server installed to: $final_path"
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
    echo "  # Start server (localhost only)"
    echo "  $BINARY_NAME"
    echo ""
    echo "  # Start server (network accessible)"
    echo "  $BINARY_NAME --bind-all"
    echo ""
    echo "  # Show help"
    echo "  $BINARY_NAME --help"
    echo ""
    print_info "After starting the server:"
    echo "  - Server will display a secure access token"
    echo "  - Use the token to connect clients from other machines"
    echo "  - Localhost connections don't need a token"
    echo ""
    print_info "Connect a client:"
    echo "  # Install client first:"
    echo "  curl -L https://raw.githubusercontent.com/scantrancher/terminal-anywhere/main/install-client.sh | bash"
    echo ""
    echo "  # Then connect:"
    echo "  terminal_anywhere_client ws://server-ip:7860/ws --token TOKEN"
}

# Main installation process
main() {
    echo ""
    print_info "Terminal Anywhere Server Installer"
    echo "=================================="
    
    # Detect platform
    local platform=$(detect_platform)
    if [ "$platform" = "unsupported" ]; then
        print_error "Unsupported platform: $(uname -s) $(uname -m)"
        print_info "Supported platforms:"
        echo "  - Linux x64 (Intel/AMD)"
        # echo "  - Linux ARM64 (Raspberry Pi, ARM servers)"  # Temporarily disabled
        echo "  - macOS x64 (Intel Mac)"
        echo "  - macOS ARM64 (Apple Silicon M1/M2)"
        exit 1
    fi
    
    print_info "Detected platform: $platform"
    
    # Get download URL
    local download_url
    if download_url=$(get_download_url "$platform"); then
        print_info "Binary available at: $download_url"
    else
        print_error "Binary not available for platform: $platform"
        print_info "Please check https://github.com/scantrancher/terminal-anywhere/releases for available releases"
        exit 1
    fi
    
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
    echo "Terminal Anywhere Server Installer"
    echo ""
    echo "Usage: curl -L https://raw.githubusercontent.com/scantrancher/terminal-anywhere/main/install-server.sh | bash"
    echo ""
    echo "This script will:"
    echo "  1. Detect your platform (Linux/macOS, x64/ARM64)"
    echo "  2. Download the appropriate server binary"
    echo "  3. Install it to ~/.local/bin/terminal_anywhere_server"
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