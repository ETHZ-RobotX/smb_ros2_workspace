# SMB ROS2 Workspace 🤖

This is the development workspace for Robotics Summer School 2025.

Use devcontainer to open this workspace. 🐳

## Installation 🛠️

```bash
gitman install
```

### Docker Build 🐳

Note: For Linux users, please install Docker Engine instead of Docker Desktop. See [Docker Engine installation guide](https://docs.docker.com/engine/install/ubuntu/).

[**Recommended**] Pull from github container registry:
```bash
docker pull ghcr.io/ethz-robotx/smb_ros2_workspace:main
```

or

To build the Docker image manually:
```bash
docker build --file .github/docker/Dockerfile --tag ghcr.io/ethz-robotx/smb_ros2_workspace:main .
```

### Network Configuration (Ubuntu Only) 🌐

For optimal performance with high-bandwidth topics (like camera feeds), run this configuration script on your Ubuntu host machine (not inside the container):
```bash
sudo ./scripts/setup/setup-desktop-host.sh
```

### VSCode Dev Container Setup 🛠️

1. Install the "Dev Containers" extension in VSCode
2. Open the command palette (<kbd>Ctrl</kbd>+<kbd>Shift</kbd>+<kbd>P</kbd>)
3. Select "Dev Containers: Reopen in Container"
4. VSCode will automatically:
   - Pulls the base image
   - Build the container if not already built
   - Mount your workspace
   - Install all required extensions
   - Configure the development environment

Note: Make sure Docker is running on your system before opening the dev container.

## Available Aliases 🚀

### ROS2 Recording 📹

The workspace provides a convenient alias for recording ROS2 topics to MCAP format:

```bash
smb_ros_record [OPTIONS] [SUFFIX]
```

Options:
- `-t, --topics`: Space-separated list of topics to record
- `-i, --ignore`: Space-separated list of topics to ignore
- `-a, --all`: Record all topics
- `-h, --help`: Show help message

Examples:
```bash
# Record specific topics
smb_ros_record -t '/cmd_vel /odom /imu/data'

# Record all topics except some
smb_ros_record -a -i '/camera/image_raw /diagnostics'

# Record all topics with a suffix
smb_ros_record -a test    # Creates smb_bag_TIMESTAMP_test
```

### Package Building 🏗️

Build specific packages and their dependencies:

```bash
smb_build_packages_up_to <package_name>
```

This command will build the specified package and all its dependencies using colcon.

## TMux 📺

TMux is a terminal multiplexer that allows you to manage multiple terminal sessions from a single window. It is already installed in the devcontainer. To start a new session, run `tmux` in the terminal.
### TMux Keys ⌨️

Command key - <kbd>Ctrl</kbd>+<kbd>a</kbd> (similar to screen)

The following needs to be pressed after the command key is released:

| Key | Functionality |
| --- | --- |
| <kbd>h</kbd> | 🔄 Split pane horizontally |
| <kbd>v</kbd> | 🔂 Split pane vertically |
| <kbd>x</kbd> | 🚫 Close pane |
| <kbd>X</kbd> | 🚪 Close window |
| <kbd>c</kbd> | ✨ New window |
| <kbd>r</kbd> | 📝 Rename window |
| <kbd>R</kbd> | 📋 Rename session |
| <kbd>arrow keys</kbd> | 🔍 Focus panes in a window |
| <kbd>d</kbd> | 👋 Detach from session |
| <kbd>s</kbd> | 🔎 Session chooser |
| <kbd>I</kbd> | 📦 Install plugins |
| <kbd>z</kbd> | 🔍 Toggle zoom in pane |
| <kbd>Ctrl</kbd>+<kbd>l</kbd> | 🧹 Clear the terminal |

<kbd>Alt</kbd>+<kbd>number</kbd> → Open the window with that number

