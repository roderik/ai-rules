#!/usr/bin/env bash
# 1Password CLI Configuration
# Uses cached completion for performance

if command -v op &> /dev/null; then
  _op_completion_cache="$HOME/.cache/bash/completions/op.bash"

  # Regenerate cache if op binary is newer than cache
  if [[ ! -f "$_op_completion_cache" ]] || [[ "$(command -v op)" -nt "$_op_completion_cache" ]]; then
    mkdir -p "$HOME/.cache/bash/completions"
    op completion bash > "$_op_completion_cache" 2>/dev/null
  fi

  [[ -f "$_op_completion_cache" ]] && source "$_op_completion_cache"
  unset _op_completion_cache
fi
