#!/usr/bin/env bash
# FZF Configuration
# Fuzzy finder setup and defaults

if command -v fzf &> /dev/null; then
  # Set up fzf key bindings and fuzzy completion
  if [[ -f /opt/homebrew/opt/fzf/shell/key-bindings.bash ]]; then
    source /opt/homebrew/opt/fzf/shell/key-bindings.bash
  elif [[ -f /usr/local/opt/fzf/shell/key-bindings.bash ]]; then
    source /usr/local/opt/fzf/shell/key-bindings.bash
  elif [[ -f ~/.fzf.bash ]]; then
    source ~/.fzf.bash
  fi
  
  if [[ -f /opt/homebrew/opt/fzf/shell/completion.bash ]]; then
    source /opt/homebrew/opt/fzf/shell/completion.bash
  elif [[ -f /usr/local/opt/fzf/shell/completion.bash ]]; then
    source /usr/local/opt/fzf/shell/completion.bash
  fi
  
  # Custom FZF defaults
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --preview "bat --style=numbers --color=always --line-range :500 {}"'
fi