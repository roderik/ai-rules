# FZF Configuration
# Fuzzy finder setup and defaults

if command -q fzf
    # Official fzf fish integration
    fzf --fish | source

    # Custom FZF defaults
    set -gx FZF_DEFAULT_COMMAND 'fd --type f --hidden --follow --exclude .git'
    set -gx FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
    # Preview hidden by default, toggle with Ctrl+/
    set -gx FZF_DEFAULT_OPTS '--height 40% --layout=reverse --border --bind "ctrl-/:toggle-preview" --preview-window=hidden'
    set -gx FZF_CTRL_T_OPTS '--preview "bat --style=numbers --color=always --line-range :500 {}" --preview-window=right:60%'
end