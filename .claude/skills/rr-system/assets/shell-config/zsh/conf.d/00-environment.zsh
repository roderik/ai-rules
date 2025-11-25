# Environment Variables

# Editor settings
export EDITOR="nvim"
export VISUAL="nvim"

# Node.js settings
export NODE_NO_WARNINGS=1

# Claude Code settings
export FORCE_AUTO_BACKGROUND_TASKS=1
export ENABLE_BACKGROUND_TASKS=1

# Homebrew settings
export HOMEBREW_NO_ENV_HINTS=1

# History settings
export HISTSIZE=10000
export SAVEHIST=10000
export HISTFILE=~/.zsh_history
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_FIND_NO_DUPS
setopt HIST_SAVE_NO_DUPS
setopt SHARE_HISTORY
setopt APPEND_HISTORY

# Path additions
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/bin:$PATH"

# Note: Homebrew setup is in 00-homebrew.zsh with static paths
# Note: FZF settings are in 20-fzf.zsh