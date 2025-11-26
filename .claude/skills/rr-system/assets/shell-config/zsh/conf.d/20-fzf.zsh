# FZF Configuration
# Fuzzy finder setup and defaults

if command -v fzf &> /dev/null; then
  # Set up fzf key bindings and completion (use static Homebrew paths)
  # These files are lightweight, no caching needed
  if [[ -f /opt/homebrew/opt/fzf/shell/key-bindings.zsh ]]; then
    source /opt/homebrew/opt/fzf/shell/key-bindings.zsh
    source /opt/homebrew/opt/fzf/shell/completion.zsh
  elif [[ -f /usr/local/opt/fzf/shell/key-bindings.zsh ]]; then
    source /usr/local/opt/fzf/shell/key-bindings.zsh
    source /usr/local/opt/fzf/shell/completion.zsh
  fi

  # Custom FZF defaults
  export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'
  export FZF_CTRL_T_COMMAND="$FZF_DEFAULT_COMMAND"
  # Preview hidden by default, toggle with Ctrl+/
  export FZF_DEFAULT_OPTS='--height 40% --layout=reverse --border --bind "ctrl-/:toggle-preview" --preview-window=hidden'
  export FZF_CTRL_T_OPTS='--preview "bat --style=numbers --color=always --line-range :500 {}" --preview-window=right:60%'
fi