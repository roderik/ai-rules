---
description: Analyze repository and generate AGENTS.md documentation for AI agent alignment. Use when initializing repo for AI-assisted dev, updating docs after structural changes, or establishing best practices.
mode: primary
model: anthropic/claude-sonnet-4-5
---

## Mission

Analyze repo, generate concise `AGENTS.md`, wire up agent/editor instructions. Minimize context bloat.

## MCP Integration (Use All Available)

**Phase 0: Data Collection (MANDATORY):**

```bash
# Dependencies (for EVERY package)
mcp__octocode__packageSearch --npmPackages "[all-dependencies]"
mcp__context7__resolve-library-id --libraryName "[each-dependency]"
mcp__context7__get-library-docs --context7CompatibleLibraryID "[resolved-ids]"

# Framework patterns
mcp__octocode__githubSearchCode --queries "[framework] best practices 2024"

# Project context
mcp__linear__list_projects
```

**Multi-Model Analysis:**
```bash
gemini -m gemini-2.5-pro -p "Analyze codebase structure: patterns? improvements?"
codex -m gpt-5 -c reasoning.level="high" "Analyze tech stack, identify issues: [stack]"
claude --model opus --print "Summarize risks, propose actions for onboarding."
```

## Objectives

1. Create root `AGENTS.md` as single source of truth
2. Symlink `CLAUDE.md` and `.github/copilot-instructions.md` to root `AGENTS.md`
3. Root `AGENTS.md` contains:
   - Project overview (no fluff)
   - Tech stack (names only, **no versions**)
   - Root commands only (dev/build/test/lint/typecheck/format)
   - If monorepo: structure map + dependency graph
4. Monorepo handling:
   - Per-package `AGENTS.md` (tailored, no scripts)
   - Per-package `CLAUDE.md` symlink
   - Scoped `.github/instructions/*.md` with `applyTo` globs
5. Generate best-practices list using context7 MCP + web search

## Detection

- Read: `README*`, `package.json`, `pnpm-workspace.yaml`, `turbo.json`, `tsconfig*.json`, configs, CI
- Monorepo: `workspaces`, `turbo.json`, multiple `package.json` under `apps/*`/`packages/*`
- Note package manager quirks (pnpm `-F`, yarn workspaces)

## Root AGENTS.md Structure

```markdown
# Project Snapshot (5-8 lines)
[What it is, who it's for, major components]

# Stack (names only)
Node, TypeScript, Next.js, Drizzle, Vitest, Turborepo

# Commands (root only)
- `dev` - Start development
- `build` - Production build
- `test` - Run test suite
- `lint` - Check code style
- `typecheck` - Validate types
- `format` - Format code

# Structure
## Monorepo
[Workspace graph: apps, packages, shared libs]
[Optional: Turborepo dependency graph]

## Single Repo
- `/src` - Source code
- `/scripts` - Build/deploy scripts
- `/config` - Configuration

# Best Practices (6-12 bullets)
[Concrete patterns from detected tools via MCP]

# Coding Standards
- ESLint/Prettier/TS key rules (3-6 bullets)
- Path aliases, module target, formatting

# TypeScript (if TS)
- Enable strictness
- Branded types for IDs
- Schema-first with Zod/Valibot

# Testing
- Full suite: `bun run test`
- Single test: `bun run test path/to/file.test.ts`
- Fixtures: `/fixtures` or `/tests/__fixtures__`

# CI Gates
- Checks: lint, typecheck, test
- Local: `bun run ci` or run checks individually

# Security & Secrets
- Env files: `.env`, `.env.local`, `.env.example`
- CI: repo/org secrets
- Local: dotenv loading

# Agent Hints
- Respect architectural boundaries
- Avoid generating infra/config unless requested
- Prefer minimal, local changes
```

## Package AGENTS.md (Monorepo)

```markdown
# Purpose (3-5 lines)
[What this package does, who consumes it]

# Layout
- Entry: `src/index.ts`
- Key folders: `routes/`, `components/`, `schemas/`

# Dependencies (names only)
[Local packages + key external libs]

# Best Practices (4-8 bullets)
[From MCP + web search]

# Style & Testing
- TS strictness bullets (up to 5)
- ESLint/Prettier deltas from root
- Test/fixture locations

# Agent Hints
- Interface boundaries
- What not to touch
- Safe extension points
- CI is root-managed
```

## Copilot Scoping (Monorepo)

Create `.github/instructions/<kebab-name>.instructions.md`:

```yaml
---
applyTo: "<path>/**"
---
For files under <path>/, treat <path>/AGENTS.md as canonical.
• Do not modify package scripts/tasks.
• Follow Best Practices in that AGENTS.md.
• Prefer small, local changes.
```

## Symlinks

- Root: `CLAUDE.md` → `AGENTS.md`, `.github/copilot-instructions.md` → `../AGENTS.md`
- Per-package: `CLAUDE.md` → local `AGENTS.md`
- Fallback (Windows/locked FS): 1-line stub file

## Best Practices Generation

- Extract tool names from `dependencies`/`devDependencies`
- Use context7 MCP + web search for current practices
- Crisp bullets (1-2 lines each), no versions

## Safety

- Update in-place between `<!-- BEGIN AUTO -->` / `<!-- END AUTO -->` markers
- Never delete user content outside markers
- Skip `node_modules`, build artifacts, lockfiles

## Verification Checklist

- [ ] Root `AGENTS.md` created/updated
- [ ] Root symlinks created (or stubs if needed)
- [ ] Monorepo: per-package `AGENTS.md` + `CLAUDE.md` symlinks
- [ ] Monorepo: `.github/instructions/*.md` with `applyTo` globs
- [ ] Best practices from MCP (names only)
- [ ] ESLint/Prettier/TS rules mirrored
- [ ] Testing includes single-test example
- [ ] CI gates listed with local reproduction
- [ ] Security & secrets guidance
- [ ] Turborepo: structure map + optional dependency graph
