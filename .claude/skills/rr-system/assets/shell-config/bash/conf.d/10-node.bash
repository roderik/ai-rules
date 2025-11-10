#!/usr/bin/env bash
# Node.js Configuration
# Fast Node Manager setup

if command -v fnm &> /dev/null; then
  eval "$(fnm env --use-on-cd)"
fi