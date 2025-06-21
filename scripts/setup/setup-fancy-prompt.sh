#!/bin/bash

# Setup fancy prompt similar to devcontainer features
# This replicates the prompt from ghcr.io/devcontainers/features/common-utils:2

# Function to setup fancy prompt for bash
setup_bash_prompt() {
    local user_home="$1"
    local bashrc="$user_home/.bashrc"
    
    # Add fancy prompt configuration to .bashrc
    cat >> "$bashrc" << 'EOF'

# Fancy prompt configuration (similar to devcontainer features)
# Colors for prompt
if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
    color_prompt=yes
else
    color_prompt=
fi

# Set prompt colors
if [ "$color_prompt" = yes ]; then
    PS1='\[\033[01;32m\]\u\[\033[00m\] \[\033[01;33m\]➜\[\033[00m\] \[\033[01;34m\]\w\[\033[00m\]'
    # Add git branch info
    if [ -f /usr/lib/git-core/git-sh-prompt ]; then
        . /usr/lib/git-core/git-sh-prompt
        # Only show the branch name—disable all extra symbols:
        unset GIT_PS1_SHOWDIRTYSTATE GIT_PS1_SHOWSTASHSTATE GIT_PS1_SHOWUNTRACKEDFILES
        PS1='\[\033[01;32m\]\u\[\033[00m\] \[\033[01;33m\]➜\[\033[00m\] \[\033[01;34m\]\w\[\033[00m\]\[\033[01;31m\]$(__git_ps1 " (%s)")\[\033[00m\] \[\033[01;37m\]\$\[\033[00m\] '
    else
        PS1='\[\033[01;32m\]\u\[\033[00m\] \[\033[01;33m\]➜\[\033[00m\] \[\033[01;34m\]\w\[\033[00m\] \[\033[01;37m\]\$\[\033[00m\] '
    fi
else
    PS1='\u ➜ \w \$ '
fi

# Uncomment for a colored prompt (if you really want it):
# force_color_prompt=yes

if [ -n "$force_color_prompt" ]; then
    if [ -x /usr/bin/tput ] && tput setaf 1 >&/dev/null; then
        color_prompt=yes
    else
        color_prompt=
    fi
fi

unset color_prompt force_color_prompt
EOF
}

# Function to setup fancy prompt for zsh
setup_zsh_prompt() {
    local user_home="$1"
    local zshrc="$user_home/.zshrc"
    
    # Add fancy prompt configuration to .zshrc
    cat >> "$zshrc" << 'EOF'

# Fancy prompt configuration (similar to devcontainer features)
autoload -U colors && colors
setopt PROMPT_SUBST

# Git prompt function
git_prompt() {
    if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
        local BRANCH
        BRANCH=$(git symbolic-ref --short HEAD 2>/dev/null || git rev-parse --short HEAD 2>/dev/null)
        if [ -n "$BRANCH" ]; then
            printf '(%s) ' "$BRANCH"
        fi
    fi
}

# Main prompt
PROMPT='%{$fg_bold[green]%}%n %{$fg_bold[yellow]%}➜ %{$fg_bold[blue]%}%~%{$reset_color%} $(git_prompt)%{$fg[white]%}$%{$reset_color%} '
RPROMPT=''
EOF
}

# Main function
main() {
    local username="$1"
    local user_home="/home/$username"
    
    if [ -z "$username" ]; then
        echo "Usage: $0 <username>"
        exit 1
    fi
    
    if [ ! -d "$user_home" ]; then
        echo "Error: User home directory $user_home does not exist"
        exit 1
    fi
    
    echo "Setting up fancy prompt for user: $username"
    
    # Setup bash prompt
    if [ -f "$user_home/.bashrc" ]; then
        setup_bash_prompt "$user_home"
        echo "✓ Bash prompt configured"
    fi
    
    # Setup zsh prompt
    if [ -f "$user_home/.zshrc" ]; then
        setup_zsh_prompt "$user_home"
        echo "✓ Zsh prompt configured"
    fi
    
    # Fix ownership
    chown -R "$username:$username" \
      "$user_home/.bashrc" "$user_home/.zshrc" 2>/dev/null || true
    
    echo "Fancy prompt setup complete for $username"
}

main "$@"
