#!/usr/bin/env bash
#
# Cross-platform jq installer for Maven Flow
# Supports: Windows (Git Bash/MSYS2), macOS, Linux
#
# Usage: curl -fsSL https://raw.githubusercontent.com/your-repo/main/install/install-jq.sh | bash
# Or: ./install-jq.sh
#

set -e

JQ_VERSION="1.8.1"
JQ_DOWNLOAD_BASE="https://github.com/jqlang/jq/releases/download/jq-${JQ_VERSION}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

info() {
    echo -e "${GREEN}[INFO]${NC} $1"
}

warn() {
    echo -e "${YELLOW}[WARN]${NC} $1"
}

error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Detect OS
detect_os() {
    case "$(uname -s)" in
        Linux*)     OS=linux;;
        Darwin*)    OS=macos;;
        MINGW*|MSYS*|CYGWIN*) OS=windows;;
        *)          OS="unknown:${uname -s}"
    esac
    info "Detected OS: $OS"
}

# Check if jq is already installed
check_jq_installed() {
    if command -v jq &> /dev/null; then
        JQ_VERSION_INSTALLED=$(jq --version 2>/dev/null || echo "unknown")
        info "jq is already installed: $JQ_VERSION_INSTALLED"
        return 0
    else
        return 1
    fi
}

# Detect machine architecture
detect_arch() {
    case "$(uname -m)" in
        x86_64|amd64)  ARCH="amd64";;
        i386|i686)     ARCH="i386";;
        aarch64|arm64) ARCH="arm64";;
        armv7l)        ARCH="arm";;
        *)             ARCH="unknown";;
    esac
    info "Detected architecture: $ARCH"
}

# Install jq using package manager (preferred method)
install_with_package_manager() {
    info "Attempting to install jq using package manager..."

    case "$OS" in
        linux)
            # Try different package managers
            if command -v apt-get &> /dev/null; then
                info "Using apt-get..."
                sudo apt-get update -qq
                sudo apt-get install -y jq
                return 0
            elif command -v dnf &> /dev/null; then
                info "Using dnf..."
                sudo dnf install -y jq
                return 0
            elif command -v yum &> /dev/null; then
                info "Using yum..."
                sudo yum install -y jq
                return 0
            elif command -v pacman &> /dev/null; then
                info "Using pacman..."
                sudo pacman -S --noconfirm jq
                return 0
            elif command -v zypper &> /dev/null; then
                info "Using zypper..."
                sudo zypper install -y jq
                return 0
            elif command -v apk &> /dev/null; then
                info "Using apk..."
                apk add --no-cache jq
                return 0
            fi
            ;;

        macos)
            # Homebrew is the most common on macOS
            if command -v brew &> /dev/null; then
                info "Using Homebrew..."
                brew install jq
                return 0
            elif command -v port &> /dev/null; then
                info "Using MacPorts..."
                sudo port install jq
                return 0
            fi
            ;;

        windows)
            # Try Windows package managers
            if command -v winget &> /dev/null; then
                info "Using winget..."
                winget install --id jqlang.jq --accept-source-agreements --accept-package-agreements -e
                return 0
            elif command -v choco &> /dev/null; then
                info "Using Chocolatey..."
                choco install jq -y
                return 0
            elif command -v scoop &> /dev/null; then
                info "Using Scoop..."
                scoop install jq
                return 0
            fi
            ;;
    esac

    warn "No suitable package manager found"
    return 1
}

