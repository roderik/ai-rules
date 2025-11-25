# UV - Fast Python package installer configuration
# Completions are provided by Homebrew in vendor_completions.d

if type -q uv
    # Useful UV aliases
    alias uvs='uv sync'
    alias uvi='uv pip install'
    alias uvr='uv run'
    alias uvv='uv venv'
end