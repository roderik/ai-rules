#!/usr/bin/env bash
# UV - Fast Python package installer configuration

if command -v uv &> /dev/null; then
  # Use Homebrew-provided completion if available
  # Fallback: cache completion if Homebrew version unavailable
  if [[ ! -f /opt/homebrew/etc/bash_completion.d/uv ]] && \
     [[ ! -f /usr/local/etc/bash_completion.d/uv ]]; then
    _uv_completion_cache="$HOME/.cache/bash/completions/uv.bash"

    if [[ ! -f "$_uv_completion_cache" ]] || [[ "$(command -v uv)" -nt "$_uv_completion_cache" ]]; then
      mkdir -p "$HOME/.cache/bash/completions"
      uv generate-shell-completion bash > "$_uv_completion_cache" 2>/dev/null
    fi

    [[ -f "$_uv_completion_cache" ]] && source "$_uv_completion_cache"
    unset _uv_completion_cache
  fi

  # Useful UV aliases
  alias uvs='uv sync'
  alias uvi='uv pip install'
  alias uvr='uv run'
  alias uvv='uv venv'
fi
