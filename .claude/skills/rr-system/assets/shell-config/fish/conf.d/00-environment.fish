# Environment Variables

# Editor settings
set -x EDITOR nvim
set -x VISUAL nvim

# Node.js settings
set -x NODE_NO_WARNINGS 1

# Claude Code settings
set -x FORCE_AUTO_BACKGROUND_TASKS 1
set -x ENABLE_BACKGROUND_TASKS 1

# Homebrew settings
set -x HOMEBREW_NO_ENV_HINTS 1

# Path additions
fish_add_path ~/.local/bin
fish_add_path ~/bin

# FZF settings
set -x FZF_DEFAULT_COMMAND 'fd --type f --hidden --follow --exclude .git'
set -x FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
set -x FZF_DEFAULT_OPTS '--height 40% --layout=reverse --border'

set fish_greeting
