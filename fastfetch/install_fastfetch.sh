#!/bin/bash
# DESC: Install Fastfetch system info tool from official deb package
set -e
# fastfetch.sh: Install and configure Fastfetch from deb package

command_exists() {
    command -v "$1" &>/dev/null
}

# User confirmation is now handled by the calling script

INSTALL_DIR="${INSTALL_DIR:-/tmp/install-fastfetch}"
mkdir -p "$INSTALL_DIR"

# Step 1: Install fastfetch if not already installed
if command_exists fastfetch; then
    echo "Fastfetch is already installed. Skipping installation."
else
    echo "Downloading and installing Fastfetch package..."
    
    # Install only wget for downloading the package
    sudo apt-get install -y wget
    
    # Get the latest release URL
    DEB_URL=$(wget -qO- https://api.github.com/repos/fastfetch-cli/fastfetch/releases/latest | grep -oP '"browser_download_url": "\K(.+?-linux-amd64\.deb)' | head -1)
    
    if [ -n "$DEB_URL" ]; then
        # Download the latest deb package
        wget -O "$INSTALL_DIR/fastfetch.deb" "$DEB_URL"
        # Install it
        sudo apt install -y "$INSTALL_DIR/fastfetch.deb"
        echo "Fastfetch installed from deb package."
    else
        echo "Could not find prebuilt deb package. Installation failed."
        exit 1
    fi
fi

# Step 2: Create configuration directory
echo "Setting up Fastfetch config..."
mkdir -p "$HOME/.config/fastfetch"

# Step 3: Download configuration files directly from GitHub
echo "Downloading configuration files from GitHub..."

wget -O "$HOME/.config/fastfetch/config.jsonc" "https://raw.githubusercontent.com/drewgrif/butterscripts/main/fastfetch/config.jsonc"
wget -O "$HOME/.config/fastfetch/minimal.jsonc" "https://raw.githubusercontent.com/drewgrif/butterscripts/main/fastfetch/minimal.jsonc"
wget -O "$HOME/.config/fastfetch/server.jsonc" "https://raw.githubusercontent.com/drewgrif/butterscripts/main/fastfetch/server.jsonc"

echo "Configuration files downloaded successfully."

# Step 4: Create an alias for fastfetch based on detected shell
echo "Setting up shell alias..."

# Check which shells are configured
if [ -f "$HOME/.bashrc" ]; then
    if ! grep -q "alias ff=" "$HOME/.bashrc"; then
        echo "# Fastfetch alias" >> "$HOME/.bashrc"
        echo "alias ff='fastfetch'" >> "$HOME/.bashrc"
        echo "Added 'ff' alias to .bashrc"
    fi
fi

if [ -f "$HOME/.zshrc" ]; then
    if ! grep -q "alias ff=" "$HOME/.zshrc"; then
        echo "# Fastfetch alias" >> "$HOME/.zshrc"
        echo "alias ff='fastfetch'" >> "$HOME/.zshrc"
        echo "Added 'ff' alias to .zshrc"
    fi
fi

if [ -d "$HOME/.config/fish" ]; then
    fish_alias_path="$HOME/.config/fish/functions/ff.fish"
    if [ ! -f "$fish_alias_path" ]; then
        mkdir -p "$(dirname "$fish_alias_path")"
        echo "function ff" > "$fish_alias_path"
        echo "    fastfetch \$argv" >> "$fish_alias_path"
        echo "end" >> "$fish_alias_path"
        echo "Added 'ff' function to fish shell"
    fi
fi

echo "Fastfetch configuration complete."
echo "Available configuration presets:"
echo "  - Default: fastfetch"
echo "  - Minimal: fastfetch -c ~/.config/fastfetch/minimal.jsonc"
echo "  - Server: fastfetch -c ~/.config/fastfetch/server.jsonc"
echo "You can also use the 'ff' alias for the default configuration."
