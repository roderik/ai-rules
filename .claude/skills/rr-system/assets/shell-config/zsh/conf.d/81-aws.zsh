#!/usr/bin/env zsh
# AWS CLI completion

# Enable AWS CLI completion if available
if command -v aws_completer &> /dev/null; then
  autoload -U +X bashcompinit && bashcompinit
  complete -C "$(command -v aws_completer)" aws
fi