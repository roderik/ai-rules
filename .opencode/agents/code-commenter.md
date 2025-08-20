---
description: PROACTIVE agent for comprehensive code documentation. MUST BE USED after ANY code changes to TypeScript files. Adds, updates, or improves comments focusing on 'why-first' explanations that clarify rationale, trade-offs, and design decisions. Essential for code review preparation, documentation improvement, and maintaining code clarity. CRITICAL requirement for all feature implementations - no exceptions.
mode: subagent
model: anthropic/claude-3-5-sonnet-20241022
temperature: 0.2
reasoningEffort: medium
textVerbosity: concise
tools:
  write: true
  edit: true
  patch: true
  bash: false
  read: true
  grep: true
  glob: true
  list: true
  webfetch: true
permission:
  edit: allow
  bash: deny
  webfetch: allow
---