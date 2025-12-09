# Aliases

# File operations with modern tools
alias ls='eza'
alias ll='eza -alh'
alias la='eza -a'
alias lt='eza --tree'
# Note: cat=bat and lzg/lzd are defined in 86-additional-tools.fish with guards

# Git shortcuts (in addition to abbreviations)
alias g='git'

# Tool shortcuts
alias ff='fzf --preview "bat --color=always {}"'
# Note: cd/cdi are defined as functions in 60-modern-tools.fish

# Common operations
alias ..='cd ..'
alias ...='cd ../..'
alias ....='cd ../../..'
alias mkdir='mkdir -p'

# System
alias reload='source ~/.config/fish/config.fish'
alias fishconfig='$EDITOR ~/.config/fish/config.fish'

# Kubernetes
alias kx='kubectx'

# Docker
alias dps='docker ps'
alias dpsa='docker ps -a'
alias dimg='docker images'
alias drm='docker rm'
alias drmi='docker rmi'

# Network
alias ip='curl -s ifconfig.me'
alias localip='ipconfig getifaddr en0'

# macOS specific
alias brewup='brew update && brew upgrade && brew cleanup'
alias flushdns='sudo dscacheutil -flushcache'
alias showfiles='defaults write com.apple.finder AppleShowAllFiles YES; killall Finder'
alias hidefiles='defaults write com.apple.finder AppleShowAllFiles NO; killall Finder'