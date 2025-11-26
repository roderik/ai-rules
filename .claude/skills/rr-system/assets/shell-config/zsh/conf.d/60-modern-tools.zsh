# Modern Shell Enhancements
# Setup for modern CLI tools like zoxide, atuin
# All tools use caching to speed up shell startup
# Note: direnv is handled by Homebrew's site-functions

local cache_dir="${HOME}/.cache/zsh/hooks"

# zoxide - Smarter cd command (cached)
if command -v zoxide &> /dev/null; then
  local cache_file="${cache_dir}/zoxide.zsh"
  local tool_path="$(command -v zoxide)"

  if [[ ! -f "$cache_file" ]] || [[ "$tool_path" -nt "$cache_file" ]]; then
    mkdir -p "$cache_dir"
    zoxide init zsh > "$cache_file" 2>/dev/null
  fi

  [[ -f "$cache_file" ]] && source "$cache_file"

  # Use z directly (zoxide provides 'z' function)
  # For interactive selection, use 'zi'
  alias cdi='zi'
fi

# atuin - Better shell history (cached)
if command -v atuin &> /dev/null; then
  local cache_file="${cache_dir}/atuin.zsh"
  local tool_path="$(command -v atuin)"

  if [[ ! -f "$cache_file" ]] || [[ "$tool_path" -nt "$cache_file" ]]; then
    mkdir -p "$cache_dir"
    atuin init zsh > "$cache_file" 2>/dev/null
  fi

  [[ -f "$cache_file" ]] && source "$cache_file"
fi