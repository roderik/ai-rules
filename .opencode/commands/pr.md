---
name: pr
description: Create a pull request with autonomous workflow management
argument_hint: "[pr-title or linear-ticket]"
tools:
  - Task
  - Bash
  - "mcp__linear__*"
delegate: pr-creator
---