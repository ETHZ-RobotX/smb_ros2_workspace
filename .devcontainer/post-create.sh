#!/bin/bash
set -e

ROOT=$(dirname "$(dirname "$(readlink -f $0)")")

# Setup fzf completions
echo "source <(fzf --zsh)" >> ~/.zshrc

# Store command history in the workspace which is persistent across rebuilds
echo "export HISTFILE=${ROOT}/.zsh_history" >> ~/.zshrc

# Source the smb_zshrc.sh script
echo "source ${ROOT}/scripts/smb_zshrc.sh" >> ~/.zshrc

# git config
git config core.autocrlf false # Prevent line ending conversion on Windows

# Setup tmux
mkdir -p ~/.config/tmux
ln -s ${ROOT}/.tmux.conf ~/.config/tmux/tmux.conf

git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# Start tmux server in the background
tmux new-session -d

# Source tmux config
tmux source ~/.config/tmux/tmux.conf

# Install tmux plugins non-interactively
~/.tmux/plugins/tpm/bin/install_plugins

# Stop tmux server (optional, remove if you want to keep it running)
tmux kill-server