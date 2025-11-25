---
name: rr-shadcn
description: shadcn/ui component library integration with on-demand MCP server loading. Use when adding UI components, searching component registries, viewing component examples, or scaffolding new UI. Example triggers: "Add button component", "Search shadcn components", "View component examples", "Install shadcn", "Enable shadcn integration"
---

# shadcn/ui Skill

On-demand shadcn/ui component library integration. This skill provides instructions to enable the shadcn MCP server per-project, reducing global context usage (~7 tools) while maintaining full component library access when needed.

## When to Use This Skill

Use this skill for:

- Adding shadcn/ui components to a project
- Searching for components in registries
- Viewing component source code and examples
- Finding usage patterns and demos

## Enabling shadcn MCP (On-Demand)

### Option 1: Project .mcp.json (Recommended)

Create `.mcp.json` in project root:

```json
{
  "mcpServers": {
    "shadcn": {
      "type": "stdio",
      "command": "bun",
      "args": ["x", "-y", "shadcn@latest", "mcp"],
      "env": {}
    }
  }
}
```

Then restart Claude Code or run `/mcp` to reload servers.

### Option 2: Temporary Global Enable

Add to `~/.claude/settings.json` under `mcpServers`:

```json
"shadcn": {
  "type": "stdio",
  "command": "bun",
  "args": ["x", "-y", "shadcn@latest", "mcp"],
  "env": {}
}
```

## Prerequisites

Project must have `components.json` (shadcn config). Initialize if needed:

```bash
bunx shadcn@latest init
```

## Common Workflows

### Finding Components

```bash
# Get configured registries
mcp__shadcn__get_project_registries

# List all components in registry
mcp__shadcn__list_items_in_registries registries=["@shadcn"]

# Search for specific component
mcp__shadcn__search_items_in_registries registries=["@shadcn"] query="button"
mcp__shadcn__search_items_in_registries registries=["@shadcn"] query="date picker"
```

### Viewing Components

```bash
# View component details and source
mcp__shadcn__view_items_in_registries items=["@shadcn/button", "@shadcn/card"]

# Get usage examples
mcp__shadcn__get_item_examples_from_registries registries=["@shadcn"] query="button-demo"
mcp__shadcn__get_item_examples_from_registries registries=["@shadcn"] query="accordion-demo"
```

### Adding Components

```bash
# Get add command for components
mcp__shadcn__get_add_command_for_items items=["@shadcn/button", "@shadcn/card"]

# Then run the command
bunx shadcn@latest add button card
```

### Post-Install Audit

```bash
# Get checklist after adding components
mcp__shadcn__get_audit_checklist
```

### Quick Reference

| Operation       | Tool                                | Key Params        |
| --------------- | ----------------------------------- | ----------------- |
| Get registries  | `get_project_registries`            | -                 |
| List components | `list_items_in_registries`          | registries        |
| Search          | `search_items_in_registries`        | registries, query |
| View source     | `view_items_in_registries`          | items             |
| Get examples    | `get_item_examples_from_registries` | registries, query |
| Get add command | `get_add_command_for_items`         | items             |
| Audit checklist | `get_audit_checklist`               | -                 |

## Common Components

Popular shadcn/ui components:

**Layout:** `card`, `separator`, `aspect-ratio`, `scroll-area`

**Forms:** `button`, `input`, `textarea`, `select`, `checkbox`, `radio-group`, `switch`, `slider`, `form`

**Data Display:** `table`, `badge`, `avatar`, `calendar`, `chart`

**Feedback:** `alert`, `alert-dialog`, `toast`, `sonner`, `progress`, `skeleton`

**Navigation:** `tabs`, `navigation-menu`, `breadcrumb`, `pagination`, `command`

**Overlay:** `dialog`, `drawer`, `dropdown-menu`, `popover`, `tooltip`, `sheet`

## Workflow: Adding UI Feature

```bash
# 1. Enable shadcn MCP (add to .mcp.json)

# 2. Search for needed components
search_items_in_registries registries=["@shadcn"] query="form"

# 3. View examples to understand usage
get_item_examples_from_registries registries=["@shadcn"] query="form-demo"

# 4. Get add command
get_add_command_for_items items=["@shadcn/form", "@shadcn/input", "@shadcn/button"]

# 5. Run command
bunx shadcn@latest add form input button

# 6. Run audit checklist
get_audit_checklist

# 7. Implement using examples as reference
```

## CLI Alternative (Without MCP)

For simple component additions, use CLI directly:

```bash
# Add single component
bunx shadcn@latest add button

# Add multiple components
bunx shadcn@latest add button card input form

# List available components
bunx shadcn@latest add --all

# Diff to see changes
bunx shadcn@latest diff button
```

## When NOT to Enable shadcn MCP

Skip enabling when:

- Project doesn't use shadcn/ui
- Only adding 1-2 known components (use CLI)
- Working on backend code
- Context space is critical

## Disabling

Remove `shadcn` from `.mcp.json` or global settings, then restart Claude Code.
