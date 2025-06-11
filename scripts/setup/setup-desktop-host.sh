#!/bin/bash

# Exit on error
set -e

# Check if running with sudo
if [ "$EUID" -ne 0 ]; then 
    echo "Please run this script with sudo, e.g. sudo ./scripts/setup/setup-desktop-host.sh"
    exit 1
fi

echo "Setting up desktop host system..."

# Get the workspace root directory
ROOT=$(dirname $(dirname $(dirname $(readlink -f $0))))
echo "Workspace root directory: ${ROOT}"

# Update package lists
apt-get update

# Install GitHub CLI
echo "Installing GitHub CLI..."
apt-get install -y gh

# Create symlink for network configuration
echo "Setting up network configuration..."
cp ${ROOT}/scripts/config/10-cyclone-max.conf /etc/sysctl.d/10-cyclone-max.conf
sysctl -p /etc/sysctl.d/10-cyclone-max.conf

echo "Desktop host setup completed successfully!"
