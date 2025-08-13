#!/bin/bash
# DESC: Install Caligula disk imaging TUI for Debian - optimized for WM users

set -e

CALIGULA_VERSION="0.4.8"
INSTALL_DIR="$HOME/.local/bin"

# Detect architecture
ARCH=$(uname -m)
case "$ARCH" in
    x86_64) BINARY_NAME="caligula-x86_64-linux" ;;
    aarch64|arm64) BINARY_NAME="caligula-aarch64-linux" ;;
    *)
        echo "Unsupported architecture: $ARCH"
        echo "Building from source instead..."
        
        # Install Rust if not present
        if ! command -v cargo &> /dev/null; then
            curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh -s -- -y --no-modify-path
            source "$HOME/.cargo/env"
        fi
        
        # Install build deps
        sudo apt update
        sudo apt install -y build-essential pkg-config
        
        # Install via cargo
        cargo install --version "${CALIGULA_VERSION}" caligula
        
        echo "Caligula installed to ~/.cargo/bin/caligula"
        exit 0
        ;;
esac

echo "Installing Caligula v${CALIGULA_VERSION} for Debian ${ARCH}..."

# Create install directory
mkdir -p "$INSTALL_DIR"

# Download binary
DOWNLOAD_URL="https://github.com/ifd3f/caligula/releases/download/v${CALIGULA_VERSION}/${BINARY_NAME}"

if command -v wget &> /dev/null; then
    wget -q --show-progress "$DOWNLOAD_URL" -O "$INSTALL_DIR/caligula"
elif command -v curl &> /dev/null; then
    curl -L --progress-bar "$DOWNLOAD_URL" -o "$INSTALL_DIR/caligula"
else
    sudo apt install -y wget
    wget -q --show-progress "$DOWNLOAD_URL" -O "$INSTALL_DIR/caligula"
fi

# Make executable
chmod +x "$INSTALL_DIR/caligula"

# Add to PATH in common shell configs if not present
for rc in "$HOME/.bashrc" "$HOME/.zshrc" "$HOME/.profile"; do
    if [ -f "$rc" ]; then
        if ! grep -q "PATH.*\.local/bin" "$rc"; then
            echo 'export PATH="$HOME/.local/bin:$PATH"' >> "$rc"
        fi
    fi
done

# Install desktop entry for rofi/app launchers
DESKTOP_DIR="$HOME/.local/share/applications"
mkdir -p "$DESKTOP_DIR"

cat > "$DESKTOP_DIR/caligula.desktop" << 'EOF'
[Desktop Entry]
Name=Caligula
GenericName=Disk Imager
Comment=User-friendly TUI for imaging disks
Exec=x-terminal-emulator -e caligula
Icon=media-removable
Terminal=false
Type=Application
Categories=System;Utility;
Keywords=disk;image;burn;dd;usb;iso;
StartupNotify=false
Actions=BurnImage;

[Desktop Action BurnImage]
Name=Burn Disk Image
Exec=x-terminal-emulator -e sh -c "echo 'Select image file:'; read -p 'Path: ' img; pkexec caligula burn \"$img\"; read -p 'Press Enter to close...'"
EOF

# Update desktop database if available
if command -v update-desktop-database &> /dev/null; then
    update-desktop-database "$DESKTOP_DIR" 2>/dev/null || true
fi

echo "Caligula installed to $INSTALL_DIR/caligula"
echo "Desktop entry installed for rofi/launchers"
echo "Run: caligula --help"