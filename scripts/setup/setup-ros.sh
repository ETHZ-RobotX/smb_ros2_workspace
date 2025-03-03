#!/usr/bin/env bash
#
# Script to install and set up ROS2 for Docker containers and direct hardware installations.
# Handles ROS2 package installation, rosdep configuration, and system setup.
#
set -euo pipefail

# Verify root privileges before proceeding
if [[ "$EUID" -ne 0 ]] ; then
  echo "ERROR: ros install must be run as root, please run:"
  echo "  sudo $0"
  exit 1
fi

# Set up paths to find configuration files
readonly SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
readonly CONFIG_DIR="$(realpath "$SCRIPT_DIR"/../config)"

# Use locally stored GPG key instead of downloading from internet
readonly ROS_KEY_CACHED_FILE="$CONFIG_DIR/ros.key.gpg"
readonly ROS_KEY_DESTINATION="/usr/share/keyrings/ros-archive-keyring.gpg"

# Copy the key file without prompting
cp "$ROS_KEY_CACHED_FILE" "$ROS_KEY_DESTINATION"

# Configure apt repository for ROS2 packages
source "/etc/os-release"
readonly ROS_DEB_ENTRY="deb\
  [arch=$(dpkg --print-architecture) signed-by=$ROS_KEY_DESTINATION]\
  http://packages.ros.org/ros2/ubuntu
  $UBUNTU_CODENAME
  main"
# shellcheck disable=SC2086
echo $ROS_DEB_ENTRY > /etc/apt/sources.list.d/ros2.list

# Refresh package lists
apt-get update

# Determine ROS2 distribution based on Ubuntu version
if [[ "$VERSION_ID" == "24.04" ]]; then
  readonly TARGET_ROS_DISTRO="jazzy"
elif [[ "$VERSION_ID" == "22.04" ]]; then
  readonly TARGET_ROS_DISTRO="humble"
else
  echo "ERROR: Unsupported Ubuntu version: $VERSION_ID"
  echo "This script supports Ubuntu 22.04 (Humble) and 24.04 (Jazzy)"
  exit 1
fi

echo "Installing ROS2 $TARGET_ROS_DISTRO for Ubuntu $VERSION_ID ($UBUNTU_CODENAME)"

# Install ROS2 desktop and additional tools
apt-get install -y --no-install-recommends \
  ros-$TARGET_ROS_DISTRO-desktop \
  ros-$TARGET_ROS_DISTRO-rosbag2-storage-mcap \
  ros-$TARGET_ROS_DISTRO-ros-gz-sim \
  ros-$TARGET_ROS_DISTRO-plotjuggler-ros \
  python3-colcon-common-extensions \
  python3-colcon-clean \
  python3-rosdep

# Load ROS2 environment variables
set +u
source "/opt/ros/$TARGET_ROS_DISTRO/setup.bash"
set -u

# Set up rosdep package manager
rm -rf /etc/ros/rosdep/sources.list.d  # Clean up any previous installations
rosdep init
rosdep update
