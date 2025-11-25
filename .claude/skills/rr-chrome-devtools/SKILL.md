---
name: rr-chrome-devtools
description: Chrome DevTools browser automation with on-demand MCP server loading. Use when automating browser interactions, taking screenshots, debugging web pages, monitoring network requests, or performance profiling. Example triggers: "Take screenshot", "Click button", "Fill form", "Debug webpage", "Check network requests", "Profile performance", "Enable browser automation"
---

# Chrome DevTools Skill

On-demand browser automation via Chrome DevTools Protocol. This skill provides instructions to enable the Chrome DevTools MCP server per-project, reducing global context usage (~26 tools) while maintaining full browser automation when needed.

## When to Use This Skill

Use this skill for:

- Browser automation and testing
- Taking screenshots of web pages
- Filling forms and clicking elements
- Monitoring network requests and console logs
- Performance profiling and analysis
- Debugging frontend issues

## Enabling Chrome DevTools MCP (On-Demand)

### Option 1: Project .mcp.json (Recommended)

Create `.mcp.json` in project root:

```json
{
  "mcpServers": {
    "chrome-devtools": {
      "type": "stdio",
      "command": "bun",
      "args": ["x", "-y", "chrome-devtools-mcp@latest"],
      "env": {}
    }
  }
}
```

Then restart Claude Code or run `/mcp` to reload servers.

### Option 2: Temporary Global Enable

Add to `~/.claude/settings.json` under `mcpServers`:

```json
"chrome-devtools": {
  "type": "stdio",
  "command": "bun",
  "args": ["x", "-y", "chrome-devtools-mcp@latest"],
  "env": {}
}
```

## Prerequisites

Chrome/Chromium must be running with remote debugging enabled:

```bash
# macOS
/Applications/Google\ Chrome.app/Contents/MacOS/Google\ Chrome --remote-debugging-port=9222

# Linux
google-chrome --remote-debugging-port=9222

# Or use Chrome Canary/Chromium
```

## Common Workflows

### Page Navigation

```bash
# List open pages
mcp__chrome-devtools__list_pages

# Select a page to work with
mcp__chrome-devtools__select_page pageIdx=0

# Navigate to URL
mcp__chrome-devtools__navigate_page type="url" url="https://example.com"

# Navigate back/forward/reload
mcp__chrome-devtools__navigate_page type="back"
mcp__chrome-devtools__navigate_page type="forward"
mcp__chrome-devtools__navigate_page type="reload"

# Open new page
mcp__chrome-devtools__new_page url="https://example.com"
```

### Screenshots & Snapshots

```bash
# Take screenshot of viewport
mcp__chrome-devtools__take_screenshot

# Full page screenshot
mcp__chrome-devtools__take_screenshot fullPage=true

# Screenshot specific element
mcp__chrome-devtools__take_screenshot uid="element-uid"

# Save to file
mcp__chrome-devtools__take_screenshot filePath="/path/to/screenshot.png"

# Text snapshot (a11y tree) - preferred for understanding page structure
mcp__chrome-devtools__take_snapshot
```

### Interacting with Elements

First take a snapshot to get element UIDs:

```bash
# Get page structure
mcp__chrome-devtools__take_snapshot

# Click element
mcp__chrome-devtools__click uid="button-uid"

# Double click
mcp__chrome-devtools__click uid="element-uid" dblClick=true

# Hover
mcp__chrome-devtools__hover uid="element-uid"

# Fill input
mcp__chrome-devtools__fill uid="input-uid" value="text to enter"

# Fill multiple form fields
mcp__chrome-devtools__fill_form elements=[{"uid": "email-uid", "value": "test@example.com"}, {"uid": "password-uid", "value": "secret"}]

# Press key
mcp__chrome-devtools__press_key key="Enter"
mcp__chrome-devtools__press_key key="Control+A"
```

### Network Monitoring

```bash
# List all network requests
mcp__chrome-devtools__list_network_requests

# Filter by type
mcp__chrome-devtools__list_network_requests resourceTypes=["fetch", "xhr"]

# Get request details
mcp__chrome-devtools__get_network_request reqid=123
```

### Console Monitoring

```bash
# List console messages
mcp__chrome-devtools__list_console_messages

# Filter by type
mcp__chrome-devtools__list_console_messages types=["error", "warn"]

# Get specific message
mcp__chrome-devtools__get_console_message msgid=123
```

### Performance Profiling

```bash
# Start trace with page reload
mcp__chrome-devtools__performance_start_trace reload=true autoStop=true

# Manual trace control
mcp__chrome-devtools__performance_start_trace reload=false autoStop=false
# ... interact with page ...
mcp__chrome-devtools__performance_stop_trace

# Analyze specific insight
mcp__chrome-devtools__performance_analyze_insight insightSetId="abc" insightName="LCPBreakdown"
```

### Quick Reference

| Operation   | Tool                    | Key Params              |
| ----------- | ----------------------- | ----------------------- |
| List pages  | `list_pages`            | -                       |
| Select page | `select_page`           | pageIdx                 |
| Navigate    | `navigate_page`         | type, url               |
| Screenshot  | `take_screenshot`       | fullPage, uid, filePath |
| Snapshot    | `take_snapshot`         | verbose                 |
| Click       | `click`                 | uid, dblClick           |
| Fill        | `fill`                  | uid, value              |
| Fill form   | `fill_form`             | elements                |
| Press key   | `press_key`             | key                     |
| Network     | `list_network_requests` | resourceTypes           |
| Console     | `list_console_messages` | types                   |
| Evaluate JS | `evaluate_script`       | function                |

## Testing Workflow

```bash
# 1. Navigate to page
navigate_page type="url" url="http://localhost:3000"

# 2. Take snapshot to understand structure
take_snapshot

# 3. Interact with elements (using UIDs from snapshot)
fill uid="username-input" value="testuser"
fill uid="password-input" value="testpass"
click uid="submit-button"

# 4. Wait for result
wait_for text="Welcome"

# 5. Verify with screenshot
take_screenshot filePath="./test-result.png"
```

## When NOT to Enable Chrome DevTools MCP

Skip enabling when:

- Not doing browser automation
- Working on backend-only code
- Context space is critical
- Using other testing tools (Playwright, Cypress)

## Disabling

Remove `chrome-devtools` from `.mcp.json` or global settings, then restart Claude Code.
