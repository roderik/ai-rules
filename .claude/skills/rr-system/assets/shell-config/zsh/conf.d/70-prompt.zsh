#!/usr/bin/env zsh
# Prompt Configuration
# Initialize Starship prompt for interactive sessions

if [[ -o interactive ]]; then
  if command -v starship &> /dev/null; then
    eval "$(starship init zsh)"
  fi
fi