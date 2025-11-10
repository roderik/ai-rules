#!/usr/bin/env zsh
# Additional tool configurations

# Lazygit - Terminal UI for git
if command -v lazygit &> /dev/null; then
  alias lg='lazygit'
  alias lzg='lazygit'
fi

# Lazydocker - Terminal UI for docker
if command -v lazydocker &> /dev/null; then
  alias lzd='lazydocker'
  alias ld='lazydocker'
fi

# Git Delta - Better git diff
if command -v delta &> /dev/null; then
  export GIT_PAGER='delta'
  export DELTA_PAGER='less -R'
fi

# Broot - Better tree
if command -v broot &> /dev/null; then
  # Source broot launcher if it exists
  if [ -f "$HOME/.config/broot/launcher/bash/br" ]; then
    source "$HOME/.config/broot/launcher/bash/br"
  fi
fi

# Procs - Better ps
if command -v procs &> /dev/null; then
  alias ps='procs'
  alias pst='procs --tree'
  alias psw='procs --watch'
fi

# Hexyl - Hex viewer
if command -v hexyl &> /dev/null; then
  alias hex='hexyl'
  alias hexdump='hexyl'
fi

# Chafa - Terminal graphics viewer
if command -v chafa &> /dev/null; then
  alias img='chafa'
  alias image='chafa'
fi

# Ripgrep aliases (better grep)
if command -v rg &> /dev/null; then
  alias rgi='rg -i'  # case insensitive
  alias rgl='rg -l'  # files with matches
  alias rgv='rg -v'  # invert match
fi

# fd aliases (better find)
if command -v fd &> /dev/null; then
  alias fdi='fd -i'  # case insensitive
  alias fdh='fd -H'  # include hidden
fi

# Bat aliases (better cat)
if command -v bat &> /dev/null; then
  alias cat='bat --style=plain'
  alias catp='bat'  # with style
  export BAT_THEME="base16-256"
  export MANPAGER="sh -c 'col -bx | bat -l man -p'"
fi

# Tilt - Local Kubernetes development
if command -v tilt &> /dev/null; then
  alias tu='tilt up'
  alias td='tilt down'
fi

# Zellij - Modern terminal multiplexer
if command -v zellij &> /dev/null; then
  alias zj='zellij'
  alias zja='zellij attach'
  alias zjs='zellij session'
  alias zjl='zellij list-sessions'
fi

# ast-grep - Structural search/replace
if command -v ast-grep &> /dev/null; then
  alias ag='sst-grep'
  alias ags='sst-grep search'
  alias agr='sst-grep replace'
fi