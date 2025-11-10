# Key Bindings

# Use emacs key bindings
bindkey -e

# History search
bindkey '^[[A' history-search-backward
bindkey '^[[B' history-search-forward
bindkey '^P' history-search-backward
bindkey '^N' history-search-forward

# Word navigation
bindkey '^[[1;5C' forward-word   # Ctrl+Right
bindkey '^[[1;5D' backward-word  # Ctrl+Left
bindkey '^[f' forward-word       # Alt+Right
bindkey '^[b' backward-word      # Alt+Left

# Line navigation
bindkey '^A' beginning-of-line
bindkey '^E' end-of-line

# Deletion
bindkey '^?' backward-delete-char
bindkey '^H' backward-delete-char
bindkey '^W' backward-kill-word
bindkey '^U' backward-kill-line
bindkey '^K' kill-line


# Edit command line in editor
autoload -Uz edit-command-line
zle -N edit-command-line
bindkey '^X^E' edit-command-line