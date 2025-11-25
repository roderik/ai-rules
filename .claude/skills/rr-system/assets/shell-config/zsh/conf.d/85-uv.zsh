# UV - Fast Python package installer configuration
# Completions are provided by Homebrew in site-functions

if command -v uv &> /dev/null; then
  # Useful UV aliases
  alias uvs='uv sync'
  alias uvi='uv pip install'
  alias uvr='uv run'
  alias uvv='uv venv'
fi