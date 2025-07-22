#!/bin/bash
# DESC: Install and configure LightDM display manager with slick-greeter

# ===========================================
# Display Manager Installation Script
# ===========================================

# Clear the screen at the start to ensure script runs at the top of TTY
clear

# Set colors for output
GREEN='\033[0;32m'
CYAN='\033[0;36m'
RED='\033[0;31m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

# Function to display script header
show_header() {
    echo -e "${CYAN}=========================================================${NC}"
    echo -e "${CYAN}         DISPLAY MANAGER INSTALLATION SCRIPT             ${NC}"
    echo -e "${CYAN}=========================================================${NC}"
    echo -e "${YELLOW}This script will help you install a display manager${NC}"
    echo -e "${YELLOW}for your system. LightDM is the recommended option.${NC}"
    echo
}

# Function to handle script exit
cleanup() {
    echo -e "\n${CYAN}Script execution completed.${NC}"
    exit ${1:-0}
}

# Trap Ctrl+C
trap 'echo -e "\n${RED}Script interrupted.${NC}"; cleanup 1' INT

# Function to check if a package is installed
is_package_installed() {
    local package="$1"
    dpkg -l | grep -q "^ii  $package"
}

# Function to check if a service is active and enabled
service_active_and_enabled() {
    local service="$1"
    # Check if service is active and enabled
    sudo systemctl is-active --quiet "$service" && sudo systemctl is-enabled --quiet "$service"
}

# Check if GDM is installed and enabled
check_gdm() {
    is_package_installed gdm3 && service_active_and_enabled gdm
}

# Check if SDDM is installed and enabled
check_sddm() {
    is_package_installed sddm && service_active_and_enabled sddm
}

# Check if LightDM is installed and enabled
check_lightdm() {
    is_package_installed lightdm && service_active_and_enabled lightdm
}

# Check if LXDM is installed and enabled
check_lxdm() {
    is_package_installed lxdm && service_active_and_enabled lxdm
}

# Check if Ly is installed and enabled
check_ly() {
    is_package_installed ly && service_active_and_enabled ly
}

# Check if SLiM is installed and enabled
check_slim() {
    is_package_installed slim && service_active_and_enabled slim
}

# Function to install and enable LightDM
install_lightdm() {
    echo -e "${GREEN}Installing LightDM (recommended)...${NC}"
    sudo apt update
    if ! sudo apt install -y lightdm lightdm-gtk-greeter lightdm-gtk-greeter-settings; then
        echo -e "${RED}Failed to install LightDM.${NC}"
        cleanup 1
    fi
    sudo systemctl enable lightdm
    sudo systemctl set-default graphical.target
    echo -e "${GREEN}LightDM has been installed and enabled.${NC}"
    echo -e "${YELLOW}You may want to configure LightDM using lightdm-gtk-greeter-settings after installation.${NC}"
}

# Function to install and enable GDM3
install_gdm() {
    echo -e "${GREEN}Installing minimal GDM3...${NC}"
    sudo apt update
    if ! sudo apt install -y --no-install-recommends gdm3; then
        echo -e "${RED}Failed to install GDM3.${NC}"
        cleanup 1
    fi
    sudo systemctl enable gdm
    sudo systemctl set-default graphical.target
    echo -e "${GREEN}GDM3 has been installed and enabled.${NC}"
    echo -e "${YELLOW}Note: GDM3 is resource-intensive compared to other display managers.${NC}"
}

# Function to install and enable SDDM
install_sddm() {
    echo -e "${GREEN}Installing minimal SDDM...${NC}"
    sudo apt update
    if ! sudo apt install -y --no-install-recommends sddm; then
        echo -e "${RED}Failed to install SDDM.${NC}"
        cleanup 1
    fi
    sudo systemctl enable sddm
    sudo systemctl set-default graphical.target
    echo -e "${GREEN}SDDM has been installed and enabled.${NC}"
}

# Function to install and enable LXDM
install_lxdm() {
    echo -e "${GREEN}Installing LXDM...${NC}"
    sudo apt update
    if ! sudo apt install -y --no-install-recommends lxdm; then
        echo -e "${RED}Failed to install LXDM.${NC}"
        cleanup 1
    fi
    sudo systemctl enable lxdm
    sudo systemctl set-default graphical.target
    echo -e "${GREEN}LXDM has been installed and enabled.${NC}"
}

# Function to install and enable SLiM
install_slim() {
    echo -e "${GREEN}Installing SLiM...${NC}"
    sudo apt update
    if ! sudo apt install -y slim; then
        echo -e "${RED}Failed to install SLiM.${NC}"
        cleanup 1
    fi
    sudo systemctl enable slim
    sudo systemctl set-default graphical.target
    echo -e "${GREEN}SLiM has been installed and enabled.${NC}"
    echo -e "${YELLOW}Note: SLiM is no longer actively maintained.${NC}"
}

# Print header
show_header

# Check which display managers are installed and enabled
if check_lightdm; then
    echo -e "${GREEN}LightDM is already installed and enabled (recommended).${NC}"
    exit 0
elif check_gdm; then
    echo -e "${GREEN}GDM3 is already installed and enabled.${NC}"
    exit 0
elif check_sddm; then
    echo -e "${GREEN}SDDM is already installed and enabled.${NC}"
    exit 0
elif check_lxdm; then
    echo -e "${GREEN}LXDM is already installed and enabled.${NC}"
    exit 0
elif check_ly; then
    echo -e "${GREEN}Ly is already installed and enabled.${NC}"
    exit 0
elif check_slim; then
    echo -e "${GREEN}SLiM is already installed and enabled.${NC}"
    exit 0
fi

# If none of the above are installed, offer a choice to the user
echo -e "${YELLOW}No supported display manager found.${NC}"

# Menu for user choice
echo -e "\n${CYAN}Choose an option (or '0' to skip):${NC}"
echo -e "${CYAN}1. ${NC}Install LightDM (recommended) - Lightweight and feature-rich"
echo -e "${CYAN}2. ${NC}Install minimal GDM3 - GNOME Display Manager"
echo -e "${CYAN}3. ${NC}Install minimal SDDM - Simple Desktop Display Manager"
echo -e "${CYAN}4. ${NC}Install LXDM - LXDE Display Manager"
echo -e "${CYAN}5. ${NC}Install SLiM - Simple Login Manager (not actively maintained)"

read -p "Enter your choice (0/1/2/3/4/5): " choice

case $choice in
    0)
        echo -e "${YELLOW}Skipping installation.${NC}"
        exit 0
        ;;
    1)
        install_lightdm
        ;;
    2)
        install_gdm
        ;;
    3)
        install_sddm
        ;;
    4)
        install_lxdm
        ;;
    5)
        install_slim
        ;;
    *)
        echo -e "${RED}Invalid choice. Exiting.${NC}"
        exit 1
        ;;
esac

cleanup
