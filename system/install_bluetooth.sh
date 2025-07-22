#!/bin/bash
# DESC: Install and configure Bluetooth services and utilities

echo "=== Bluetooth Support Installation ==="

# Function to handle script exit
cleanup() {
    echo "Script execution completed."
    exit ${1:-0}
}

# Trap Ctrl+C
trap 'echo "Script interrupted."; cleanup 1' INT

echo "Would you like to install Bluetooth services? (y/n)"
read -r response

if [[ "$response" =~ ^[Yy]$ ]]; then
    echo "Installing Bluetooth services..."
    
    # Install Bluetooth packages
    if ! sudo apt update && sudo apt install -y bluez blueman bluez-tools pulseaudio-module-bluetooth; then
        echo "Error: Failed to install some packages. Please check your internet connection and try again."
        cleanup 1
    fi
    
    # Enable and start Bluetooth service
    sudo systemctl enable bluetooth.service
    sudo systemctl start bluetooth.service
    
    # Add current user to bluetooth group
    sudo usermod -aG bluetooth "$USER"
    
    echo -e "\n✅ Bluetooth services installed successfully."
    echo "- Use blueman-applet for GUI configuration"
    echo "- Use 'bluetoothctl' in terminal for command-line control"
    echo "- Log out and log back in for group changes to take effect"
    
elif [[ "$response" =~ ^[Nn]$ ]]; then
    echo "Bluetooth services will not be installed."
else
    echo "Invalid input. Please enter 'y' or 'n'."
    cleanup 1
fi

cleanup
