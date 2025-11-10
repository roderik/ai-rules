#!/usr/bin/env zsh
# Homebrew setup
# Detects and configures Homebrew for M-series vs Intel Macs

if [[ -e /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -e /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# Homebrew completions
if command -v brew &> /dev/null; then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
  
  # Load completions
  autoload -Uz compinit && compinit
fi