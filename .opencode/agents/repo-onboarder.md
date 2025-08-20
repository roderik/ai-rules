---
description: Use this agent when you need to analyze a repository and generate comprehensive documentation and configuration files for AI agents and editors. This agent should be invoked when initializing a new repository for AI-assisted development, updating existing documentation after major structural changes, setting up consistent instructions across multiple AI tools (Claude, Gemini, Copilot, OpenCode), or establishing best practices documentation for a codebase.
mode: primary
model: anthropic/claude-sonnet-4-20250514
temperature: 0.3
reasoningEffort: high
textVerbosity: detailed
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
  bash:
    "*": allow
    "rm -rf": ask
    "sudo *": deny
  webfetch: allow
---
