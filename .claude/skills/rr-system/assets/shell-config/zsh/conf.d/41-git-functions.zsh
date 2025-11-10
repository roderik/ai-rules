# Git Functions

# Clean Docker containers, images, and volumes
dockerclean() {
  # Remove stopped containers
  local containers=$(docker ps -a -q)
  if [[ -n "$containers" ]]; then
    docker rm $containers
  fi
  
  # Remove unused images
  local images=$(docker images -q)
  if [[ -n "$images" ]]; then
    docker rmi $images
  fi
  
  # Remove dangling volumes
  local volumes=$(docker volume ls -f dangling=true -q)
  if [[ -n "$volumes" ]]; then
    docker volume rm $volumes
  fi
}

# Remove local branches that have been merged
gclean() {
  git branch --merged | grep -v "\*" | grep -v main | grep -v master | xargs -n 1 git branch -d
}

# Delete all branches that have been merged into main/master
gbda() {
  git branch --no-color --merged | command grep -vE "^([+*]|\s*(main|master|develop|dev)\s*$)" | command xargs git branch -d 2>/dev/null
}

# Fuzzy find and checkout git branch
gfg() {
  if ! command -v fzf >/dev/null 2>&1; then
    echo "fzf is required for this function"
    return 1
  fi
  
  local branch=$(git branch -a | grep -v HEAD | sed 's/^[* ]*//' | fzf --height 20% --reverse --info=inline)
  if [[ -n "$branch" ]]; then
    git checkout $(echo "$branch" | sed "s#remotes/[^/]*/##")
  fi
}

# Pretty git log with graph
glog() {
  git log --graph --pretty=format:'%Cred%h%Creset -%C(yellow)%d%Creset %s %Cgreen(%cr) %C(bold blue)<%an>%Creset' --abbrev-commit
}