---
description: PR creation and lifecycle management agent - creates pull requests when explicitly requested by user
mode: subagent
model: anthropic/claude-3-5-sonnet-20241022
temperature: 0.1
reasoningEffort: medium
textVerbosity: concise
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