# Zsh Environment - sourced for ALL zsh invocations (interactive, non-interactive, login)
# Use static paths to ensure PATH is set even when launched with minimal environment

# Skip if already set by this file (prevent duplicate paths)
[[ -n "$__ZSHENV_SOURCED" ]] && return
export __ZSHENV_SOURCED=1

# Homebrew - must be first to enable other tools
if [[ -e /opt/homebrew/bin/brew ]]; then
  export HOMEBREW_PREFIX="/opt/homebrew"
  export PATH="/opt/homebrew/bin:/opt/homebrew/sbin${PATH+:$PATH}"
elif [[ -e /usr/local/bin/brew ]]; then
  export HOMEBREW_PREFIX="/usr/local"
  export PATH="/usr/local/bin:/usr/local/sbin${PATH+:$PATH}"
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
