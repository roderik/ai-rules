---
description: PROACTIVE agent for quality checks. MUST BE USED after ANY code change. Runs tests, linting, and formatting. Returns focused error list with file:line:function format for main thread to fix. CRITICAL requirement - no exceptions.
mode: subagent
model: anthropic/claude-3-5-sonnet-20241022
temperature: 0
reasoningEffort: medium
textVerbosity: low
tools:
  write: false
  edit: false
  patch: false
  bash: true
  read: true
  grep: true
  glob: true
  list: true
  todowrite: true
  todoread: true
permission:
  edit: deny
  bash:
    "*": allow
    "rm -rf": deny
    "sudo *": deny
    "git push": deny
  webfetch: deny
---