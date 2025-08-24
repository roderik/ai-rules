---
name: comments
description: Add comprehensive documentation to TypeScript code changes
arguments:
  - name: focus
    description: "Optional focus area (e.g., 'security', 'performance', 'architecture')"
    required: false
delegate: code-commenter
tools:
  - Task
  - "mcp__context7__*"
  - "mcp__octocode__*"
---