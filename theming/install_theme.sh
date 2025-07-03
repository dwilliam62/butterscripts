#!/bin/bash

set -e

# Fixed configuration
GTK_THEME="Orchis-Grey-Dark"
ICON_THEME="Colloid-Grey-Dracula-Dark"
TEMP_DIR="/tmp/theme_$$"

# Cleanup on exit
trap "rm -rf $TEMP_DIR" EXIT

die() { echo "ERROR: $1" >&2; exit 1; }

# Check if already installed
[ -d "$HOME/.themes/$GTK_THEME" ] && [ -d "$HOME/.icons/$ICON_THEME" ] && {
    echo "Themes already installed"
    exit 0
}

# Install themes
echo "Installing themes..."
mkdir -p "$TEMP_DIR" && cd "$TEMP_DIR"

# GTK Theme
git clone -q https://github.com/vinceliuice/Orchis-theme || die "Failed to clone GTK theme"
cd Orchis-theme
yes | ./install.sh -c dark -t grey --tweaks black >/dev/null 2>&1 || die "GTK theme install failed"

# Icon Theme  
cd "$TEMP_DIR"
git clone -q https://github.com/vinceliuice/Colloid-icon-theme || die "Failed to clone icon theme"
cd Colloid-icon-theme
./install.sh -t grey -s dracula 2>&1 | grep -v "sed: can't read" >/dev/null || true

# Verify icon theme installation
[ ! -d "$HOME/.local/share/icons/$ICON_THEME" ] && [ ! -d "$HOME/.icons/$ICON_THEME" ] && die "Icon theme installation verification failed"

# Apply settings
mkdir -p ~/.config/gtk-3.0
cat > ~/.config/gtk-3.0/settings.ini << EOF
[Settings]
gtk-theme-name=$GTK_THEME
gtk-icon-theme-name=$ICON_THEME
gtk-font-name=Sans 10
gtk-cursor-theme-name=Adwaita
gtk-xft-antialias=1
gtk-xft-hinting=1
gtk-xft-hintstyle=hintfull
EOF

cat > ~/.gtkrc-2.0 << EOF
gtk-theme-name="$GTK_THEME"
gtk-icon-theme-name="$ICON_THEME"
gtk-font-name="Sans 10"
gtk-cursor-theme-name="Adwaita"
gtk-xft-antialias=1
gtk-xft-hinting=1
gtk-xft-hintstyle="hintfull"
EOF

echo "Themes installed successfully"