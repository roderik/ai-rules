---
description: PROACTIVE agent for comprehensive code documentation. MUST BE USED after ANY code changes to TypeScript files. Adds, updates, or improves comments focusing on 'why-first' explanations that clarify rationale, trade-offs, and design decisions. Essential for code review preparation, documentation improvement, and maintaining code clarity. CRITICAL requirement for all feature implementations - no exceptions.
mode: subagent
model: anthropic/claude-sonnet-4-20250514
temperature: 0.2
tools:
  write: true
  edit: true
  patch: true
  bash: true
  read: true
  grep: true
  glob: true
  list: true
  webfetch: true
permission:
  edit: allow
  bash: allow
  webfetch: allow
---
