---
description: Analyze the repository and generate `AGENTS.md` documentation for AI agent alignment.
---


### Workflow
1. **Analyze structure**
   - Inspect `package.json`, `README`, configs (`tsconfig`, `.eslintrc`, etc.)
   - Map folder structure (skip `node_modules`, build outputs)
   - Detect monorepo structure (Turborepo, pnpm workspaces, etc.)
   - Focus on `$ARGUMENTS` areas if provided

2. **Research dependencies** (use MCP when available)
   - Context7: `mcp__context7__resolve-library-id` + `get-library-docs`
   - Octocode: `mcp__octocode__packageSearch` for package info
   - GitHub: `githubSearchCode` for similar structures

3. **Create documentation**
   - Root `AGENTS.md` with full structure (see below)
   - For monorepos: per-package `AGENTS.md`
   - Symlink `CLAUDE.md` → `AGENTS.md`
   - Symlink `.github/copilot-instructions.md` → `../AGENTS.md`

### Root AGENTS.md Structure
```markdown
# AGENTS.md

## Project Overview
- Purpose and architecture

## Tech Stack
- Tool names (no versions)

## Top-Level Scripts
- Build, test, lint commands

## Workspace Map (monorepo only)
- Package locations and purposes

## Best Practices
- 4-8 key practices for the stack

## Linting & Formatting
- Rules from ESLint/Prettier/TypeScript

## Testing
- Frameworks and test command
- Fixture locations

## CI Gates
- CI checks and how to run locally

## Security
- Secrets management
- Auth flows

## Agent Hints
- Architecture boundaries
- Safe extension points
```

### Package AGENTS.md (monorepo)
```markdown
# AGENTS.md

## Package Purpose & Layout
- What this package does

## Key Dependencies
- Main libraries used

## Best Practices
- Package-specific workflows

## Style, Lint & Testing
- Local rules and test patterns

## Fixtures
- Test data locations

## Agent Hints
- Boundaries and extension points
```

### Commands
```bash
# Detect monorepo
fd -t f "package.json|pnpm-workspace.yaml|turbo.json"

# Find configs
fd -t f "tsconfig|eslintrc|prettierrc|vite.config|next.config"

# Map structure
eza -T -L 3 --ignore-glob "node_modules|dist|build"
```
