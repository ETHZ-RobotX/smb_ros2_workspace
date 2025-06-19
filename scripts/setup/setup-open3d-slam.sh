#!/usr/bin/env bash
set -euo pipefail

# Verify root privileges before proceeding
if [[ "$EUID" -ne 0 ]] ; then
  echo "ERROR: open3d install must be run as root, please run:"
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

echo "Installing open3d dependencies for ROS2 $TARGET_ROS_DISTRO..."

# check cmake version, it should be 3.29.2
cmake --version
if [ $? -ne 0 ]; then
  echo "ERROR: CMake is not installed"
  exit 1
fi
CMAKE_VERSION=$(cmake --version | awk '/cmake version/ {print $3}')  
if [ "$CMAKE_VERSION" != "3.29.2" ]; then  
  echo "ERROR: CMake version is not 3.29.2 (found $CMAKE_VERSION)"  
  exit 1
fi

python3 -m pip install --break-system-packages --no-cache-dir "mcap[ros2]"

git clone https://github.com/foxglove/mcap.git /tmp/mcap && \
    python3 -m pip install --break-system-packages /tmp/mcap/python/mcap-ros2-support && \
    rm -rf /tmp/mcap

apt-get update && \
    apt-get install -y ros-${TARGET_ROS_DISTRO}-rosbag2-storage-mcap && \
    rm -rf /var/lib/apt/lists/*

apt-get update && \
    add-apt-repository -y universe && \
    apt-get update && \
    apt-get install -y libc++abi-dev libc++-dev liblua5.4-dev libomp-dev libgoogle-glog-dev libgflags-dev && \
    rm -rf /var/lib/apt/lists/*


# Install Open3D (from ppa)

# apt-get update && \
#     apt-get install -y software-properties-common && \
#     add-apt-repository -y ppa:roehling/open3d && \
#     apt-get update && \
#     apt-get install -y libopen3d-dev && \
#     rm -f /etc/apt/sources.list.d/roehling-ubuntu-open3d-*.list && \
#     apt-get update && \
#     apt-get clean && rm -rf /var/lib/apt/lists/*

# Install Open3D (from source)
readonly OPEN3D_VERSION="0.19.0"
readonly OPEN3D_INSTALL_DIR="/usr/local"

echo "Installing Open3D version ${OPEN3D_VERSION}..."
wget -qO- https://github.com/isl-org/Open3D/archive/refs/tags/v${OPEN3D_VERSION}.tar.gz | tar xzv -C /tmp

cd /tmp/Open3D-${OPEN3D_VERSION}
chmod +x util/install_deps_ubuntu.sh
DEBIAN_FRONTEND=noninteractive SUDO=command ./util/install_deps_ubuntu.sh assume-yes

mkdir build && cd build
cmake -DCMAKE_INSTALL_PREFIX=${OPEN3D_INSTALL_DIR} \
    -DBUILD_SHARED_LIBS=ON \
    -DBUILD_EXAMPLES=OFF \
    -DBUILD_PYTHON_MODULE=OFF \
    -DBUILD_GUI=OFF \
    -DCMAKE_BUILD_TYPE=Release \
    -DDEVELOPER_BUILD=OFF ..
make -j$(nproc)
make install
cd /tmp
rm -rf Open3D-${OPEN3D_VERSION}

echo "Open3d dependencies installed successfully for ROS2 $TARGET_ROS_DISTRO"