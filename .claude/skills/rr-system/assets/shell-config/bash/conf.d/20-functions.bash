#!/usr/bin/env bash
# Custom Functions

# Create directory and cd into it
mkcd() {
  if [[ -z "$1" ]]; then
    echo "Usage: mkcd <directory>"
    return 1
  fi
  mkdir -p "$1" && cd "$1" || return 1
}

# Extract archives (supports modern formats)
extract() {
  if [[ -z "$1" ]]; then
    echo "Usage: extract <archive>"
    return 1
  fi

  if [[ ! -f "$1" ]]; then
    echo "'$1' is not a valid file"
    return 1
  fi

  case "$1" in
    *.tar.bz2)   tar xjf "$1"     ;;
    *.tar.gz)    tar xzf "$1"     ;;
    *.tar.xz)    tar xJf "$1"     ;;
    *.tar.zst)   tar --zstd -xf "$1" ;;
    *.bz2)       bunzip2 "$1"     ;;
    *.rar)       unrar x "$1"     ;;
    *.gz)        gunzip "$1"      ;;
    *.tar)       tar xf "$1"      ;;
    *.tbz2)      tar xjf "$1"     ;;
    *.tgz)       tar xzf "$1"     ;;
    *.zip)       unzip "$1"       ;;
    *.Z)         uncompress "$1"  ;;
    *.7z)        7z x "$1"        ;;
    *.xz)        unxz "$1"        ;;
    *.zst)       unzstd "$1"      ;;
    *)           echo "'$1' cannot be extracted via extract()" ; return 1 ;;
  esac
}

# Search in history
hist() {
  if [[ -z "$1" ]]; then
    echo "Usage: hist <pattern>"
    return 1
  fi
  history | grep "$1"
}

# Port usage
port() {
  if [[ -z "$1" ]]; then
    echo "Usage: port <port_number>"
    return 1
  fi
  lsof -i :"$1"
}

# Kill process on port
killport() {
  if [[ -z "$1" ]]; then
    echo "Usage: killport <port_number>"
    return 1
  fi

  local pids
  pids=$(lsof -ti :"$1" 2>/dev/null)
  if [[ -z "$pids" ]]; then
    echo "No process found on port $1"
    return 1
  fi
  echo "$pids" | xargs kill -9
  echo "Killed processes on port $1"
}
