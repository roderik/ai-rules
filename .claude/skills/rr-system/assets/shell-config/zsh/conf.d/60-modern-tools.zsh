# Modern Shell Enhancements
# Setup for modern CLI tools like direnv, zoxide, atuin

# direnv - Per-project environment variables (cached)
if command -v direnv &> /dev/null; then
  local cache_dir="${HOME}/.cache/zsh/hooks"
  local cache_file="${cache_dir}/direnv.zsh"
  local direnv_path="$(command -v direnv)"

  if [[ ! -f "$cache_file" ]] || [[ "$direnv_path" -nt "$cache_file" ]]; then
    mkdir -p "$cache_dir"
    direnv hook zsh > "$cache_file" 2>/dev/null
  fi

  [[ -f "$cache_file" ]] && source "$cache_file"
fi

# zoxide - Smarter cd command (cached)
if command -v zoxide &> /dev/null; then
  local cache_dir="${HOME}/.cache/zsh/hooks"
  local cache_file="${cache_dir}/zoxide.zsh"
  local zoxide_path="$(command -v zoxide)"

  if [[ ! -f "$cache_file" ]] || [[ "$zoxide_path" -nt "$cache_file" ]]; then
    mkdir -p "$cache_dir"
    zoxide init zsh > "$cache_file" 2>/dev/null
  fi

  [[ -f "$cache_file" ]] && source "$cache_file"
  
  # Use z directly (zoxide provides 'z' function)
  # For interactive selection, use 'zi'
  alias cdi='zi'
fi

# atuin - Better shell history
if command -v atuin &> /dev/null; then
  eval "$(atuin init zsh)"
fi