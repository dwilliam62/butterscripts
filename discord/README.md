# 🧈 Discord Installer

A simple Discord installer and updater for Linux systems.

## Features
- Installs and updates Discord with a single command
- Works with Bash, Zsh, Fish, and other shells
- User-level installation to ~/.local/bin
- Automatic shell environment configuration
- Clean uninstallation option
- Uses wget or curl (automatically detects)

## Requirements
- Linux-based operating system
- wget or curl for downloading files
- sudo privileges for Discord installation

## Installation
```bash
# Clone repository
git clone https://github.com/drewgrif/butterscripts.git

# Navigate to discord directory
cd butterscripts/discord

# Make executable
chmod +x discord

# Install Discord
./discord

# (Optional) Setup script globally
./discord setup
```

## Usage

**Before setup:**
```bash
# Install or update Discord
./discord

# Uninstall Discord
./discord uninstall

# Setup script globally
./discord setup
```

**After setup (global usage):**
```bash
# Install or update Discord
discord

# Uninstall Discord
discord uninstall

# Show help
discord help
```

## How It Works
The script:
1. Downloads the latest Discord Linux package
2. Extracts it to /opt/Discord
3. Creates necessary symbolic links and desktop entries
4. Handles cleanup during updates/uninstallation

## Project Info
Made for Linux Discord users who want simple installation and updates.

---

## 🧈 Built For

- **Butter Bean (butterbian) Linux** (and other Debian-based systems)
- Window manager setups (BSPWM, Openbox, etc.)
- Users who like things lightweight, modular, and fast

> Butterbian Linux is a joke... for now.

---

## 📫 Author

**JustAGuy Linux**  
🎥 [YouTube](https://youtube.com/@JustAGuyLinux)  

---

More scripts coming soon. Use what you need, fork what you like, tweak everything.
