#!/usr/bin/env bash
# Homebrew setup
# Detects and configures Homebrew for M-series vs Intel Macs

if [[ -e /opt/homebrew/bin/brew ]]; then
  eval "$(/opt/homebrew/bin/brew shellenv)"
elif [[ -e /usr/local/bin/brew ]]; then
  eval "$(/usr/local/bin/brew shellenv)"
fi

# Homebrew completions
if command -v brew &> /dev/null; then
  BREW_PREFIX=$(brew --prefix)
  
  # Bash completions from Homebrew
  if [[ -r "$BREW_PREFIX/etc/profile.d/bash_completion.sh" ]]; then
    source "$BREW_PREFIX/etc/profile.d/bash_completion.sh"
  fi
  
  # Additional completion paths
  if [[ -d "$BREW_PREFIX/etc/bash_completion.d" ]]; then
    for comp in "$BREW_PREFIX"/etc/bash_completion.d/*; do
      [[ -r "$comp" ]] && source "$comp"
    done
  fi
fi