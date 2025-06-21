#!/usr/bin/env bash
set -euo pipefail

# Verify root privileges before proceeding
if [[ "$EUID" -ne 0 ]] ; then
  echo "ERROR: graph-msf install must be run as root, please run:"
  echo "  sudo $0"
  exit 1
fi

# Get the workspace root directory
ROOT=$(dirname $(dirname $(dirname $(readlink -f $0))))
echo "Workspace root directory: ${ROOT}"

KASMVNC_VERSION="1.3.4"
source "/etc/lsb-release"

# find the architecture
ARCH=$(uname -m)
if [ "$ARCH" == "x86_64" ]; then
    ARCH="amd64"
elif [ "$ARCH" == "aarch64" ]; then
    ARCH="arm64"
else
    echo "Unsupported architecture: $ARCH"
    exit 1
fi

KASMVNC_DEB_FILE="https://github.com/kasmtech/KasmVNC/releases/download/v${KASMVNC_VERSION}/kasmvncserver_${DISTRIB_CODENAME}_${KASMVNC_VERSION}_${ARCH}.deb"

# Pre-configure lightdm to skip keyboard setup
echo "keyboard-configuration keyboard-configuration/layoutcode string us" | debconf-set-selections
echo "keyboard-configuration keyboard-configuration/modelcode string pc105" | debconf-set-selections
echo "keyboard-configuration keyboard-configuration/optionscode string " | debconf-set-selections
echo "keyboard-configuration keyboard-configuration/variantcode string " | debconf-set-selections
echo "keyboard-configuration keyboard-configuration/xkb-keymap select " | debconf-set-selections
echo "keyboard-configuration keyboard-configuration/unsupported_config boolean true" | debconf-set-selections
echo "keyboard-configuration keyboard-configuration/unsupported_config_options boolean true" | debconf-set-selections

wget $KASMVNC_DEB_FILE -O /tmp/kasmvnc.deb
apt-get update && apt-get install -y /tmp/kasmvnc.deb ubuntu-mate-core mate-desktop-environment-core curl wget net-tools x11-xserver-utils xserver-xorg-video-dummy
rm -rf /var/lib/apt/lists/*

sudo tee /etc/X11/xorg.conf > /dev/null <<EOF
Section "Device"
    Identifier  "Configured Video Device"
    Driver      "dummy"
EndSection

Section "Monitor"
    Identifier  "Configured Monitor"
    HorizSync   31.5-48.5
    VertRefresh 50-70
EndSection

Section "Screen"
    Identifier  "Default Screen"
    Monitor     "Configured Monitor"
    Device      "Configured Video Device"
    DefaultDepth 24
    SubSection "Display"
        Depth   24
        Modes   "1920x1080"
    EndSubSection
EndSection
EOF

# expect <<EOF
# spawn vncserver -select-de mate :2

# expect "Provide selection number:"
# send "1\r"

# expect "Enter username (default: robotx):"
# send "robotx\r"

# expect "Password:"
# send "robotx\r"

# expect "Verify:"
# send "robotx\r"

# expect eof
# EOF

# # Copy xorg.conf if missing or different
# if ! cmp -s "$CURRENT_PATH/xorg.conf" /etc/X11/xorg.conf; then
#     sudo cp "$CURRENT_PATH/xorg.conf" /etc/X11/xorg.conf
#     echo "Copied xorg.conf"
# else
#     echo "xorg.conf is already up to date."
# fi
