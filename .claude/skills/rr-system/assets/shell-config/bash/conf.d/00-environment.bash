#!/usr/bin/env bash
# Environment Variables

# Editor settings
export EDITOR=nvim
export VISUAL=nvim

# Node.js settings
export NODE_NO_WARNINGS=1

# Claude Code settings
export FORCE_AUTO_BACKGROUND_TASKS=1
export ENABLE_BACKGROUND_TASKS=1

# Homebrew settings
export HOMEBREW_NO_ENV_HINTS=1

# Path additions
[[ -d "$HOME/.local/bin" ]] && export PATH="$HOME/.local/bin:$PATH"
[[ -d "$HOME/bin" ]] && export PATH="$HOME/bin:$PATH"

# FZF settings
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border'