#!/usr/bin/env bash
# SSH Agent configuration
# Auto-start ssh-agent and persist socket across sessions

if [[ $- == *i* ]]; then
  export SSH_AUTH_SOCK="$HOME/.ssh/agent.sock"

  # Start agent if socket doesn't exist or agent isn't responding
  if ! ssh-add -l &>/dev/null; then
    rm -f "$SSH_AUTH_SOCK"
    ssh-agent -a "$SSH_AUTH_SOCK" &>/dev/null
  fi
fi
