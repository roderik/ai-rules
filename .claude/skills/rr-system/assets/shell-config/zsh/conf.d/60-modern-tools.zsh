#!/usr/bin/env zsh
# Modern Shell Enhancements
# Setup for modern CLI tools like direnv, atuin

# direnv - Per-project environment variables
if command -v direnv &> /dev/null; then
  eval "$(direnv hook zsh)"
fi

# atuin - Better shell history
if command -v atuin &> /dev/null; then
  eval "$(atuin init zsh)"
fi