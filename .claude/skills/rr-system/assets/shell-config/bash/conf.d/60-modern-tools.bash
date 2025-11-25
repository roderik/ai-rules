#!/usr/bin/env bash
# Modern Shell Enhancements
# Setup for modern CLI tools with caching for performance

# direnv - Per-project environment variables (cached)
if command -v direnv &> /dev/null; then
  _direnv_hook_cache="$HOME/.cache/bash/hooks/direnv.bash"

  if [[ ! -f "$_direnv_hook_cache" ]] || [[ "$(command -v direnv)" -nt "$_direnv_hook_cache" ]]; then
    mkdir -p "$HOME/.cache/bash/hooks"
    direnv hook bash > "$_direnv_hook_cache" 2>/dev/null
  fi

  [[ -f "$_direnv_hook_cache" ]] && source "$_direnv_hook_cache"
  unset _direnv_hook_cache
fi

# atuin - Better shell history (cached)
if command -v atuin &> /dev/null; then
  _atuin_init_cache="$HOME/.cache/bash/hooks/atuin.bash"

  if [[ ! -f "$_atuin_init_cache" ]] || [[ "$(command -v atuin)" -nt "$_atuin_init_cache" ]]; then
    mkdir -p "$HOME/.cache/bash/hooks"
    atuin init bash > "$_atuin_init_cache" 2>/dev/null
  fi

  [[ -f "$_atuin_init_cache" ]] && source "$_atuin_init_cache"
  unset _atuin_init_cache
fi

# zoxide - Better cd command
if command -v zoxide &> /dev/null; then
  _zoxide_init_cache="$HOME/.cache/bash/hooks/zoxide.bash"

  if [[ ! -f "$_zoxide_init_cache" ]] || [[ "$(command -v zoxide)" -nt "$_zoxide_init_cache" ]]; then
    mkdir -p "$HOME/.cache/bash/hooks"
    zoxide init bash > "$_zoxide_init_cache" 2>/dev/null
  fi

  [[ -f "$_zoxide_init_cache" ]] && source "$_zoxide_init_cache"
  unset _zoxide_init_cache
fi
