#!/bin/bash
# DESC: Backup current .bashrc and download custom configuration

[ -f ~/.bashrc ] && mv ~/.bashrc ~/.bashrc.bak
wget -O ~/.bashrc https://raw.githubusercontent.com/drewgrif/jag_dots/main/.bashrc