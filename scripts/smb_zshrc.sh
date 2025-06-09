# This configuration file provides common settings for Docker containers and robot hosts.
# It includes useful aliases and environment configurations to enhance productivity.
#
# shellcheck shell=bash      # shellcheck: ignore missing shebang as this file is meant to be sourced
# shellcheck disable=SC2139  # shellcheck: allow expansion during alias definition rather than execution

# Safety check: ensure this script is being sourced and not executed directly
if [ "${BASH_SOURCE[0]}" -ef "$0" ] ; then
  echo "ERROR: $(basename "${BASH_SOURCE[0]}") must be sourced, not executed directly!"
  exit 1
fi

WORKSPACE_ROOT=$(dirname "$(dirname "$(readlink -f $0)")")

# Detect installed ROS version and source the appropriate setup file
if [ -d "/opt/ros/humble/install" ]; then
    ROS_DISTRO="humble"
    ROS_SETUP_PATH="/opt/ros/humble/install"
elif [ -d "/opt/ros/humble" ]; then
    ROS_DISTRO="humble"
    ROS_SETUP_PATH="/opt/ros/humble"
elif [ -d "/opt/ros/jazzy" ]; then
    ROS_DISTRO="jazzy"
    ROS_SETUP_PATH="/opt/ros/jazzy"
else
    # Find any ROS installation
    for dir in /opt/ros/*; do
        if [ -d "$dir" ]; then
            ROS_DISTRO=$(basename "$dir")
            if [ -d "$dir/install" ]; then
                ROS_SETUP_PATH="$dir/install"
            else
                ROS_SETUP_PATH="$dir"
            fi
            break
        fi
    done
    
    if [ -z "$ROS_DISTRO" ]; then
        echo "No ROS distribution found in /opt/ros/"
        exit 1
    fi
fi

echo "Found ROS distribution: $ROS_DISTRO"

# Setup the ROS environment in shells
source "$ROS_SETUP_PATH/setup.zsh"

# Source the workspace setup if it exists
if [ -f "$WORKSPACE_ROOT/install/setup.zsh" ]; then
    echo "Sourcing workspace setup from: $WORKSPACE_ROOT/install/setup.zsh"
    source "$WORKSPACE_ROOT/install/setup.zsh"
fi

# DDS Configuration
export SMB_DDS_CONFIG_DIR="$WORKSPACE_ROOT/scripts/config"
export SMB_CURRENT_DDS="cyclonedds"  # DDS Implementation: cyclonedds or fastdds

# Function to switch between DDS implementations
smb_switch_dds() {
    if [ "$1" = "cyclonedds" ]; then
        export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp
        export CYCLONEDDS_URI="file://$SMB_DDS_CONFIG_DIR/cyclonedds-config.xml"
        export FASTRTPS_DEFAULT_PROFILES_FILE=""
        export SMB_CURRENT_DDS="cyclonedds"
        echo "CycloneDDS configured as DDS layer."
    elif [ "$1" = "fastdds" ]; then
        export RMW_IMPLEMENTATION=rmw_fastrtps_cpp
        export CYCLONEDDS_URI=""
        export FASTRTPS_DEFAULT_PROFILES_FILE="$SMB_DDS_CONFIG_DIR/fastdds-config.xml"
        export SMB_CURRENT_DDS="fastdds"
        echo "FastDDS configured as DDS layer."
    else
        echo "Error: Invalid DDS implementation. Use 'cyclonedds' or 'fastdds'"
        return 1
    fi
}

# Initialize with default DDS implementation
smb_switch_dds $SMB_CURRENT_DDS

# Set a specific ROS domain ID to isolate communication between ROS nodes
export ROS_DOMAIN_ID=42

# Enable command-line completion for ROS 2 CLI tools and colcon build system commands
source /usr/share/colcon_argcomplete/hook/colcon-argcomplete.zsh
source $ROS_SETUP_PATH/share/ros2cli/environment/ros2-argcomplete.zsh

export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH

# Alias for recording ROS2 bags
alias smb_ros_record="$WORKSPACE_ROOT/scripts/ros/smb_record.sh"

# Alias that wraps colcon build
smb_build_packages_up_to() {
    colcon build --symlink-install --merge-install --base-paths $WORKSPACE_ROOT/src --packages-up-to "$@"
}