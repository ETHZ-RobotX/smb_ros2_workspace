#!/bin/bash
set -e

ROOT=$(dirname "$(dirname "$(readlink -f $0)")")

# Set environment variables for CMake to resolve Unwind and other dependencies
ARCH=$(uname -m)
if [[ "$ARCH" == "x86_64" ]]; then
  LIB_PATH="/usr/lib/x86_64-linux-gnu"
elif [[ "$ARCH" == "aarch64" ]]; then
  LIB_PATH="/usr/lib/aarch64-linux-gnu"
else
  echo "ERROR: Unsupported architecture: $ARCH"
  exit 1
fi

# Setup fancy prompt
chmod +x "${ROOT}/scripts/setup/setup-fancy-prompt.sh"
"${ROOT}/scripts/setup/setup-fancy-prompt.sh" "${USER}"

echo "export CMAKE_INCLUDE_PATH=/usr/include:\$CMAKE_INCLUDE_PATH" >> "${HOME}/.bashrc"
echo "export CMAKE_LIBRARY_PATH=${LIB_PATH}:\$CMAKE_LIBRARY_PATH" >> "${HOME}/.bashrc"

# Setup fzf completions
echo "source <(fzf --zsh)" >> ~/.zshrc
echo "source <(fzf --bash)" >> ~/.bashrc

# Store command history in the workspace which is persistent across rebuilds
echo "export HISTFILE=${ROOT}/.zsh_history" >> ~/.zshrc
echo "export HISTFILE=${ROOT}/.bash_history" >> ~/.bashrc

# Source the smb script
echo "source ${ROOT}/scripts/smb_zshrc.sh" >> ~/.zshrc
echo "source ${ROOT}/scripts/smb_bashrc.sh" >> ~/.bashrc

# git config
git config core.autocrlf false # Prevent line ending conversion on Windows

# kasmvnc setting up
mkdir -p "/home/${USER}/.vnc"
cp "${ROOT}/scripts/config/kasmvnc.yaml" "/home/${USER}/.vnc/kasmvnc.yaml"
cp "${ROOT}/scripts/config/xstartup" "/home/${USER}/.vnc/xstartup"
chmod +x "/home/${USER}/.vnc/xstartup"
echo "Setup kasmvnc done"

# kasmvnc setting up
mkdir -p "/home/${USER}/.vnc"
cp "${ROOT}/scripts/config/kasmvnc.yaml" "/home/${USER}/.vnc/kasmvnc.yaml"
cp "${ROOT}/scripts/config/xstartup" "/home/${USER}/.vnc/xstartup"
chmod +x "/home/${USER}/.vnc/xstartup"
sudo usermod -aG video dishtaweera
echo "Setup kasmvnc done"

# Setup tmux - create config directory and link config
mkdir -p ~/.config/tmux
ln -sf ${ROOT}/.tmux.conf ~/.config/tmux/tmux.conf

# Clone tmux plugin manager if it doesn't exist
if [ ! -d ~/.tmux/plugins/tpm ]; then
    git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm
fi

# Start tmux server in the background
tmux new-session -d

# Source tmux config
tmux source ~/.config/tmux/tmux.conf

# Install tmux plugins non-interactively
~/.tmux/plugins/tpm/bin/install_plugins

# Stop tmux server (optional, remove if you want to keep it running)
tmux kill-server