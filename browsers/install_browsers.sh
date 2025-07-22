#!/bin/bash
# DESC: Install various web browsers (Chrome, Firefox, Brave, etc.)

# Browser Installation Scripts for Debian Stable
# This script provides installation methods for various browsers
# targeting the latest versions available for Debian Stable

# Set colors for output (matching lightdm script)
GREEN='\033[0;32m'
CYAN='\033[0;36m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Check if running on Debian
if [ ! -f /etc/debian_version ]; then
    echo -e "${RED}This script is optimized for Debian. Your system may not be compatible.${NC}"
    read -p "Continue anyway? (y/n): " continue_anyway
    if [[ "$continue_anyway" != "y" && "$continue_anyway" != "Y" ]]; then
        exit 1
    fi
fi

# Make sure we have basic dependencies
ensure_dependencies() {
    echo -e "${GREEN}Installing essential dependencies...${NC}"
    sudo apt update
    sudo apt install -y wget curl apt-transport-https gnupg ca-certificates software-properties-common
}

# Choose browsers to install
show_menu() {
    clear
    echo -e "${CYAN}=========================================================${NC}"
    echo -e "${CYAN}         BROWSER INSTALLATION SCRIPTS (DEBIAN)          ${NC}"
    echo -e "${CYAN}=========================================================${NC}"
    echo -e "${YELLOW}Enter numbers of browsers to install (separated by spaces):${NC}"
    echo -e "${CYAN}1. ${NC}Firefox Latest"
    echo -e "${CYAN}2. ${NC}Firefox ESR"
    echo -e "${CYAN}3. ${NC}LibreWolf"
    echo -e "${CYAN}4. ${NC}Brave"
    echo -e "${CYAN}5. ${NC}Floorp"
    echo -e "${CYAN}6. ${NC}Vivaldi"
    echo -e "${CYAN}7. ${NC}Zen Browser"
    echo -e "${CYAN}8. ${NC}Chromium"
    echo -e "${CYAN}9. ${NC}All Browsers"
    echo -e "${CYAN}10. ${NC}Exit"
    echo -e "${CYAN}=========================================================${NC}"
    
    # Simple read command with normal terminal behavior
    read -p "Enter your choice(s): " input
    
    # Check if input is empty
    if [ -z "$input" ]; then
        echo -e "${YELLOW}No selection made. Exiting.${NC}"
        exit 0
    fi
    
    # Check if user wants to exit with option 10
    if [[ "$input" == "10" ]]; then
        echo -e "${YELLOW}Exiting...${NC}"
        exit 0
    fi
    
    # Install all browsers if option 9 is selected
    if [[ "$input" == "9" ]]; then
        install_firefox
        install_firefox_esr
        install_librewolf
        install_brave
        install_floorp
        install_vivaldi
        install_zen
        install_chromium
        echo -e "${GREEN}All browsers have been installed!${NC}"
        exit 0
    fi
    
    # Process each selection
    for choice in $input; do
        case $choice in
            1) install_firefox ;;
            2) install_firefox_esr ;;
            3) install_librewolf ;;
            4) install_brave ;;
            5) install_floorp ;;
            6) install_vivaldi ;;
            7) install_zen ;;
            8) install_chromium ;;
            *) echo -e "${RED}Invalid choice: $choice (skipping)${NC}" ;;
        esac
    done
    
    echo -e "${GREEN}Selected browsers have been installed!${NC}"
    exit 0
}

# Function to check if a package is installed
is_installed() {
    if [ -n "$(dpkg -l | grep -E "^ii\s+$1\s+")" ]; then
        return 0  # Package is installed
    else
        return 1  # Package is not installed
    fi
}

# Function to check if a command exists
command_exists() {
    command -v "$1" >/dev/null 2>&1
}

