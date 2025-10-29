---
description: Analyze repository and generate AGENTS.md documentation
---

## Workflow

1. **Analyze**
   - Inspect: `package.json`, `README`, configs (tsconfig, eslint, etc.)
   - Map structure (skip `node_modules`, build outputs)
   - Detect monorepo (Turborepo, pnpm workspaces)
   - Focus on `$ARGUMENTS` if provided

2. **Research** (use MCP when available)
   - Context7: `resolve-library-id` + `get-library-docs`
   - Octocode: `packageSearch` for package info
   - GitHub: `githubSearchCode` for similar structures

3. **Generate**
   - Root `AGENTS.md` (see structure below)
   - Monorepo: per-package `AGENTS.md`
   - Symlink `CLAUDE.md` → `AGENTS.md`
   - Symlink `.github/copilot-instructions.md` → `../AGENTS.md`

## Root AGENTS.md

```markdown
# Project Overview
[Purpose and architecture]

# Tech Stack
[Tool names (no versions)]

# Commands
[Build, test, lint scripts]

# Structure
[Workspace map for monorepo, or top-level dirs]

# Best Practices
[4-8 key practices for stack]

# Linting & Formatting
[ESLint/Prettier/TS rules]

# Testing
[Frameworks, commands, fixture locations]

# CI Gates
[Checks and local reproduction]

# Security
[Secrets management, auth flows]

# Agent Hints
[Boundaries, extension points]
```

## Package AGENTS.md (Monorepo)

```markdown
# Purpose & Layout
[What package does]

# Dependencies
[Main libraries]

# Best Practices
[Package-specific workflows]

# Style & Testing
[Local rules, test patterns, fixtures]

# Agent Hints
[Boundaries, extension points]
```

## Commands

```bash
# Detect monorepo
fd -t f "package.json|pnpm-workspace.yaml|turbo.json"

# Find configs
fd -t f "tsconfig|eslintrc|prettierrc"

# Map structure
eza -T -L 3 --ignore-glob "node_modules|dist|build"
```
