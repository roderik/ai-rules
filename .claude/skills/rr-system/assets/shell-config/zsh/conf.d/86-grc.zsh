#!/usr/bin/env zsh
# grc (Generic Colourizer) integration
# Colorizes output of common CLI tools (ping, df, dig, netstat, etc.)
# Install: brew install grc
# https://github.com/garabik/grc

# Skip if grc not installed
(( $+commands[grc] )) || return 0

# Skip if not interactive terminal
[[ -o interactive ]] || return 0
[[ -n "$TERM" && "$TERM" != "dumb" ]] || return 0

# Detect Homebrew prefix (Apple Silicon vs Intel)
local _grc_prefix
if [[ -d "/opt/homebrew" ]]; then
  _grc_prefix="/opt/homebrew"
elif [[ -d "/usr/local/Homebrew" ]]; then
  _grc_prefix="/usr/local"
else
  return 0
fi

# Source grc shell integration if it exists
local _grc_zsh="${_grc_prefix}/etc/grc.zsh"
if [[ -f "$_grc_zsh" ]]; then
  source "$_grc_zsh"

  # Remove functions that conflict with our preferred tools
  # grc.zsh creates wrapper functions, not aliases
  unfunction cat 2>/dev/null   # Prefer bat
  unfunction ps 2>/dev/null    # Prefer procs
  unfunction ls 2>/dev/null    # Prefer eza
  unfunction diff 2>/dev/null  # Prefer delta
fi