# Function to install Firefox
install_firefox() {
    # Check if Firefox is already installed
    if is_installed firefox-esr || is_installed firefox; then
        if is_installed firefox-esr && ! is_installed firefox; then
            echo -e "${YELLOW}Firefox ESR is currently installed.${NC}"
            echo -e "${CYAN}Choose an option:${NC}"
            echo -e "${CYAN}1. ${NC}Install latest Firefox alongside ESR (both will be available)"
            echo -e "${CYAN}2. ${NC}Remove ESR and install latest Firefox"
            echo -e "${CYAN}3. ${NC}Skip installation (keep ESR only)"
            read -p "Enter your choice (1-3): " firefox_choice
            
            case $firefox_choice in
                1)
                    echo -e "${GREEN}Installing Firefox latest alongside ESR...${NC}"
                    ;;
                2)
                    echo -e "${GREEN}Removing Firefox ESR and installing latest...${NC}"
                    sudo apt remove -y firefox-esr
                    ;;
                3)
                    echo -e "${GREEN}Keeping Firefox ESR. Skipping installation.${NC}"
                    return
                    ;;
                *)
                    echo -e "${RED}Invalid choice. Skipping installation.${NC}"
                    return
                    ;;
            esac
        else
            echo -e "${GREEN}Firefox is already installed. Skipping installation.${NC}"
            return
        fi
    fi
    
    echo -e "${GREEN}Installing Firefox Latest...${NC}"
    
    # Install dependencies
    ensure_dependencies
    
    # Remove any old Mozilla repository files if they exist
    sudo rm -f /etc/apt/sources.list.d/mozilla.list
    sudo rm -f /etc/apt/keyrings/packages.mozilla.org.asc
    
    # Create keyrings directory if it doesn't exist
    sudo install -d -m 0755 /etc/apt/keyrings
    
    # Import the Mozilla APT repository signing key
    wget -q https://packages.mozilla.org/apt/repo-signing-key.gpg -O- | sudo tee /etc/apt/keyrings/packages.mozilla.org.asc > /dev/null
    
    # Add the Mozilla APT repository
    echo "deb [signed-by=/etc/apt/keyrings/packages.mozilla.org.asc] https://packages.mozilla.org/apt mozilla main" | sudo tee -a /etc/apt/sources.list.d/mozilla.list > /dev/null
    
    # Configure APT to prioritize packages from the Mozilla repository
    echo '
Package: *
Pin: origin packages.mozilla.org
Pin-Priority: 1000
' | sudo tee /etc/apt/preferences.d/mozilla
    
    # Update and install Firefox
    sudo apt update
    if ! sudo apt install -y firefox; then
        echo -e "${RED}Failed to install Firefox.${NC}"
        return 1
    fi
    
    echo -e "${GREEN}Firefox installation completed.${NC}"
    echo -e "${YELLOW}You can run Firefox by typing 'firefox' in the terminal or launching it from the applications menu.${NC}"
}

# Function to install Firefox ESR
install_firefox_esr() {
    # Check if Firefox ESR is already installed
    if is_installed firefox-esr; then
        echo -e "${GREEN}Firefox ESR is already installed. Skipping installation.${NC}"
        return
    fi
    
    echo -e "${GREEN}Installing Firefox ESR...${NC}"
    
    # Install dependencies
    ensure_dependencies
    
    # Update and install Firefox ESR from Debian repositories
    sudo apt update
    if ! sudo apt install -y firefox-esr; then
        echo -e "${RED}Failed to install Firefox ESR.${NC}"
        return 1
    fi
    
    echo -e "${GREEN}Firefox ESR installation completed.${NC}"
    echo -e "${YELLOW}You can run Firefox ESR by typing 'firefox-esr' in the terminal or launching it from the applications menu.${NC}"
}

