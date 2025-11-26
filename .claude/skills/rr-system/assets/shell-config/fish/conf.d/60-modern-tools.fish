# Modern Shell Enhancements
# Setup for modern CLI tools like zoxide, atuin
# All tools use caching to speed up shell startup
# Note: direnv is handled by Homebrew's vendor_conf.d/direnv.fish

set -l cache_dir ~/.cache/fish/hooks

# zoxide - Smarter cd command (cached)
if command -q zoxide
    set -l cache_file "$cache_dir/zoxide.fish"
    set -l tool_path (command -v zoxide)

    if not test -f "$cache_file"; or test "$tool_path" -nt "$cache_file"
        mkdir -p "$cache_dir"
        zoxide init fish > "$cache_file" 2>/dev/null
    end

    test -f "$cache_file" && source "$cache_file"

    # Create cd as a function that calls z to avoid alias expansion issues
    function cd --wraps z
        z $argv
    end
    alias cdi='zi' # interactive selection
end

# atuin - Better shell history (cached)
if command -q atuin
    set -l cache_file "$cache_dir/atuin.fish"
    set -l tool_path (command -v atuin)

    if not test -f "$cache_file"; or test "$tool_path" -nt "$cache_file"
        mkdir -p "$cache_dir"
        atuin init fish > "$cache_file" 2>/dev/null
    end

    test -f "$cache_file" && source "$cache_file"
end