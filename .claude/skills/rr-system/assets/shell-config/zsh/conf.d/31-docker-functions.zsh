#!/usr/bin/env zsh
# Docker Functions
# Docker cleanup and utility functions

dockerclean() {
  # Clean up Docker containers, images, and volumes
  
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