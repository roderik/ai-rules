---
description: PR creation and lifecycle management agent - creates pull requests when explicitly requested by user
mode: primary
model: anthropic/claude-sonnet-4-20250514
temperature: 0.1
tools:
  write: false
  edit: false
  patch: false
  bash: true
  read: true
  grep: true
  glob: true
  list: true
  webfetch: true
permission:
  edit: deny
  bash:
    "git *": allow
    "gh *": allow
    "*": ask
  webfetch: allow
---