# Function to install LibreWolf
install_librewolf() {
    # Check if LibreWolf is already installed
    if is_installed librewolf; then
        echo -e "${GREEN}LibreWolf is already installed. Skipping installation.${NC}"
        return
    fi
    
    echo -e "${GREEN}Installing LibreWolf...${NC}"
    
    # Install dependencies
    ensure_dependencies
    
    # First, remove any old LibreWolf repository files if they exist
    sudo rm -f \
        /etc/apt/sources.list.d/librewolf.sources \
        /etc/apt/keyrings/librewolf.gpg \
        /etc/apt/preferences.d/librewolf.pref \
        /etc/apt/sources.list.d/librewolf.list \
        /etc/apt/trusted.gpg.d/librewolf.gpg
    
    # Install extrepo tool
    sudo apt update
    sudo apt install -y extrepo
    
    # Enable LibreWolf repository via extrepo
    sudo extrepo enable librewolf
    
    # Update and install
    sudo apt update
    if ! sudo apt install -y librewolf; then
        echo -e "${RED}Failed to install LibreWolf.${NC}"
        return 1
    fi
    
    echo -e "${GREEN}LibreWolf installation complete!${NC}"
    echo -e "${YELLOW}You can run LibreWolf by typing 'librewolf' in the terminal or launching it from the applications menu.${NC}"
}

# Function to install Brave
install_brave() {
    # Check if Brave is already installed
    if is_installed brave-browser; then
        echo -e "${GREEN}Brave Browser is already installed. Skipping installation.${NC}"
        return
    fi
    
    echo -e "${GREEN}Installing Brave Browser...${NC}"
    
    # Install dependencies
    ensure_dependencies
    
    # Add Brave GPG key
    sudo curl -fsSLo /usr/share/keyrings/brave-browser-archive-keyring.gpg https://brave-browser-apt-release.s3.brave.com/brave-browser-archive-keyring.gpg
    
    # Add Brave repository
    echo "deb [signed-by=/usr/share/keyrings/brave-browser-archive-keyring.gpg] https://brave-browser-apt-release.s3.brave.com/ stable main" | sudo tee /etc/apt/sources.list.d/brave-browser-release.list
    
    # Update and install
    sudo apt update
    if ! sudo apt install -y brave-browser; then
        echo -e "${RED}Failed to install Brave Browser.${NC}"
        return 1
    fi
    
    echo -e "${GREEN}Brave Browser installation complete!${NC}"
    echo -e "${YELLOW}You can run Brave by typing 'brave-browser' in the terminal or launching it from the applications menu.${NC}"
}

# Function to install Floorp
install_floorp() {
    # Check if Floorp is already installed
    if is_installed floorp; then
        echo -e "${GREEN}Floorp Browser is already installed. Skipping installation.${NC}"
        return
    fi
    
    echo -e "${GREEN}Installing Floorp Browser...${NC}"
    
    # Install dependencies
    ensure_dependencies
    
    # Add Floorp GPG key
    curl -fsSL https://ppa.ablaze.one/KEY.gpg | sudo gpg --dearmor -o /usr/share/keyrings/Floorp.gpg
    
    # Add Floorp repository
    sudo curl -sS --compressed -o /etc/apt/sources.list.d/Floorp.list 'https://ppa.ablaze.one/Floorp.list'
    
    # Update and install
    sudo apt update
    if ! sudo apt install -y floorp; then
        echo -e "${RED}Failed to install Floorp Browser.${NC}"
        return 1
    fi
    
    echo -e "${GREEN}Floorp Browser installation complete!${NC}"
    echo -e "${YELLOW}You can run Floorp by typing 'floorp' in the terminal or launching it from the applications menu.${NC}"
}

# Function to install Vivaldi
install_vivaldi() {
    # Check if Vivaldi is already installed
    if is_installed vivaldi-stable; then
        echo -e "${GREEN}Vivaldi Browser is already installed. Skipping installation.${NC}"
        return
    fi
    
    echo -e "${GREEN}Installing Vivaldi Browser...${NC}"
    
    # Install dependencies
    ensure_dependencies
    
    # Add Vivaldi key
    wget -qO- https://repo.vivaldi.com/archive/linux_signing_key.pub | sudo apt-key add -
    
    # Add Vivaldi repository
    echo "deb [arch=amd64] https://repo.vivaldi.com/archive/deb/ stable main" | sudo tee /etc/apt/sources.list.d/vivaldi.list
    
    # Update and install
    sudo apt update
    if ! sudo apt install -y vivaldi-stable; then
        echo -e "${RED}Failed to install Vivaldi Browser.${NC}"
        return 1
    fi
    
    echo -e "${GREEN}Vivaldi Browser installation complete!${NC}"
    echo -e "${YELLOW}You can run Vivaldi by typing 'vivaldi' or 'vivaldi-stable' in the terminal or launching it from the applications menu.${NC}"
}

