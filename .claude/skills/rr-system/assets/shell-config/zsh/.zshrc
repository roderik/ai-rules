# Zsh Configuration
# Modern shell setup with powerful CLI tools

# Source all configuration modules from conf.d
if [[ -d ~/.config/zsh/conf.d ]]; then
  for config in ~/.config/zsh/conf.d/*.zsh(.N); do
    source "$config"
  done
fi

# Initialize Starship prompt if available
if command -v starship >/dev/null 2>&1; then
  eval "$(starship init zsh)"
fi

# Initialize zoxide if available
if command -v zoxide >/dev/null 2>&1; then
  eval "$(zoxide init zsh)"
fi

# Initialize atuin if available
if command -v atuin >/dev/null 2>&1; then
  eval "$(atuin init zsh)"
fi

# Initialize direnv if available
if command -v direnv >/dev/null 2>&1; then
  eval "$(direnv hook zsh)"
fi

# Initialize fnm if available
if command -v fnm >/dev/null 2>&1; then
  eval "$(fnm env --use-on-cd)"
fi