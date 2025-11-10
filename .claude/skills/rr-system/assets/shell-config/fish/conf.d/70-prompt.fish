# Prompt Configuration
# Initialize Starship prompt for interactive sessions

if status is-interactive
    if command -q starship
        starship init fish | source
    end
end