# Additional Path Configurations

# Note: Bun and Foundry are installed via Homebrew
# Their paths are automatically handled by brew shellenv

# pnpm
if [[ -d "$HOME/Library/pnpm" ]]; then
  export PNPM_HOME="$HOME/Library/pnpm"
  export PATH="$PNPM_HOME:$PATH"
fi

# Kubernetes krew
if [[ -d "$HOME/.krew/bin" ]]; then
  export PATH="$HOME/.krew/bin:$PATH"
fi

# User local bin
if [[ -d "$HOME/.local/bin" ]]; then
  export PATH="$HOME/.local/bin:$PATH"
fi