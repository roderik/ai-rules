# SSH Agent configuration
# Auto-start ssh-agent and persist socket across sessions

if [[ -o interactive ]]; then
  export SSH_AUTH_SOCK="${HOME}/.ssh/agent.sock"

  # Start agent only if socket doesn't exist (faster than ssh-add -l check)
  if [[ ! -S "$SSH_AUTH_SOCK" ]]; then
    rm -f "$SSH_AUTH_SOCK"
    ssh-agent -a "$SSH_AUTH_SOCK" &>/dev/null
  fi
fi
