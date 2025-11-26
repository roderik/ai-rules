# Modern Shell Enhancements
# Setup for modern CLI tools with caching for performance
# Note: direnv is handled by Homebrew's bash-completion

# zoxide - Better cd command (cached)
if command -v zoxide &> /dev/null; then
  _zoxide_cache="$HOME/.cache/bash/hooks/zoxide.bash"

  if [[ ! -f "$_zoxide_cache" ]] || [[ "$(command -v zoxide)" -nt "$_zoxide_cache" ]]; then
    mkdir -p "$HOME/.cache/bash/hooks"
    zoxide init bash > "$_zoxide_cache" 2>/dev/null
  fi

  [[ -f "$_zoxide_cache" ]] && source "$_zoxide_cache"
  unset _zoxide_cache
fi

# atuin - Better shell history (cached)
if command -v atuin &> /dev/null; then
  _atuin_cache="$HOME/.cache/bash/hooks/atuin.bash"

  if [[ ! -f "$_atuin_cache" ]] || [[ "$(command -v atuin)" -nt "$_atuin_cache" ]]; then
    mkdir -p "$HOME/.cache/bash/hooks"
    atuin init bash > "$_atuin_cache" 2>/dev/null
  fi

  [[ -f "$_atuin_cache" ]] && source "$_atuin_cache"
  unset _atuin_cache
fi
