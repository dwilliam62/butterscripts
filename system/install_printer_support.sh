#!/bin/bash
# DESC: Install CUPS and printing services for printer support

echo "=== Printer Support Installation ==="

# Function to handle script exit
cleanup() {
    echo "Script execution completed."
    exit ${1:-0}
}

# Trap Ctrl+C
trap 'echo "Script interrupted."; cleanup 1' INT

# Check if we have an automatic response (for non-interactive use)
if [ -n "$1" ]; then
    response="$1"
else
    echo "Would you like to install printing services? (y/n)"
    read -r response
fi

if [[ "$response" =~ ^[Yy]$ ]]; then
    echo "Installing printing services..."
    
    # Install required packages
    if ! sudo apt update && sudo apt install -y cups cups-client cups-filters \
                                              system-config-printer simple-scan \
                                              printer-driver-gutenprint hplip; then
        echo "Error: Failed to install some packages. Please check your internet connection and try again."
        cleanup 1
    fi
    
    # Enable and start CUPS service
    sudo systemctl enable cups.service
    sudo systemctl start cups.service
    
    # Add current user to lpadmin group for printer admin rights
    sudo usermod -aG lpadmin "$USER"
    
    echo -e "\n✅ Printing services installed successfully."
    echo "- Access CUPS web interface at: http://localhost:631"
    echo "- Use system-config-printer for GUI configuration"
    echo "- Log out and log back in for group changes to take effect"
    
elif [[ "$response" =~ ^[Nn]$ ]]; then
    echo "Printing services will not be installed."
else
    echo "Invalid input. Please enter 'y' or 'n'."
    cleanup 1
fi

cleanup
