#!/usr/bin/env bash
# UV - Fast Python package installer configuration

# Enable UV completion if available
if command -v uv &> /dev/null; then
  eval "$(uv generate-shell-completion bash)"
  
  # Useful UV aliases
  alias uvs='uv sync'
  alias uvi='uv pip install'
  alias uvr='uv run'
  alias uvv='uv venv'
fi