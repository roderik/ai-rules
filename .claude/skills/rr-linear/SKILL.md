---
name: rr-linear
description: Linear issue tracking integration with on-demand MCP server loading. Use when working with Linear issues, projects, or workflows. Provides instructions to enable Linear MCP per-project and common issue CRUD operations. Example triggers: "Create Linear issue", "List my issues", "Update issue status", "Work on Linear ticket", "Enable Linear integration"
---

# Linear Skill

On-demand Linear issue tracking integration. This skill provides instructions to enable the Linear MCP server per-project, reducing global context usage while maintaining full Linear functionality when needed.

## When to Use This Skill

Use this skill for:

- Creating, viewing, updating Linear issues
- Managing Linear projects and cycles
- Working with issue labels and statuses
- Any Linear workflow integration

## Enabling Linear MCP (On-Demand)

The Linear MCP server provides full API access but consumes ~23 tools worth of context. Enable it per-project when needed.

### Option 1: Project .mcp.json (Recommended)

Create `.mcp.json` in project root:

```json
{
  "mcpServers": {
    "linear": {
      "type": "sse",
      "url": "https://mcp.linear.app/sse"
    }
  }
}
```

Then restart Claude Code or run `/mcp` to reload servers.

### Option 2: Temporary Global Enable

Add to `~/.claude/settings.json` under `mcpServers`:

```json
"linear": {
  "type": "sse",
  "url": "https://mcp.linear.app/sse"
}
```

Remember to remove after use to reclaim context.

## Common Workflows

Once Linear MCP is enabled, use these patterns:

### Issue CRUD

```bash
# List my issues
mcp__linear__list_issues assignee="me" state="In Progress"

# Get issue details
mcp__linear__get_issue id="ABC-123"

# Create issue
mcp__linear__create_issue team="Engineering" title="Fix auth bug" description="Details..."

# Update issue
mcp__linear__update_issue id="ABC-123" state="Done"
```

### Quick Reference

| Operation    | Tool             | Key Params                      |
| ------------ | ---------------- | ------------------------------- |
| List issues  | `list_issues`    | assignee, state, project, label |
| Get issue    | `get_issue`      | id                              |
| Create issue | `create_issue`   | team, title, description        |
| Update issue | `update_issue`   | id, state, assignee             |
| Add comment  | `create_comment` | issueId, body                   |
| List teams   | `list_teams`     | -                               |

### Issue States

Common state names (varies by team):

- `Backlog` - Not started
- `Todo` - Ready to work
- `In Progress` - Being worked on
- `In Review` - Awaiting review
- `Done` - Completed
- `Canceled` - Won't do

### Filtering Issues

```bash
# By assignee
list_issues assignee="me"
list_issues assignee="john@example.com"

# By state
list_issues state="In Progress"

# By project
list_issues project="Q1 Release"

# By label
list_issues label="bug"

# Combined
list_issues assignee="me" state="In Progress" project="Q1 Release"
```

## Workflow Integration

### Starting Work on an Issue

1. Enable Linear MCP (see above)
2. Find or create your issue
3. Update status to "In Progress"
4. Create branch with issue ID: `git checkout -b ABC-123-feature-name`
5. Work on changes
6. Reference issue in PR: "Fixes ABC-123"

### Issue-Driven Development

```bash
# 1. Get assigned issues
list_issues assignee="me" state="Todo"

# 2. Pick issue, get details
get_issue id="ABC-123"

# 3. Start work
update_issue id="ABC-123" state="In Progress"

# 4. After PR merged
update_issue id="ABC-123" state="Done"
```

## When NOT to Enable Linear MCP

Skip enabling Linear MCP when:

- Just coding without issue tracking
- Working on personal/hobby projects
- Context space is critical
- Only need to reference issue IDs (use git branch names instead)

## Disabling Linear MCP

### Remove from .mcp.json

Delete the `linear` entry or the entire `.mcp.json` file, then restart Claude Code.

### Remove from global settings

Edit `~/.claude/settings.json` and remove the `linear` entry from `mcpServers`.
