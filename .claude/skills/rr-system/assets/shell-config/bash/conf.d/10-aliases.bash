#!/usr/bin/env bash
# Command Aliases
# Modern replacements and shortcuts for common commands

# ls/eza aliases
alias ls='eza -lh --group-directories-first'
alias l='eza --git-ignore --group-directories-first'
alias ll='eza --all --header --long --group-directories-first'
alias llm='eza --all --header --long --sort=modified --group-directories-first'
alias la='eza -lbhHigUmuSa'
alias lx='eza -lbhHigUmuSa@'
alias lt='eza --tree'
alias tree='eza --tree'
alias exa='eza'

# Editor shortcuts
alias n='nvim'
alias vim='nvim'

# Git shortcuts
alias gcmp='git checkout main && git pull'

# Kubernetes
alias kx='kubectx'

# FZF preview
alias ff="fzf --preview 'bat --style=numbers --color=always '"