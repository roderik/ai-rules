#!/usr/bin/env bash
# Modern Shell Enhancements
# Setup for modern CLI tools like direnv, atuin

# direnv - Per-project environment variables
if command -v direnv &> /dev/null; then
  eval "$(direnv hook bash)"
fi

# atuin - Better shell history
if command -v atuin &> /dev/null; then
  eval "$(atuin init bash)"
fi