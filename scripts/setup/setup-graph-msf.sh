#!/usr/bin/env bash
set -euo pipefail

# Parse command line arguments
FORCE_INSTALL=false
while [[ $# -gt 0 ]]; do
    case $1 in
        -f|--force)
            FORCE_INSTALL=true
            shift
            ;;
        *)
            echo "Unknown option: $1"
            exit 1
            ;;
    esac
done

# Verify root privileges before proceeding
if [[ "$EUID" -ne 0 ]] ; then
  echo "ERROR: graph-msf install must be run as root, please run:"
  echo "  sudo $0"
  exit 1
fi

# Determine ROS2 distribution based on Ubuntu version
source "/etc/os-release"
if [[ "$VERSION_ID" == "24.04" ]]; then
  readonly TARGET_ROS_DISTRO="jazzy"
elif [[ "$VERSION_ID" == "22.04" ]]; then
  readonly TARGET_ROS_DISTRO="humble"
else
  echo "ERROR: Unsupported Ubuntu version: $VERSION_ID"
  echo "This script supports Ubuntu 22.04 (Humble) and 24.04 (Jazzy)"
  exit 1
fi

echo "Installing graph-msf dependencies for ROS2 $TARGET_ROS_DISTRO..."

# Update package lists
apt-get update

# Install basic build tools and dependencies
apt-get install -y \
    build-essential \
    cmake \
    curl \
    git \
    python3-colcon-common-extensions \
    python3-colcon-clean \
    python3-dev \
    libeigen3-dev \
    libtbb-dev \
    ros-$TARGET_ROS_DISTRO-kdl-parser \
    ros-$TARGET_ROS_DISTRO-tf2 \
    ros-$TARGET_ROS_DISTRO-tf2-kdl \
    ros-$TARGET_ROS_DISTRO-cv-bridge \
    ros-$TARGET_ROS_DISTRO-grid-map \
    ros-$TARGET_ROS_DISTRO-tf2-eigen \
    ros-$TARGET_ROS_DISTRO-desktop \
    software-properties-common \
    libxrandr-dev \
    libxinerama-dev \
    libxcursor-dev \
    libssl-dev \
    liblua5.2-dev \
    libgoogle-glog-dev \
    libx11-dev \
    libglfw3 \
    libglfw3-dev \
    wget \
    libboost-all-dev

# Install GTSAM
export PATH=/usr/local/bin:$PATH
# Check if GTSAM is already installed by looking for a key header file
if [ -f "/usr/local/include/gtsam/base/Vector.h" ] && [ "$FORCE_INSTALL" = false ]; then
    echo "GTSAM is already installed"
else
    echo "Installing GTSAM..."
    git clone https://github.com/leggedrobotics/gtsam_fork /tmp/gtsam_fork
    cd /tmp/gtsam_fork
    git checkout gtsam_rsl
    mkdir build && cd build

    echo "Installing GTSAM"
    cmake .. \
        -DCMAKE_BUILD_TYPE=Release \
        -DGTSAM_POSE3_EXPMAP=ON \
        -DGTSAM_ROT3_EXPMAP=ON \
        -DGTSAM_USE_QUATERNIONS=ON \
        -DGTSAM_USE_SYSTEM_EIGEN=ON \
        -DGTSAM_BUILD_WITH_MARCH_NATIVE=OFF \
        -DGTSAM_WITH_TBB=OFF
    make install -j$(nproc)
    cd /tmp
    rm -rf gtsam_fork
    echo "GTSAM installed successfully"
fi

echo "Graph MSF dependencies installation completed for ROS2 $TARGET_ROS_DISTRO!"
