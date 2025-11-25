# 1Password CLI configuration
# Completions are cached for performance

if command -q op
    set -l cache_dir ~/.cache/fish/completions
    set -l cache_file "$cache_dir/op.fish"
    set -l op_path (command -v op)

    # Regenerate cache if it doesn't exist or op binary is newer
    if not test -f "$cache_file"; or test "$op_path" -nt "$cache_file"
        mkdir -p "$cache_dir"
        op completion fish > "$cache_file" 2>/dev/null
    end

    test -f "$cache_file" && source "$cache_file"
end