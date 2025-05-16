#!/bin/bash
set -e

echo "Running system cleanup..."

# Clean package cache
sudo apt-get clean
sudo apt-get autoremove -y

# Remove temporary files
sudo rm -rf /tmp/*
sudo rm -rf /var/tmp/*

# Clear system logs
sudo find /var/log -type f -exec truncate --size=0 {} \;

# Clear bash history
history -c
cat /dev/null > ~/.bash_history

echo "Cleanup completed successfully."