#!/usr/bin/env bash
# Completions and Integrations


# FZF completions
if [[ -f /opt/homebrew/opt/fzf/shell/completion.bash ]]; then
  source /opt/homebrew/opt/fzf/shell/completion.bash
elif [[ -f /usr/local/opt/fzf/shell/completion.bash ]]; then
  source /usr/local/opt/fzf/shell/completion.bash
fi