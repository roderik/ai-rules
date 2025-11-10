#!/usr/bin/env bash
# Prompt Configuration
# Initialize Starship prompt for interactive sessions

if [[ $- == *i* ]]; then
  if command -v starship &> /dev/null; then
    eval "$(starship init bash)"
  fi
fi