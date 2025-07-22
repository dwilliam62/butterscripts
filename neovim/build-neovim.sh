#!/bin/bash
# DESC: Build and install latest Neovim from source
# Script to build and install the latest Neovim from source

set -e  # Exit immediately if a command exits with a non-zero status

echo "Installing build prerequisites..."
sudo apt update
sudo apt install -y ninja-build gettext cmake unzip curl git

echo "Cloning Neovim repository..."
if [ -d "neovim" ]; then
  echo "Neovim directory already exists. Updating..."
  cd neovim
  git pull
  git checkout stable
else
  git clone https://github.com/neovim/neovim
  cd neovim
  git checkout stable
fi

echo "Building Neovim..."
make clean
make CMAKE_BUILD_TYPE=RelWithDebInfo -j$(nproc)

echo "Creating Debian package..."
cd build
cpack -G DEB

echo "Installing Neovim..."
sudo dpkg -i nvim-linux64.deb || sudo dpkg -i nvim-linux-x86_64.deb

echo "Neovim installation completed. You can run it with 'nvim'"
nvim --version
