#!/usr/bin/env fish
# Tmux configuration

# Set default terminal for better color support
set -gx TERM "xterm-256color"

# Tmux aliases
if type -q tmux
    alias tma='tmux attach -t'
    alias tms='tmux new-session -s'
    alias tml='tmux list-sessions'
    alias tmk='tmux kill-session -t'
    alias tmka='tmux kill-server'
end