#!/bin/bash
# Terminal Anywhere Client Installation Script
# One-command installation: curl -L https://raw.githubusercontent.com/scantrancher/terminal-anywhere/main/install-client.sh | bash

set -e

# Configuration
REPO_URL="https://raw.githubusercontent.com/scantrancher/terminal-anywhere/main"
BINARY_NAME="terminal_anywhere_client"
INSTALL_DIR="$HOME/.local/bin"
VERSION_URL="$REPO_URL/version.json"
RELEASE_TAG="${TA_RELEASE_TAG:-}"

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
get_download_urls() {
    local platform=$1
    local binary_file="${BINARY_NAME}-${platform}"
    # Prefer GitHub Releases assets
    if [ -n "$RELEASE_TAG" ]; then
        echo "https://github.com/scantrancher/terminal-anywhere/releases/download/${RELEASE_TAG}/${binary_file}"
    else
        echo "https://github.com/scantrancher/terminal-anywhere/releases/latest/download/${binary_file}"
    fi
    # Fallback to raw (may be LFS pointer if quota exceeded)
    echo "https://raw.githubusercontent.com/scantrancher/terminal-anywhere/main/latest/${binary_file}"
}

# Validate that a downloaded file is a real binary, not an LFS pointer
is_valid_binary() {
    local path="$1"
    [ -f "$path" ] && [ -s "$path" ] || return 1
    if head -n 1 "$path" | grep -qi "git-lfs.github.com/spec/v1"; then
        return 1
    fi
    if command -v xxd >/dev/null 2>&1; then
        local magic
        magic=$(xxd -p -l 4 "$path" 2>/dev/null | tr '[:lower:]' '[:upper:]')
        case "$magic" in
            7F454C46) return 0 ;;
            CFFAEDFE) return 0 ;;
            CEFAEDFE) return 0 ;;
            FEEDFACF) return 0 ;;
            FEEDFACE) return 0 ;;
        esac
    fi
    if [ $(wc -c <"$path") -lt 4096 ]; then
        return 1
    fi
    return 0
}

# Download and install binary
install_binary() {
    local platform=$1
    local final_path="${INSTALL_DIR}/${BINARY_NAME}"
    local temp_file
    temp_file=$(mktemp "/tmp/${BINARY_NAME}.XXXXXX")

    print_info "Downloading Terminal Anywhere Client..."
    mkdir -p "$INSTALL_DIR"

    local url
    local success=0
    while IFS= read -r url; do
        [ -n "$url" ] || continue
        print_info "Attempting download: $url"
        if command -v curl >/dev/null 2>&1; then
            if curl -fL -o "$temp_file" "$url"; then
                if is_valid_binary "$temp_file"; then
                    success=1
                    break
                else
                    print_warning "Downloaded file is not a valid binary (likely LFS pointer)."
                fi
            else
                print_warning "Download failed from: $url"
            fi
        elif command -v wget >/dev/null 2>&1; then
            if wget -q -O "$temp_file" "$url"; then
                if is_valid_binary "$temp_file"; then
                    success=1
                    break
                else
                    print_warning "Downloaded file is not a valid binary (likely LFS pointer)."
                fi
            else
                print_warning "Download failed from: $url"
            fi
        else
            print_error "Neither curl nor wget is available. Please install one of them."
            rm -f "$temp_file"
            exit 1
        fi
    done < <(get_download_urls "$platform")

    if [ "$success" -ne 1 ]; then
        print_error "Unable to download a valid binary for $platform."
        print_info "Tried URLs:"
        get_download_urls "$platform"
        rm -f "$temp_file"
        exit 1
    fi

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
    
    # Optional --tag argument to pin a specific release
    if [ "$1" = "--tag" ] && [ -n "$2" ]; then
        RELEASE_TAG="$2"
        shift 2
        print_info "Using release tag: $RELEASE_TAG"
    elif [ -n "$RELEASE_TAG" ]; then
        print_info "Using release tag from TA_RELEASE_TAG: $RELEASE_TAG"
    fi
    
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
    
    # Check for existing installation
    if [ -f "${INSTALL_DIR}/${BINARY_NAME}" ]; then
        print_warning "Existing installation found. Updating..."
    fi
    
    # Install binary
    install_binary "$platform"
    
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
    echo ""
    echo "Advanced:"
    echo "  Use a specific release tag via env or flag:"
    echo "    TA_RELEASE_TAG=v1.24.4 curl -L https://raw.githubusercontent.com/scantrancher/terminal-anywhere/main/install-client.sh | bash"
    echo "    curl -L https://raw.githubusercontent.com/scantrancher/terminal-anywhere/main/install-client.sh | bash -s -- --tag v1.24.4"
    exit 0
fi

# Run main installation
main
