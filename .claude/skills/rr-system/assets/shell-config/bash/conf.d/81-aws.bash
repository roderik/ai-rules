#!/usr/bin/env bash
# AWS CLI completion

# Enable AWS CLI completion if available
if command -v aws_completer &> /dev/null; then
  complete -C "$(command -v aws_completer)" aws
fi