# Install jq by downloading binary (fallback method)
install_binary() {
    info "Installing jq from binary..."

    # Determine download URL based on OS and architecture
    case "$OS" in
        linux)
            if [ "$ARCH" = "amd64" ]; then
                BINARY="jq-linux64"
            elif [ "$ARCH" = "arm64" ]; then
                BINARY="jq-linux-arm64"
            elif [ "$ARCH" = "i386" ]; then
                BINARY="jq-linux32"
            else
                error "Unsupported architecture: $ARCH"
                return 1
            fi
            ;;

        macos)
            if [ "$ARCH" = "amd64" ] || [ "$ARCH" = "arm64" ]; then
                BINARY="jq-macos-${ARCH}"
            else
                BINARY="jq-macos-amd64"  # Fallback for older macOS
            fi
            ;;

        windows)
            if [ "$ARCH" = "amd64" ]; then
                BINARY="jq-win64.exe"
            else
                BINARY="jq-win32.exe"
            fi
            ;;
    esac

    local DOWNLOAD_URL="${JQ_DOWNLOAD_BASE}/${BINARY}"
    local INSTALL_DIR="$HOME/.local/bin"
    local INSTALL_PATH="$INSTALL_DIR/jq"

    # Create installation directory if it doesn't exist
    mkdir -p "$INSTALL_DIR"

    info "Downloading jq from: $DOWNLOAD_URL"

    # Download with curl or wget
    if command -v curl &> /dev/null; then
        curl -fsSL "$DOWNLOAD_URL" -o "$INSTALL_PATH"
    elif command -v wget &> /dev/null; then
        wget -q "$DOWNLOAD_URL" -O "$INSTALL_PATH"
    else
        error "Neither curl nor wget is available"
        return 1
    fi

    # Make executable (not needed on Windows)
    if [ "$OS" != "windows" ]; then
        chmod +x "$INSTALL_PATH"
        info "Made jq executable"
    fi

    # Add to PATH if not already there
    if [[ ":$PATH:" != *":$INSTALL_DIR:"* ]]; then
        warn "Adding $INSTALL_DIR to PATH..."
        echo "export PATH=\"\$PATH:$INSTALL_DIR\"" >> "$HOME/.bashrc"
        echo "export PATH=\"\$PATH:$INSTALL_DIR\"" >> "$HOME/.zshrc" 2>/dev/null || true
        export PATH="$PATH:$INSTALL_DIR"
        warn "Please restart your shell or run: export PATH=\"\$PATH:$INSTALL_DIR\""
    fi

    info "jq installed to: $INSTALL_PATH"
    return 0
}

# Verify installation
verify_installation() {
    info "Verifying jq installation..."

    if command -v jq &> /dev/null; then
        JQ_VER=$(jq --version)
        info "jq successfully installed: $JQ_VER"

        # Test basic functionality
        echo '{"test": "success"}' | jq -r '.test' > /dev/null 2>&1
        if [ $? -eq 0 ]; then
            info "jq is working correctly!"
            return 0
        else
            error "jq is installed but not working properly"
            return 1
        fi
    else
        error "jq installation failed - jq command not found"
        return 1
    fi
}

# Main installation flow
main() {
    echo "╔══════════════════════════════════════════════════════════╗"
    echo "║   Maven Flow - jq Installer                             ║"
    echo "║   Cross-platform JSON processor installation             ║"
    echo "╚══════════════════════════════════════════════════════════╝"
    echo ""

    detect_os
    detect_arch

    # Check if already installed
    if check_jq_installed; then
        info "jq is already installed. Skipping installation."
        verify_installation
        exit 0
    fi

    # Try package manager first
    if ! install_with_package_manager; then
        warn "Package manager installation failed, trying binary download..."
        install_binary
    fi

    # Verify installation
    if verify_installation; then
        echo ""
        echo "╔══════════════════════════════════════════════════════════╗"
        echo "║   ✓ jq installation complete!                            ║"
        echo "╚══════════════════════════════════════════════════════════╝"
        echo ""
        info "You can now use jq in your Maven Flow hooks!"
        echo ""
        return 0
    else
        echo ""
        echo "╔══════════════════════════════════════════════════════════╗"
        echo "║   ✗ jq installation failed                                ║"
        echo "╚══════════════════════════════════════════════════════════╝"
        echo ""
        error "Please install jq manually:"
        error "  Windows: winget install jqlang.jq"
        error "  macOS:   brew install jq"
        error "  Linux:   sudo apt-get install jq  # or your package manager"
        echo ""
        return 1
    fi
}

# Run main
main "$@"
