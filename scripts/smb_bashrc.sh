# This configuration file provides common settings for Docker containers and robot hosts.
# It includes useful aliases and environment configurations to enhance productivity.
#
# shellcheck shell=bash
# shellcheck disable=SC2139  # shellcheck: allow expansion during alias definition rather than execution

# Safety check: ensure this script is being sourced and not executed directly
if [ "${BASH_SOURCE[0]}" -ef "$0" ] ; then
  echo "ERROR: $(basename "${BASH_SOURCE[0]}") must be sourced, not executed directly!"
  exit 1
fi

WORKSPACE_ROOT=$(dirname "$(dirname "$(readlink -f "${BASH_SOURCE[0]}")")")

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
source "$ROS_SETUP_PATH/setup.bash"

# Source the workspace setup if it exists
if [ -f "$WORKSPACE_ROOT/install/setup.bash" ]; then
    echo "Sourcing workspace setup from: $WORKSPACE_ROOT/install/setup.bash"
    source "$WORKSPACE_ROOT/install/setup.bash"
fi

# Configure ROS to use CycloneDDS as the middleware implementation
export RMW_IMPLEMENTATION=rmw_cyclonedds_cpp

# Set CycloneDDS config file
export CYCLONEDDS_URI="file://$WORKSPACE_ROOT/scripts/config/cyclonedds-config.xml"
echo "CycloneDDS configured for unicast communication."

# Set a specific ROS domain ID to isolate communication between ROS nodes
export ROS_DOMAIN_ID=42

# Enable command-line completion for ROS 2 CLI tools and colcon build system commands
source /usr/share/colcon_argcomplete/hook/colcon-argcomplete.bash
source $ROS_SETUP_PATH/share/ros2cli/environment/ros2-argcomplete.bash

export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH

# Alias for recording ROS2 bags
alias smb_ros_record="$WORKSPACE_ROOT/scripts/ros/smb_record.sh"

# Function that wraps colcon build
smb_build_packages_up_to() {
    colcon build --symlink-install --merge-install --base-paths $WORKSPACE_ROOT/src --packages-up-to "$@"
}

# Bash completion function with passthrough to colcon
_smb_build_packages_up_to_completion() {
    # Extract the command name and remaining fragment for autocompletion
    local COMMAND="${COMP_WORDS[0]}"   # name of the command
    local FRAGMENT=${COMP_WORDS[*]:1}  # everything else on the line

    # Construct the autocomplete passthrough to colcon build
    COMP_LINE="colcon build --symlink-install --merge-install --base-paths $WORKSPACE_ROOT/src --packages-up-to $FRAGMENT"
    COMP_WORDS=("$COMP_LINE")     # split the command line into words
    COMP_CWORD=${#COMP_WORDS[@]}  # the number of words
    COMP_POINT=${#COMP_LINE}      # the "cursor" position at the end of command

    # Perform the autocompletion passthrough
    _python_argcomplete colcon
}

# Register the completion function
complete -o default -o nospace -F _smb_build_packages_up_to_completion smb_build_packages_up_to 