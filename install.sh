#!/bin/bash
# Terminal Anywhere Interactive Installation Script
# One-command installation: curl -L https://raw.githubusercontent.com/scantrancher/terminal-anywhere/main/install.sh | bash

set -e

# Configuration
REPO_URL="https://raw.githubusercontent.com/scantrancher/terminal-anywhere/main"
INSTALL_DIR="$HOME/.local/bin"

# Colors for output (only if terminal supports it)
if [ -t 1 ] && [ -t 0 ]; then
    RED='\033[0;31m'
    GREEN='\033[0;32m'
    YELLOW='\033[1;33m'
    BLUE='\033[0;34m'
    CYAN='\033[0;36m'
    BOLD='\033[1m'
    NC='\033[0m' # No Color
else
    # No colors for non-interactive sessions
    RED=''
    GREEN=''
    YELLOW=''
    BLUE=''
    CYAN=''
    BOLD=''
    NC=''
fi

# Helper functions
print_info() { echo -e "${BLUE}ℹ${NC} $1"; }
print_success() { echo -e "${GREEN}✅${NC} $1"; }
print_warning() { echo -e "${YELLOW}⚠${NC} $1"; }
print_error() { echo -e "${RED}❌${NC} $1"; }
print_header() { echo -e "${CYAN}${BOLD}$1${NC}"; }

# Interactive menu
show_menu() {
    clear
    print_header "🚀 Terminal Anywhere Installer"
    echo "=========================================="
    echo ""
    print_info "What would you like to install?"
    echo ""
    echo "  ${BOLD}1)${NC} Server only   - Host terminals for remote access"
    echo "  ${BOLD}2)${NC} Client only   - Connect to remote terminals"
    echo "  ${BOLD}3)${NC} Both          - Full Terminal Anywhere suite"
    echo "  ${BOLD}4)${NC} Help          - Show detailed information"
    echo "  ${BOLD}q)${NC} Quit          - Exit installer"
    echo ""
}

# Show help information
show_help() {
    clear
    print_header "📚 Terminal Anywhere Help"
    echo "============================================"
    echo ""
    print_info "What is Terminal Anywhere?"
    echo "A secure, high-performance terminal streaming system that allows you to"
    echo "access and share terminal sessions from anywhere with sub-20ms latency."
    echo ""
    print_info "Components:"
    echo ""
    echo "${BOLD}Server (terminal_anywhere_server):${NC}"
    echo "  • Hosts terminal sessions via WebSocket"
    echo "  • Provides secure web-based terminal interface"
    echo "  • Supports session persistence and sharing"
    echo "  • Auto-generates secure access tokens"
    echo ""
    echo "${BOLD}Client (terminal_anywhere_client):${NC}"
    echo "  • Native terminal interface with rich text rendering"
    echo "  • Connects to any Terminal Anywhere server"
    echo "  • Session management and resumption"
    echo "  • Cross-platform (Linux, macOS, Windows via WSL)"
    echo ""
    print_info "Use Cases:"
    echo "  • Remote server administration"
    echo "  • Collaborative debugging and development"
    echo "  • Persistent terminal sessions"
    echo "  • Secure terminal sharing"
    echo "  • Development environment access"
    echo ""
    print_info "Security Features:"
    echo "  • Token-based authentication"
    echo "  • Localhost bypass (no token needed locally)"
    echo "  • Rate limiting and IP blocking"
    echo "  • Input validation and sanitization"
    echo ""
    echo "Press Enter to return to main menu..."
    read
}

# Install server
install_server() {
    print_info "Installing Terminal Anywhere Server..."
    curl -L -s "${REPO_URL}/install-server.sh" | bash
}

# Install client
install_client() {
    print_info "Installing Terminal Anywhere Client..."
    curl -L -s "${REPO_URL}/install-client.sh" | bash
}

# Install both
install_both() {
    print_info "Installing complete Terminal Anywhere suite..."
    echo ""
    install_server
    echo ""
    print_info "Now installing client..."
    echo ""
    install_client
    echo ""
    print_success "Complete installation finished!"
    echo ""
    print_info "Quick Start Guide:"
    echo "  1. Start server: terminal_anywhere_server --bind-all"
    echo "  2. Note the access token displayed"
    echo "  3. Connect client: terminal_anywhere_client ws://server-ip:7860/ws --token TOKEN"
    echo ""
    print_info "Or access via web browser:"
    echo "  http://server-ip:7860/terminal?token=TOKEN"
}

# Check if we can run interactively
check_interactive() {
    if [ ! -t 0 ] || [ ! -t 1 ]; then
        print_warning "Non-interactive session detected (likely piped through curl)"
        # Honor CLI arg if provided: server|client|both
        case "$1" in
            server)
                print_info "Installing server only (arg: server)"
                echo ""
                install_server
                ;;
            client)
                print_info "Installing client only (arg: client)"
                echo ""
                install_client
                ;;
            both|"")
                print_info "Installing both server and client (default)"
                echo ""
                install_both
                ;;
            *)
                print_warning "Unknown argument: $1. Expected: server | client | both"
                print_info "Proceeding with full installation (both)."
                echo ""
                install_both
                ;;
        esac
        exit 0
    fi
}

# Main interactive loop
main() {
    check_interactive "$1"
    while true; do
        show_menu
        printf "Enter your choice [1-4, q]: "
        read -r choice
        
        case $choice in
            1)
                echo ""
                install_server
                echo ""
                print_info "Press Enter to continue..."
                read
                ;;
            2)
                echo ""
                install_client
                echo ""
                print_info "Press Enter to continue..."
                read
                ;;
            3)
                echo ""
                install_both
                echo ""
                print_info "Press Enter to continue..."
                read
                ;;
            4)
                show_help
                ;;
            [qQ])
                print_info "Thanks for using Terminal Anywhere!"
                exit 0
                ;;
            *)
                print_warning "Invalid option. Please choose 1-4 or q."
                sleep 2
                ;;
        esac
    done
}

# Show usage information for piped execution
if [ ! -t 0 ]; then
    echo "Terminal Anywhere Installation"
    echo "============================="
    echo ""
    echo "💡 TIP: For interactive installation, download and run directly:"
    echo "  wget https://raw.githubusercontent.com/scantrancher/terminal-anywhere/main/install.sh"
    echo "  chmod +x install.sh"
    echo "  ./install.sh"
    echo ""
    echo "Or use command line arguments:"
    echo "  curl -L https://raw.githubusercontent.com/scantrancher/terminal-anywhere/main/install.sh | bash -s server"
    echo "  curl -L https://raw.githubusercontent.com/scantrancher/terminal-anywhere/main/install.sh | bash -s client"
    echo "  curl -L https://raw.githubusercontent.com/scantrancher/terminal-anywhere/main/install.sh | bash -s both"
    echo ""
fi

# Non-interactive mode based on arguments
if [ $# -gt 0 ]; then
    case "$1" in
        server)
            install_server
            ;;
        client)
            install_client
            ;;
        both)
            install_both
            ;;
        --help|-h)
            show_help
            exit 0
            ;;
        *)
            print_error "Unknown option: $1"
            print_info "Usage: $0 [server|client|both|--help]"
            exit 1
            ;;
    esac
else
    # Interactive mode
    main
fi
