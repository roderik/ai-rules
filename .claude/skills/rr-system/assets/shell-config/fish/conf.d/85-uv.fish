#!/usr/bin/env fish
# UV - Fast Python package installer configuration

# Enable UV completion if available
if type -q uv
    uv generate-shell-completion fish | source
    
    # Useful UV aliases
    alias uvs='uv sync'
    alias uvi='uv pip install'
    alias uvr='uv run'
    alias uvv='uv venv'
end