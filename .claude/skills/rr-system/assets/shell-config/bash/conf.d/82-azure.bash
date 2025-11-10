#!/usr/bin/env bash
# Azure CLI completion

# Enable Azure CLI completion if available
if command -v az &> /dev/null; then
  # Azure CLI provides its own bash completion
  if [[ -f "/opt/homebrew/etc/bash_completion.d/az" ]]; then
    source "/opt/homebrew/etc/bash_completion.d/az"
  elif [[ -f "/usr/local/etc/bash_completion.d/az" ]]; then
    source "/usr/local/etc/bash_completion.d/az"
  fi
fi