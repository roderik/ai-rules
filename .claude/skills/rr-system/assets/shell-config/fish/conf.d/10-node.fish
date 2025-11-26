# Node.js Configuration
# Fast Node Manager setup (cached)

if command -q fnm
    set -l cache_dir ~/.cache/fish/hooks
    set -l cache_file "$cache_dir/fnm.fish"
    set -l tool_path (command -v fnm)

    if not test -f "$cache_file"; or test "$tool_path" -nt "$cache_file"
        mkdir -p "$cache_dir"
        fnm env --use-on-cd > "$cache_file" 2>/dev/null
    end

    test -f "$cache_file" && source "$cache_file"
end