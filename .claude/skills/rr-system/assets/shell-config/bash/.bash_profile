#!/bin/bash
# Bash Profile - sourced for login shells
# Sets essential PATH first, then sources .bashrc for full config

# Skip if already set by this file (prevent duplicate paths on nested shells)
if [[ -z "$__BASH_PROFILE_SOURCED" ]]; then
  export __BASH_PROFILE_SOURCED=1

  # Homebrew - must be first to enable other tools
  if [[ -e /opt/homebrew/bin/brew ]]; then
    export HOMEBREW_PREFIX="/opt/homebrew"
    export HOMEBREW_CELLAR="/opt/homebrew/Cellar"
    export HOMEBREW_REPOSITORY="/opt/homebrew"
    export PATH="/opt/homebrew/bin:/opt/homebrew/sbin${PATH+:$PATH}"
    export MANPATH="/opt/homebrew/share/man${MANPATH+:$MANPATH}:"
    export INFOPATH="/opt/homebrew/share/info:${INFOPATH:-}"
  elif [[ -e /usr/local/bin/brew ]]; then
    export HOMEBREW_PREFIX="/usr/local"
    export HOMEBREW_CELLAR="/usr/local/Cellar"
    export HOMEBREW_REPOSITORY="/usr/local/Homebrew"
    export PATH="/usr/local/bin:/usr/local/sbin${PATH+:$PATH}"
    export MANPATH="/usr/local/share/man${MANPATH+:$MANPATH}:"
    export INFOPATH="/usr/local/share/info:${INFOPATH:-}"
  fi

  # Core user paths
  [[ -d "$HOME/.local/bin" ]] && export PATH="$HOME/.local/bin:$PATH"
  [[ -d "$HOME/bin" ]] && export PATH="$HOME/bin:$PATH"

  # Development tools
  [[ -d "$HOME/.bun/bin" ]] && export PATH="$HOME/.bun/bin:$PATH"
  [[ -d "$HOME/.foundry/bin" ]] && export PATH="$HOME/.foundry/bin:$PATH"
  [[ -d "$HOME/Library/pnpm" ]] && export PATH="$HOME/Library/pnpm:$PATH"
  [[ -d "$HOME/.krew/bin" ]] && export PATH="$HOME/.krew/bin:$PATH"

  # Google Cloud SDK
  [[ -d "/opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/bin" ]] && \
    export PATH="/opt/homebrew/Caskroom/google-cloud-sdk/latest/google-cloud-sdk/bin:$PATH"
fi

# Source .bashrc for full interactive config
[[ -f ~/.bashrc ]] && source ~/.bashrc
