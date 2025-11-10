#!/usr/bin/env zsh
# Tmux configuration

# Set default terminal for better color support
export TERM="xterm-256color"

# Tmux aliases
if command -v tmux &> /dev/null; then
  alias tma='tmux attach -t'
  alias tms='tmux new-session -s'
  alias tml='tmux list-sessions'
  alias tmk='tmux kill-session -t'
  alias tmka='tmux kill-server'
fi