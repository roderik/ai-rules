# Zsh Completions
# Single compinit call for the entire configuration

# Initialize completion system with aggressive caching
# Only regenerate completion dump if it's older than 24 hours
autoload -Uz compinit

# Check if .zcompdump needs regeneration (older than 24h or doesn't exist)
local zcompdump="${HOME}/.zcompdump"
if [[ -f "$zcompdump" ]]; then
  local zcompdump_age=$(( $(date +%s) - $(stat -f %m "$zcompdump" 2>/dev/null || echo 0) ))
  if (( zcompdump_age > 86400 )); then
    # Older than 24 hours, regenerate
    compinit -d "$zcompdump"
  else
    # Use cached version without checking (much faster)
    compinit -C -d "$zcompdump"
  fi
else
  # No cache, generate it
  compinit -d "$zcompdump"
fi

# Completion styling
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Za-z}'  # Case insensitive
zstyle ':completion:*' list-colors "${(s.:.)LS_COLORS}"
zstyle ':completion:*' menu select
zstyle ':completion:*' group-name ''
zstyle ':completion:*' verbose yes

# Descriptions format
zstyle ':completion:*:descriptions' format '%F{yellow}-- %d --%f'
zstyle ':completion:*:messages' format '%F{purple}-- %d --%f'
zstyle ':completion:*:warnings' format '%F{red}-- no matches found --%f'
zstyle ':completion:*:corrections' format '%F{green}-- %d (errors: %e) --%f'

# Completion caching
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path ~/.zsh/cache

# Specific completions
zstyle ':completion:*:*:kill:*:processes' list-colors '=(#b) #([0-9]#)*=0=01;31'
zstyle ':completion:*:kill:*' command 'ps -u $USER -o pid,%cpu,tty,cputime,cmd'

# Note: fzf completions are loaded in 20-fzf.zsh