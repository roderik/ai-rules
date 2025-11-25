# Homebrew setup
# Static configuration for M-series vs Intel Macs (no subprocess calls)

if [[ -e /opt/homebrew/bin/brew ]]; then
  # Apple Silicon Mac - static paths
  export HOMEBREW_PREFIX="/opt/homebrew"
  export HOMEBREW_CELLAR="/opt/homebrew/Cellar"
  export HOMEBREW_REPOSITORY="/opt/homebrew"
  export PATH="/opt/homebrew/bin:/opt/homebrew/sbin${PATH+:$PATH}"
  export MANPATH="/opt/homebrew/share/man${MANPATH+:$MANPATH}:"
  export INFOPATH="/opt/homebrew/share/info:${INFOPATH:-}"
  # Add completions to fpath
  fpath=(/opt/homebrew/share/zsh/site-functions $fpath)
elif [[ -e /usr/local/bin/brew ]]; then
  # Intel Mac - static paths
  export HOMEBREW_PREFIX="/usr/local"
  export HOMEBREW_CELLAR="/usr/local/Cellar"
  export HOMEBREW_REPOSITORY="/usr/local/Homebrew"
  export PATH="/usr/local/bin:/usr/local/sbin${PATH+:$PATH}"
  export MANPATH="/usr/local/share/man${MANPATH+:$MANPATH}:"
  export INFOPATH="/usr/local/share/info:${INFOPATH:-}"
  # Add completions to fpath
  fpath=(/usr/local/share/zsh/site-functions $fpath)
fi