#!/bin/bash

# ST Terminal Installer - Suckless version

set -e

# Check if st is already installed
if command -v st &> /dev/null; then
    echo "ST is already installed at: $(which st)"
    # Use return if sourced, exit if run directly
    [[ "${BASH_SOURCE[0]}" != "${0}" ]] && return 0 || exit 0
fi

# Install dependencies
sudo apt-get update || true
sudo apt-get install -y git make gcc libx11-dev libxft-dev libxinerama-dev

# Clone and build
git clone https://github.com/drewgrif/dwm-setup.git /tmp/st-build
cd /tmp/st-build/suckless/st
make
sudo make install

# Create desktop file
mkdir -p ~/.local/share/applications
cat > ~/.local/share/applications/st.desktop << EOF
[Desktop Entry]
Name=st
Comment=Simple Terminal
Exec=st
Icon=utilities-terminal
Terminal=false
Type=Application
Categories=System;TerminalEmulator;
EOF

# Update desktop database
update-desktop-database ~/.local/share/applications/

# Cleanup
rm -rf /tmp/st-build

echo "ST installed. Available in rofi as 'st'."
