#!/usr/bin/env zsh

# Determine workspace root from script location
WORKSPACE_ROOT="$(cd "$(dirname "$(dirname "$(dirname "$(readlink -f "$0")")")")" && pwd)"

# Function to display usage information
show_usage() {
    echo "Usage: $0 [OPTIONS] [SUFFIX]"
    echo "Record ROS2 topics to MCAP format"
    echo ""
    echo "Options:"
    echo "  -t, --topics     Space-separated list of topics to record"
    echo "  -i, --ignore     Space-separated list of topics to ignore"
    echo "  -a, --all        Record all topics"
    echo "  -h, --help       Show this help message"
    echo ""
    echo "Example:"
    echo "  $0 -t '/cmd_vel /odom /imu/data'"
    echo "  $0 --all -i '/camera/image_raw /diagnostics'"
    echo "  $0 --all test    # Will create smb_recording_TIMESTAMP_test"
    echo "  $0 --all"
}

# Default values
TOPICS=""
IGNORE_TOPICS=""
RECORD_ALL=false
SUFFIX=""

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        -t|--topics)
            TOPICS="$2"
            shift 2
            ;;
        -i|--ignore)
            IGNORE_TOPICS="$2"
            shift 2
            ;;
        -a|--all)
            RECORD_ALL=true
            shift
            ;;
        -h|--help)
            show_usage
            exit 0
            ;;
        *)
            # If it's not an option, treat it as a suffix
            SUFFIX="$1"
            shift
            ;;
    esac
done

# Create data directory if it doesn't exist
DATA_DIR="${WORKSPACE_ROOT}/data/rosbags"
mkdir -p "$DATA_DIR"

# Generate timestamp for directory name
TIMESTAMP=$(date +"%Y%m%d_%H%M%S")
if [ -n "$SUFFIX" ]; then
    BAG_DIR="${DATA_DIR}/smb_bag_${TIMESTAMP}_${SUFFIX}"
else
    BAG_DIR="${DATA_DIR}/smb_bag_${TIMESTAMP}"
fi

# Build the ros2 bag record command
if [ "$RECORD_ALL" = true ]; then
    if [ -n "$IGNORE_TOPICS" ]; then
        CMD="ros2 bag record -a -o $BAG_DIR --storage mcap --exclude-topics $IGNORE_TOPICS"
    else
        CMD="ros2 bag record -a -o $BAG_DIR --storage mcap"
    fi
else
    if [ -z "$TOPICS" ]; then
        echo "Error: No topics specified. Use -t to specify topics or -a to record all topics."
        show_usage
        exit 1
    fi
    CMD="ros2 bag record -o $BAG_DIR --storage mcap $TOPICS"
fi

echo "Starting recording..."
echo "Saving to directory: $BAG_DIR"
echo "Command: $CMD"
echo "Press Ctrl+C to stop recording"

# Execute the recording command
eval $CMD
