# Zsh Configuration
# Modern shell setup with powerful CLI tools

# Source all configuration modules from conf.d
# Tool initializations are handled in individual conf.d files
if [[ -d ~/.config/zsh/conf.d ]]; then
  for config in ~/.config/zsh/conf.d/*.zsh(.N); do
    source "$config"
  done
fi

# Source local customizations if present
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local