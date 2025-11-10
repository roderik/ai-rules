#!/usr/bin/env bash
# Bash Abbreviations
# Using aliases since bash doesn't have abbreviations like fish

# Git abbreviations
alias g='git'
alias ga='git add'
alias gaa='git add --all'
alias gap='git add --patch'
alias gb='git branch'
alias gba='git branch --all'
alias gbd='git branch --delete'
alias gc='git commit --verbose'
alias gca='git commit --verbose --all'
alias gcad='git commit --all --amend'
alias gcam='git commit --all --message'
alias gcm='git commit --message'
alias gco='git checkout'
alias gcob='git checkout -b'
alias gcp='git cherry-pick'
alias gd='git diff'
alias gds='git diff --staged'
alias gf='git fetch'
alias gfa='git fetch --all --prune'
alias gl='git pull'
alias glg='git log --stat'
alias glgg='git log --graph'
alias glgga='git log --graph --decorate --all'
alias glo='git log --oneline --decorate'
alias gp='git push'
alias gpf='git push --force-with-lease'
alias gpr='git pull --rebase'
alias gr='git remote'
alias gra='git remote add'
alias grb='git rebase'
alias grbi='git rebase --interactive'
alias grh='git reset HEAD'
alias grhh='git reset HEAD --hard'
alias grs='git restore'
alias grss='git restore --staged'
alias gs='git status'
alias gss='git status --short'
alias gst='git stash'
alias gsta='git stash apply'
alias gstd='git stash drop'
alias gstl='git stash list'
alias gstp='git stash pop'
alias gsts='git stash show --text'
alias gsw='git switch'
alias gswc='git switch --create'

# Directory navigation (using functions for ... patterns)
cd...() { cd ../..; }
cd....() { cd ../../..; }
cd.....() { cd ../../../..; }

# Docker abbreviations
alias d='docker'
alias dc='docker compose'
alias lzd='lazydocker'

# Other tool abbreviations
alias lzg='lazygit'