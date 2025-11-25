# Modern Shell Enhancements
# Setup for modern CLI tools like direnv, zoxide, atuin

# direnv - Per-project environment variables (cached)
if command -q direnv
    set -l cache_dir ~/.cache/fish/hooks
    set -l cache_file "$cache_dir/direnv.fish"
    set -l direnv_path (command -v direnv)

    if not test -f "$cache_file"; or test "$direnv_path" -nt "$cache_file"
        mkdir -p "$cache_dir"
        direnv hook fish > "$cache_file" 2>/dev/null
    end

    test -f "$cache_file" && source "$cache_file"
end

# zoxide - Smarter cd command
if command -q zoxide
    zoxide init fish | source
    # Create cd as a function that calls z to avoid alias expansion issues
    function cd --wraps z
        z $argv
    end
    alias cdi='zi' # interactive selection
end

# atuin - Better shell history
if command -q atuin
    atuin init fish | source
end