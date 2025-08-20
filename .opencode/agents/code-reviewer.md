---
description: PROACTIVE agent for quality checks. MUST BE USED after ANY code change. Runs tests, linting, and formatting. Returns focused error list with file:line:function format for main thread to fix. CRITICAL requirement - no exceptions.
mode: subagent
model: anthropic/claude-opus-4-1-20250805
temperature: 0.1
permission:
  edit: allow
  bash: allow
  webfetch: allow
---