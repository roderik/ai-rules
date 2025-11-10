#!/usr/bin/env zsh
# Azure CLI completion

# Enable Azure CLI completion if available
if command -v az &> /dev/null; then
  # Azure CLI provides completion via homebrew
  if [[ -f "/opt/homebrew/share/zsh/site-functions/_az" ]]; then
    # Already in fpath, will be loaded automatically
    :
  elif [[ -f "/usr/local/share/zsh/site-functions/_az" ]]; then
    # Already in fpath, will be loaded automatically
    :
  fi
fi