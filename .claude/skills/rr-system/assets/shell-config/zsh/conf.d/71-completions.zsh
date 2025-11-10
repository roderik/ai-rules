# Additional Tool Completions

# 1Password CLI completion
if command -v op >/dev/null 2>&1; then
  eval "$(op completion zsh)"
  compdef _op op
fi

# Homebrew completions
if command -v brew >/dev/null 2>&1; then
  FPATH="$(brew --prefix)/share/zsh/site-functions:${FPATH}"
  
  # Also add vendor completions if available
  if [[ -d "$(brew --prefix)/share/zsh/vendor-completions" ]]; then
    FPATH="$(brew --prefix)/share/zsh/vendor-completions:${FPATH}"
  fi
  
  autoload -Uz compinit
  compinit
fi