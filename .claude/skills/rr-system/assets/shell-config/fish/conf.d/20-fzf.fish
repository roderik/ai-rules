# FZF Configuration
# Fuzzy finder setup and defaults

if command -q fzf
    # Set up fzf key bindings and fuzzy completion
    # Temporarily disabled due to fish bind syntax changes
    # fzf --fish | source

    # Manual key bindings with new fish syntax
    bind ctrl-r 'fzf-history-widget'
    bind -M insert ctrl-r 'fzf-history-widget'
    bind ctrl-t 'fzf-file-widget'
    bind -M insert ctrl-t 'fzf-file-widget'
    bind alt-c 'fzf-cd-widget'
    bind -M insert alt-c 'fzf-cd-widget'

    # Custom FZF defaults
    set -gx FZF_DEFAULT_COMMAND 'fd --type f --hidden --follow --exclude .git'
    set -gx FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
    set -gx FZF_DEFAULT_OPTS '--height 40% --layout=reverse --border --preview "bat --style=numbers --color=always --line-range :500 {}"'
end