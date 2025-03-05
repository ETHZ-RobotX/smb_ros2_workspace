#!/bin/bash
set -e

ROOT=$(dirname "$(dirname "$(readlink -f $0)")")

# Setup fzf completions
echo "source <(fzf --zsh)" >> ~/.zshrc

# Store command history in the workspace which is persistent across rebuilds
echo "export HISTFILE=${ROOT}/.zsh_history" >> ~/.zshrc

# Source the smb_zshrc.sh script
echo "source ${ROOT}/scripts/smb_zshrc.sh" >> ~/.zshrc

# Check for NVIDIA GPU and configure container accordingly
if lspci | grep -qi nvidia; then
    if command -v nvidia-smi >/dev/null 2>&1; then
        if command -v nvidia-container-toolkit >/dev/null 2>&1; then
            echo "NVIDIA GPU detected and container toolkit installed. GPU support enabled."
            export NVIDIA_VISIBLE_DEVICES=all
            export NVIDIA_DRIVER_CAPABILITIES=all
        else
            echo "NVIDIA GPU detected but container toolkit not found."
            echo "Please install nvidia-container-toolkit on the host system."
        fi
    else
        echo "NVIDIA GPU detected but drivers not installed."
        echo "Please install NVIDIA drivers on the host system."
    fi
fi


# Check if /dev/dri exists (if the system has a GPU or related device), give aceess to the user
if [ -d /dev/dri ]; then
    echo "/dev/dri exists, setting ACLs"
    sudo setfacl -m u:$(whoami):rw /dev/dri/*
else
    echo "/dev/dri does not exist, skipping ACLs setup"
fi