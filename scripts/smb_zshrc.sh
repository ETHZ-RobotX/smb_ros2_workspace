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
if [ -d "/opt/ros/humble" ]; then
    ROS_DISTRO="humble"
elif [ -d "/opt/ros/jazzy" ]; then
    ROS_DISTRO="jazzy"
else
    # Find any ROS installation
    for dir in /opt/ros/*; do
        if [ -d "$dir" ]; then
            ROS_DISTRO=$(basename "$dir")
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
source /opt/ros/$ROS_DISTRO/setup.zsh

# Source the workspace setup if it exists
if [ -f "$WORKSPACE_ROOT/install/setup.zsh" ]; then
    echo "Sourcing workspace setup from: $WORKSPACE_ROOT/install/setup.zsh"
    source "$WORKSPACE_ROOT/install/setup.zsh"
fi

# Configure ROS to use FastDDS as the middleware implementation (enforcing default)
export RMW_IMPLEMENTATION=rmw_fastrtps_cpp

# Set fastdds config file
export FASTRTPS_DEFAULT_PROFILES_FILE=$WORKSPACE_ROOT/scripts/config/fastdds-config.xml
echo "FastDDS configured for localhost-only communication."

# Set a specific ROS domain ID to isolate communication between ROS nodes
export ROS_DOMAIN_ID=42