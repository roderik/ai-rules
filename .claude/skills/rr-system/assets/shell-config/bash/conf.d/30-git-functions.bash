#!/usr/bin/env bash
# Git Functions
# Custom git utilities and helper functions

gclean() {
  # Remove local branches that have been merged
  git branch --merged | grep -v "\*" | grep -v main | grep -v master | xargs -n 1 git branch -d
}

gbda() {
  # Delete all branches that have been merged into main/master
  git branch --no-color --merged | command grep -vE "^([+*]|\s*(main|master|develop|dev)\s*\$)" | command xargs git branch -d 2>/dev/null
}

gfg() {
  # Fuzzy find and checkout git branch
  if ! command -v fzf &> /dev/null; then
    echo "fzf is required for this function"
    return 1
  fi

  local branch
  branch=$(git branch -a | grep -v HEAD | sed 's/^[[:space:]]*//' | fzf --height 20% --reverse --info=inline)
  if [[ -n "$branch" ]]; then
    # Clean up branch name
    branch="${branch##* }"
    branch="${branch#remotes/*/}"
    git checkout "$branch"
  fi
}

glog() {
  # Pretty git log with graph
  git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit
}

glogf() {
  # Interactive git log with fzf
  if ! command -v fzf &> /dev/null; then
    echo "fzf is required for this function"
    return 1
  fi

  git log --oneline --decorate --color=always | \
    fzf --ansi --no-sort --reverse \
        --preview 'git show --color=always {1}' \
        --bind 'enter:execute(git show --color=always {1} | less -R)+abort'
}

gdm() {
  # Delete all local branches except main/master (force delete)
  local current_branch
  current_branch=$(git branch --show-current)
  local protected_branches=("main" "master")

  # Check if we're on a branch that will be deleted
  if [[ ! " ${protected_branches[@]} " =~ " ${current_branch} " ]]; then
    echo "Switching to main/master first..."
    if git show-ref --verify --quiet refs/heads/main; then
      git checkout main
    elif git show-ref --verify --quiet refs/heads/master; then
      git checkout master
    else
      echo "Error: Neither main nor master branch exists"
      return 1
    fi
  fi

  # Delete all branches except protected ones
  local branches_to_delete
  branches_to_delete=$(git branch | sed 's/^[* ]*//' | grep -v '^main$' | grep -v '^master$')
  if [[ -n "$branches_to_delete" ]]; then
    echo "$branches_to_delete" | while IFS= read -r branch; do
      git branch -D "$branch"
    done
    echo "Deleted branches:"
    echo "$branches_to_delete"
  else
    echo "No branches to delete"
  fi
}
