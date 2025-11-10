#!/bin/bash
# Bash Configuration
# Modern shell setup with powerful CLI tools

# Source modular configuration if available
if [[ -d ~/.config/bash/conf.d ]]; then
  for config in ~/.config/bash/conf.d/*.bash; do
    [[ -f "$config" ]] && source "$config"
  done
fi