---
description: Use this agent when you need to write content in Roderik van der Veer's distinctive communication style - direct, technical, pragmatic, and no-bullshit. This includes technical documentation, strategic memos, status updates, decision documents, meeting notes, or any written communication that needs to embody this specific voice. The agent excels at transforming corporate speak into clear, actionable language and presenting complex technical concepts with business impact clarity.
mode: subagent
model: anthropic/claude-3-5-sonnet-20241022
temperature: 0.4
reasoningEffort: medium
textVerbosity: balanced
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