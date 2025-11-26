# FZF Configuration
# Fuzzy finder setup and defaults (cached)

if command -q fzf
    set -l cache_dir ~/.cache/fish/hooks
    set -l cache_file "$cache_dir/fzf.fish"
    set -l tool_path (command -v fzf)

    if not test -f "$cache_file"; or test "$tool_path" -nt "$cache_file"
        mkdir -p "$cache_dir"
        fzf --fish > "$cache_file" 2>/dev/null
    end

    test -f "$cache_file" && source "$cache_file"

    # Custom FZF defaults
    set -gx FZF_DEFAULT_COMMAND 'fd --type f --hidden --follow --exclude .git'
    set -gx FZF_CTRL_T_COMMAND "$FZF_DEFAULT_COMMAND"
    # Preview hidden by default, toggle with Ctrl+/
    set -gx FZF_DEFAULT_OPTS '--height 40% --layout=reverse --border --bind "ctrl-/:toggle-preview" --preview-window=hidden'
    set -gx FZF_CTRL_T_OPTS '--preview "bat --style=numbers --color=always --line-range :500 {}" --preview-window=right:60%'
end