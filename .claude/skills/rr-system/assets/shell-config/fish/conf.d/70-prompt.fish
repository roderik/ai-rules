# Prompt Configuration
# Initialize Starship prompt for interactive sessions (cached)

if status is-interactive
    if command -q starship
        set -l cache_dir ~/.cache/fish/hooks
        set -l cache_file "$cache_dir/starship.fish"
        set -l tool_path (command -v starship)

        if not test -f "$cache_file"; or test "$tool_path" -nt "$cache_file"
            mkdir -p "$cache_dir"
            # Use --print-full-init to get the actual init script, not just a source command
            starship init fish --print-full-init > "$cache_file" 2>/dev/null
        end

        test -f "$cache_file" && source "$cache_file"

        # Enable transient prompts (Fish 4.0+ / Starship feature)
        # Shows simplified prompt for previously executed commands
        # The starship_transient_prompt_func is defined in 05-fish4-features.fish
        type -q enable_transience && enable_transience
    end
end