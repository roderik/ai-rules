# Custom Functions

# Create directory and cd into it
mkcd() {
  if [[ -z "$1" ]]; then
    echo "Usage: mkcd <directory>"
    return 1
  fi
  mkdir -p "$1" && cd "$1"
}

# Extract archives
extract() {
  if [[ -z "$1" ]]; then
    echo "Usage: extract <archive_file>"
    echo "Supported: tar.bz2, tar.gz, tar.xz, tar.zst, bz2, rar, gz, tar, tbz2, tgz, zip, Z, 7z, xz, zst"
    return 1
  fi

  if [[ ! -f "$1" ]]; then
    echo "Error: '$1' is not a valid file"
    return 1
  fi

  case "$1" in
    *.tar.bz2)   tar xjf "$1"     ;;
    *.tar.gz)    tar xzf "$1"     ;;
    *.tar.xz)    tar xJf "$1"     ;;
    *.tar.zst)   tar --zstd -xf "$1" ;;
    *.bz2)       bunzip2 "$1"     ;;
    *.rar)
      if ! command -v unrar &> /dev/null; then
        echo "Error: 'unrar' required. Install: brew install unrar"
        return 1
      fi
      unrar e "$1"
      ;;
    *.gz)        gunzip "$1"      ;;
    *.tar)       tar xf "$1"      ;;
    *.tbz2)      tar xjf "$1"     ;;
    *.tgz)       tar xzf "$1"     ;;
    *.zip)       unzip "$1"       ;;
    *.Z)         uncompress "$1"  ;;
    *.7z)
      if ! command -v 7z &> /dev/null; then
        echo "Error: '7z' required. Install: brew install p7zip"
        return 1
      fi
      7z x "$1"
      ;;
    *.xz)        xz -d "$1"       ;;
    *.zst)       zstd -d "$1"     ;;
    *)           echo "Error: '$1' - unknown archive format"; return 1 ;;
  esac
}

# Search in history
hist() {
  if [[ -z "$1" ]]; then
    echo "Usage: hist <search_term>"
    return 1
  fi
  fc -l 1 | grep "$1"
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
    return 0
  fi

  echo "$pids" | xargs kill -9
  echo "Killed processes on port $1"
}