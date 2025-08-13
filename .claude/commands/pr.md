---
description: Trigger autonomous PR creation and lifecycle management
allowed-tools: Task, Bash, mcp__linear__*
argument-hint: [pr-title or linear-ticket]
---

# Create Pull Request

## Context

- Current branch: !`git branch --show-current`
- Recent commits: !`git log origin/main..HEAD --oneline || echo "No commits ahead of main"`
- Uncommitted changes: !`git status --porcelain`
- Remote URL: !`git remote get-url origin`

## Your Task

User request: $ARGUMENTS

Trigger the @pr-creator agent to handle the complete PR creation workflow.

When invoking the pr-creator agent using the Task tool:

```
If "$ARGUMENTS" is not empty:
  - Include "User request: $ARGUMENTS" in the prompt
  - The agent will parse for Linear tickets and PR title overrides

If "$ARGUMENTS" is empty:
  - Use the standard PR creation prompt
  - The agent will analyze commits to determine the PR title
```

The agent will autonomously create and manage the PR lifecycle.

## Output Handling

When the pr-creator agent returns its results, display the output exactly as provided without modification or summarization.