# Function to install Zen Browser
install_zen() {
    # Check if Zen Browser is already installed
    if [ -f "$HOME/Applications/ZenBrowser.AppImage" ] && [ -f "$HOME/.local/share/applications/zen-browser.desktop" ]; then
        echo -e "${GREEN}Zen Browser AppImage is already installed. Skipping installation.${NC}"
        return
    fi
    
    echo -e "${GREEN}Installing Zen Browser AppImage...${NC}"
    
    # Install dependencies
    ensure_dependencies
    
    # Create directory for AppImages if it doesn't exist
    mkdir -p "$HOME/Applications"
    
    # Download latest Zen Browser AppImage
    echo -e "${CYAN}Downloading Zen Browser AppImage...${NC}"
    if ! wget -O "$HOME/Applications/ZenBrowser.AppImage" "https://github.com/zen-browser/desktop/releases/latest/download/zen-x86_64.AppImage"; then
        echo -e "${RED}Failed to download Zen Browser AppImage.${NC}"
        return 1
    fi
    
    # Make it executable
    echo -e "${CYAN}Setting executable permissions...${NC}"
    chmod +x "$HOME/Applications/ZenBrowser.AppImage"
    
    # Create applications directory if it doesn't exist
    mkdir -p "$HOME/.local/share/applications"
    
    # Create desktop entry
    echo -e "${CYAN}Creating desktop entry...${NC}"
    echo "[Desktop Entry]
Version=1.0
Name=Zen Browser
Comment=Experience tranquillity while browsing the web
GenericName=Web Browser
Keywords=Internet;WWW;Browser;Web;Explorer
Exec=$HOME/Applications/ZenBrowser.AppImage %u
Terminal=false
Type=Application
Icon=web-browser
Categories=Network;WebBrowser;
StartupNotify=true
MimeType=text/html;text/xml;application/xhtml+xml;application/xml;application/rss+xml;application/rdf+xml;image/gif;image/jpeg;image/png;x-scheme-handler/http;x-scheme-handler/https;x-scheme-handler/ftp;video/webm;application/x-xpinstall;" > "$HOME/.local/share/applications/zen-browser.desktop"
    
    echo -e "${GREEN}Zen Browser AppImage installation complete!${NC}"
    echo -e "${YELLOW}You can run Zen Browser by executing $HOME/Applications/ZenBrowser.AppImage or launching it from the applications menu.${NC}"
}

# Function to install Chromium
install_chromium() {
    # Check if Chromium is already installed
    if is_installed chromium || is_installed chromium-browser; then
        echo -e "${GREEN}Chromium Browser is already installed. Skipping installation.${NC}"
        return
    fi
    
    echo -e "${GREEN}Installing Chromium Browser...${NC}"
    
    # Install dependencies
    ensure_dependencies
    
    # Install Chromium from Debian repositories
    sudo apt update
    if ! sudo apt install -y chromium; then
        echo -e "${RED}Failed to install Chromium Browser.${NC}"
        return 1
    fi
    
    echo -e "${GREEN}Chromium Browser installation complete!${NC}"
    echo -e "${YELLOW}You can run Chromium by typing 'chromium' in the terminal or launching it from the applications menu.${NC}"
}


# Ensure we have necessary privileges
if [[ $EUID -ne 0 ]]; then
    echo -e "${YELLOW}This script requires sudo privileges for installation.${NC}"
    echo -e "${YELLOW}You'll be prompted for your password when necessary.${NC}"
fi

# Start installation process
ensure_dependencies
show_menu

exit 0
