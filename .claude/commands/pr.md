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

Trigger the @pr-creator agent to handle the complete PR creation workflow including branch management, commit organization, PR generation, and Linear integration.

When invoking the pr-creator agent using the Task tool:

```
If "$ARGUMENTS" is not empty:
  - Parse for Linear ticket IDs (PROJ-123 format)
  - Use remaining text as PR title override
  - Pass both to the agent for processing

If "$ARGUMENTS" is empty:
  - Agent will analyze commits to determine PR title
  - Agent will search for Linear context in commit messages
```

The pr-creator agent will autonomously:

1. **Environment Analysis**: Gather full repository context
2. **Branch Validation**: Ensure proper branch setup (not on main/master)
3. **Commit Strategy**: Organize commits based on branch type
4. **PR Analysis**: Determine main change and impact level
5. **PR Creation**: Generate comprehensive PR with what/why/how structure
6. **Linear Integration**: Link and update related tickets
7. **Continuous Updates**: Monitor PR lifecycle and update as needed
8. **Post-Merge Cleanup**: Handle branch deletion and ticket closure

### Expected Output

The agent will provide:

- **PR URL**: Direct link to created pull request
- **Branch Info**: Current branch and commit summary
- **Linear Status**: Linked tickets and their updated states
- **Next Steps**: Actions needed for PR completion
- **Review Assignment**: Suggested or assigned reviewers

## Lifecycle Management

The pr-creator agent will continue to:

### On New Commits

- Update PR title if primary change shifts
- Regenerate description with new changes
- Update testing checklist

### On Review Comments

- Track requested changes
- Add "Addresses feedback" section
- Link fixing commits

### On CI Status Changes

- Update testing status
- Document CI fixes
- Suggest resolution steps

### On Merge

- Update Linear to "Done"
- Clean up branches
- Document follow-up work

## Output Handling

When the pr-creator agent returns its results:

1. **Display the formatted PR report** exactly as provided
2. **Show the PR URL** prominently for user access
3. **List any warnings** about large PRs or missing tests
4. **Provide next steps** for the review process

## Error Recovery

The agent handles common issues:

- **Rebase conflicts**: Guides through resolution
- **Large PRs**: Suggests splitting strategies
- **CI failures**: Analyzes and suggests fixes
- **Missing reviewers**: Auto-assigns based on CODEOWNERS

Remember: The pr-creator agent manages the entire PR lifecycle, not just creation. It will continue updating the PR until it's merged.
