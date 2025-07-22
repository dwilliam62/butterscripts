#!/bin/bash
# DESC: Build and install FT-Labs Picom compositor with dependencies
set -e
# install-picom-ftlabs.sh: Build and install FT-Labs Picom

# Print current directory for debugging
echo "Current directory: $(pwd)"

# Check if picom is already installed
if command -v picom &>/dev/null; then
    echo "Picom is already installed. Skipping installation."
    exit 0
fi

echo "Installing dependencies for picom..."
sudo apt-get install -y \
    libconfig-dev libdbus-1-dev libegl-dev libev-dev libgl-dev \
    libepoxy-dev libpcre2-dev libpixman-1-dev libx11-xcb-dev \
    libxcb1-dev libxcb-composite0-dev libxcb-damage0-dev \
    libxcb-dpms0-dev libxcb-glx0-dev libxcb-image0-dev \
    libxcb-present-dev libxcb-randr0-dev libxcb-render0-dev \
    libxcb-render-util0-dev libxcb-shape0-dev libxcb-util-dev \
    libxcb-xfixes0-dev libxext-dev meson ninja-build uthash-dev

# Use the temp directory provided by the main script, or create a unique one if run standalone
PICOM_BUILD_DIR="${SCRIPT_TEMP_DIR:-/tmp/picom-build-$(date +%s)-$$}"
echo "Using build directory: $PICOM_BUILD_DIR"

# Create directory (main script should have created it already if called from there)
mkdir -p "$PICOM_BUILD_DIR"

echo "Cloning FT-Labs picom repository..."
git clone https://github.com/FT-Labs/picom "$PICOM_BUILD_DIR/source" || {
    echo "Failed to clone FT-Labs Picom."
    exit 1
}

echo "Building picom..."
cd "$PICOM_BUILD_DIR/source"
meson setup --buildtype=release build
ninja -C build

echo "Installing picom..."
sudo ninja -C build install

# Only clean up if run standalone (the main script handles cleanup otherwise)
if [ -z "$SCRIPT_TEMP_DIR" ]; then
    echo "Cleaning up build directory..."
    rm -rf "$PICOM_BUILD_DIR"
fi

echo "Picom installation completed successfully."
