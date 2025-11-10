#!/usr/bin/env bash
# 1Password CLI Configuration
# Enable CLI completion for 1Password

if command -v op &> /dev/null; then
  eval "$(op completion bash)"
fi