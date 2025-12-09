#!/usr/bin/env bash
# grc (Generic Colourizer) integration
# Colorizes output of common CLI tools (ping, df, dig, netstat, etc.)
# Install: brew install grc
# https://github.com/garabik/grc

# Skip if grc not installed
command -v grc &> /dev/null || return 0

# Skip if not interactive terminal
[[ $- != *i* ]] && return 0
[[ -z "$TERM" || "$TERM" = "dumb" ]] && return 0

# Detect Homebrew prefix (Apple Silicon vs Intel)
if [[ -d "/opt/homebrew" ]]; then
  _grc_prefix="/opt/homebrew"
elif [[ -d "/usr/local/Homebrew" ]]; then
  _grc_prefix="/usr/local"
else
  return 0
fi

# Source grc shell integration if it exists
_grc_sh="${_grc_prefix}/etc/grc.sh"
if [[ -f "$_grc_sh" ]]; then
  export GRC_ALIASES=true
  source "$_grc_sh"

  # Remove aliases that conflict with our preferred tools
  unalias cat 2>/dev/null   # Prefer bat
  unalias ps 2>/dev/null    # Prefer procs
  unalias ls 2>/dev/null    # Prefer eza
  unalias diff 2>/dev/null  # Prefer delta
fi

unset _grc_prefix _grc_sh
