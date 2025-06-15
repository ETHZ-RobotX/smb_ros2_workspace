#!/usr/bin/env bash
set -euo pipefail

# Verify root privileges before proceeding
if [[ "$EUID" -ne 0 ]] ; then
  echo "ERROR: graph-msf install must be run as root, please run:"
  echo "  sudo $0"
  exit 1
fi

python3 -m pip install --break-system-packages --no-cache-dir "mcap[ros2]"

git clone https://github.com/foxglove/mcap.git /tmp/mcap && \
    python3 -m pip install --break-system-packages /tmp/mcap/python/mcap-ros2-support && \
    rm -rf /tmp/mcap

apt-get update && \
    apt-get install -y ros-${ROS_DISTRO}-rosbag2-storage-mcap && \
    rm -rf /var/lib/apt/lists/*

apt-get update && \
    add-apt-repository universe && \
    apt-get update && \
    apt-get install -y libc++abi-dev libc++-dev liblua5.4-dev libomp-dev libgoogle-glog-dev libgflags-dev && \
    rm -rf /var/lib/apt/lists/*

apt-get update && \
    apt-get install -y software-properties-common && \
    add-apt-repository -y ppa:roehling/open3d && \
    apt-get update && \
    apt-get install -y libopen3d-dev && \
    rm -f /etc/apt/sources.list.d/roehling-ubuntu-open3d-*.list && \
    apt-get update && \
    apt-get clean && rm -rf /var/lib/apt/lists/*

# Set environment variables for CMake to resolve Unwind and other dependencies
echo 'export CMAKE_INCLUDE_PATH=/usr/include:$CMAKE_INCLUDE_PATH' >> "${HOME}/.bashrc"
echo 'export CMAKE_LIBRARY_PATH=/usr/lib/x86_64-linux-gnu:$CMAKE_LIBRARY_PATH' >> "${HOME}/.bashrc"