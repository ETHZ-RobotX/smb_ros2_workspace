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