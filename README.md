# AI Skills Management with OpenSkills

Professional skills collection for AI assistants covering security-first blockchain development and production-ready cloud-native infrastructure.

Manage custom skills across Claude Code, OpenCode, Cursor, and Codex using [openskills](https://github.com/numman-ali/openskills).

## Overview

This repository uses the `.claude/skills/` directory to store custom skills that follow Anthropic's skills specification. These skills work across multiple AI coding tools:

- **Claude Code**: Native skill support via `Skill` tool
- **OpenCode**: CLI-based skills via `openskills read <name>`
- **Cursor**: CLI-based skills via `openskills read <name>` in AGENTS.md
- **Codex**: CLI-based skills via `openskills read <name>` in AGENTS.md

## Quick Start: Bare Machine Setup

Complete setup from scratch on a new machine.

### Step 1: Install Homebrew (macOS/Linux)

```bash
# Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# Verify installation
brew --version
```

### Step 2: Install Bun

```bash
# Install via Homebrew (preferred)
brew install bun

# Or via curl (alternative)
# curl -fsSL https://bun.sh/install | bash

# Verify installation
bun --version
```

### Step 3: Install AI CLI Tools

```bash
# Install Claude Code (via Homebrew if available, otherwise use npm/bun)
brew install claude-code || bun add -g claude-code

# Install OpenCode
brew install opencode || bun add -g @opencode/cli

# Install Codex
brew install codex || bun add -g @codex/cli

# Install Gemini CLI
bun add -g @google/gemini-cli
```

**Note:** Some tools may not be in Homebrew yet. The commands above fall back to `bun add` if Homebrew install fails.

### Step 4: Install OpenSkills

```bash
# Install openskills globally via bun
bun add -g openskills

# Verify installation
openskills --version
```

### Step 5: Install Skills Globally

```bash
# Install all skills from this repository
openskills install roderik/ai-rules --global

# Skills are installed to ~/.claude/skills/
# Interactive checkbox lets you select which skills to install
```

**Note:** Skills are now globally installed and ready to use. You'll sync to project-specific `AGENTS.md` later when you have a project.

## Authentication Setup

### Claude Code Authentication

```bash
# Login to Claude Code
claude login

# Verify authentication
claude whoami
```

Visit the authentication URL and enter the code provided.

### OpenCode Authentication

```bash
# Login to OpenCode
opencode auth login

# Verify authentication
opencode auth whoami
```

Follow the authentication prompts to complete the login process.

### Codex Authentication

```bash
# Login to Codex
codex login

# Verify authentication
codex whoami
```

### Gemini Authentication

```bash
# Set API key
export GOOGLE_API_KEY="your-api-key-here"

# Or add to ~/.bashrc or ~/.zshrc
echo 'export GOOGLE_API_KEY="your-api-key-here"' >> ~/.zshrc

# Verify authentication
gemini --version
```

Get your API key from: https://aistudio.google.com/app/apikey

## Complete System Setup with rr-system Skill

After installing the skills and authenticating, use the `rr-system` skill to finish configuring your development environment with modern CLI tools.

Since we don't have a project with `AGENTS.md` yet, we'll use `openskills read` to load the skill directly.

### Using Claude Code

```bash
# Load the skill content and pass to Claude (non-interactive)
claude --print "$(openskills read rr-system)

Complete my system setup following the instructions above."
```

### Using OpenCode

```bash
# Load the skill content and pass to OpenCode
opencode run "$(openskills read rr-system)

Complete my system setup following the instructions above."
```

### Using Codex

```bash
# Load the skill content and pass to Codex (non-interactive)
codex exec "$(openskills read rr-system)

Complete my system setup following the instructions above."
```

### Using Gemini

```bash
# Load the skill content and pass to Gemini
gemini -p "$(openskills read rr-system)

Complete my system setup following the instructions above."
```

The `rr-system` skill will guide the agent to install and configure:
- Modern CLI tools (fd, rg, bat, eza, etc.)
- Git configuration
- Development tools and aliases
- Shell enhancements

### After System Setup: Sync Skills to Projects

Once you have a project directory, sync skills to enable automatic skill loading:

```bash
# In your project directory
cd /path/to/your/project

# Sync skills to AGENTS.md
openskills sync
```

This creates/updates `AGENTS.md` with a `<skills_system>` section, allowing agents to automatically discover and use skills without manually loading them via `openskills read`.

## Quick Reference

```bash
# List installed skills
openskills list

# Read a skill (useful for manual loading or inspection)
openskills read rr-system

# Call an agent with a skill (if AGENTS.md is synced in project)
claude "Use rr-typescript skill to help me set up a new TypeScript project"
opencode run "Use rr-kubernetes skill to create a production-ready deployment"
codex "Use rr-solidity skill to write a secure ERC20 contract"
gemini -p "Use rr-tanstack skill to set up TanStack Query"

# Call an agent with a skill (without AGENTS.md - manual loading)
claude --print "$(openskills read rr-typescript)

Help me set up a new TypeScript project following the instructions above."

opencode run "$(openskills read rr-kubernetes)

Create a production-ready deployment following the instructions above."

codex exec "$(openskills read rr-solidity)

Write a secure ERC20 contract following the instructions above."

gemini -p "$(openskills read rr-tanstack)

Set up TanStack Query following the instructions above."

# Sync skills to project AGENTS.md
cd /path/to/your/project
openskills sync
```

## Available Skills

### 🔐 [rr-better-auth](./.claude/skills/rr-better-auth/)
**Better Auth Authentication Framework**

Type-safe authentication with Better Auth framework for Next.js and React applications.

**Triggers:** `better-auth`, authentication setup, auth configuration

---

### 🔧 [rr-gitops](./.claude/skills/rr-gitops/)
**Git Workflow & GitHub CLI**

Git best practices, GitHub CLI operations, and PR management workflows.

**Triggers:** Git operations, GitHub CLI, PR workflows

---

### ☸️ [rr-kubernetes](./.claude/skills/rr-kubernetes/)
**Kubernetes, Helm & OpenShift Operations**

Production-ready Kubernetes manifest generation, Helm chart development, and security policy implementation.

**Features:**
- Generate production-ready K8s manifests
- Scaffold Helm charts with best practices
- Security policies (PSS, Network Policies, RBAC)
- OpenShift-specific resources (Routes, ImageStreams)
- Automated validation and security scanning
- Multi-environment deployment strategies

**Triggers:** `.yaml`/`.yml` files, Helm charts, kubectl/oc commands

---

### 🔌 [rr-orpc](./.claude/skills/rr-orpc/)
**oRPC Framework**

Type-safe API development with oRPC framework for building end-to-end type-safe APIs.

**Triggers:** `orpc`, API development, type-safe RPC

---

### 🛠️ [rr-skill-creator](./.claude/skills/rr-skill-creator/)
**Skill Creator Guide**

Comprehensive guide for creating effective skills with proper structure, validation, and packaging.

**Triggers:** Creating or editing skills, SKILL.md files

---

### 🔗 [rr-solidity](./.claude/skills/rr-solidity/)
**Solidity Development with Foundry**

Security-first smart contract development with Foundry framework, testing, static analysis, and deployment workflows.

**Features:**
- Security-first contract patterns (CEI, access control)
- Comprehensive testing (unit, fuzz, invariant)
- Static analysis integration (Slither, solhint)
- Deployment and verification scripts
- Gas optimization strategies

**Triggers:** `.sol` files, Foundry projects

---

### 💻 [rr-system](./.claude/skills/rr-system/)
**System Setup & Modern CLI Tools**

System configuration, modern CLI tool setup, and development environment best practices.

**Triggers:** System setup, CLI tool configuration

---

### 📊 [rr-tanstack](./.claude/skills/rr-tanstack/)
**TanStack Ecosystem**

Comprehensive guidance for TanStack libraries (Query, Router, Table, Form, Start, Virtual, Store, DB).

**Triggers:** TanStack libraries, data fetching, routing, forms, tables

---

### 📘 [rr-typescript](./.claude/skills/rr-typescript/)
**TypeScript, Bun & Vitest**

TypeScript best practices, Bun runtime patterns, and Vitest testing standards.

**Triggers:** `.ts`/`.tsx` files, TypeScript projects

---

## Skills Marketplace

A **[marketplace.json](./marketplace.json)** file at the repository root provides a complete catalog of published skills with metadata.

The marketplace focuses on **security-first blockchain development** (Solidity smart contracts with Foundry) and **production-ready cloud-native infrastructure** (Kubernetes orchestration, Helm charts, OpenShift operations, security policies, and multi-environment deployment strategies).

```bash
# Browse all skills
cat marketplace.json | jq '.skills[] | {id, name, category}'

# View skill details
cat marketplace.json | jq '.skills[] | select(.id == "rr-kubernetes")'
```

The marketplace includes:
- **Category organization** (Blockchain & Web3, DevOps & Infrastructure)
- **Trigger patterns** for auto-activation (file extensions, patterns, keywords)
- **Feature descriptions** and compatibility info
- **Tags and keywords** for discovery

## Directory Structure

```
.
├── marketplace.json     # Skills catalog with metadata
├── .claude/
│   └── skills/          # Skill source code
│       ├── rr-typescript/
│       │   ├── SKILL.md
│       │   └── references/
│       ├── rr-orpc/
│       │   ├── SKILL.md
│       │   └── references/
│       └── ...
├── .github/
│   ├── workflows/       # CI validation
│   └── validate-all.sh  # Local validation script
├── AGENTS.md            # Configuration for OpenCode, Cursor, Codex
└── CLAUDE.md            # Global preferences for all tools
```

Skills are installed globally to `~/.claude/skills/` on your machine.

## Skill Structure

Each skill follows this structure:

```
skill-name/
├── SKILL.md              # Main skill documentation
├── references/           # Reference documentation
├── scripts/              # Executable utilities
├── assets/               # Templates and resources
└── marketplace.json      # Individual skill metadata (optional)
```

## Common Commands

### List Installed Skills

```bash
openskills list
```

Shows all globally installed skills from `~/.claude/skills/`.

### Install Skills

```bash
# From this repository
openskills install roderik/ai-rules --global

# From Anthropic's marketplace
openskills install anthropics/skills --global

# From other repositories
openskills install your-username/your-skill --global
```

### Read Skills

```bash
# Read skill content (for inspection or manual loading)
openskills read rr-system

# Use with agents (without AGENTS.md synced)
claude --print "$(openskills read rr-typescript)

Set up a new TypeScript project following the instructions above."

opencode run "$(openskills read rr-typescript)

Set up a new TypeScript project following the instructions above."

codex exec "$(openskills read rr-typescript)

Set up a new TypeScript project following the instructions above."

gemini -p "$(openskills read rr-typescript)

Set up a new TypeScript project following the instructions above."
```

### Sync to AGENTS.md

Update the skills list in AGENTS.md (run from project directory):

```bash
cd /path/to/your/project
openskills sync
```

Run after installing or removing skills, or when setting up a new project.

### Remove Skills

```bash
# Interactive removal
openskills manage

# Remove specific skill
openskills remove rr-typescript
```

## Validation

All skills are automatically validated in CI using GitHub Actions. Validate locally before committing:

```bash
# Validate all skills
./.github/validate-all.sh

# Validate specific skill
python3 .claude/skills/rr-skill-creator/scripts/quick_validate.py .claude/skills/rr-tanstack
```

Validation checks:
- YAML frontmatter format
- Required fields (`name`, `description`)
- Naming conventions (hyphen-case)
- Description format
- openskills CLI compatibility

See [.github/workflows/README.md](./.github/workflows/README.md) for CI details.

## How Skills Work Across Tools

### Claude Code

Claude Code has **native skill support** via the `Skill` tool:

```xml
<skill>
<name>rr-typescript</name>
<description>Guidance for writing TypeScript code...</description>
<location>project</location>
</skill>
```

When user mentions a skill, Claude invokes: `Skill("rr-typescript")`

### OpenCode, Cursor, Codex

These tools support skills in two ways:

**1. Via AGENTS.md (automatic - after sync)**

```xml
<skill>
<name>rr-typescript</name>
<description>Guidance for writing TypeScript code...</description>
<location>project</location>
</skill>
```

When user mentions a skill, agent invokes: `Bash("openskills read rr-typescript")`

**2. Via Manual Loading (before project setup)**

```bash
# Load skill content directly into prompt
opencode run "$(openskills read rr-typescript)

Set up TypeScript project following the instructions above."

# Or with other tools:
claude --print "$(openskills read rr-typescript) ..."
codex exec "$(openskills read rr-typescript) ..."
gemini -p "$(openskills read rr-typescript) ..."
```

**Same format, different invocation methods.**

## Multi-Tool Setup

If you use multiple AI tools, here's the recommended configuration:

### Claude Code
- Reads skills from `.claude/skills/` automatically
- Can also read from AGENTS.md if synced
- Uses native `Skill` tool
- Works immediately after global skill installation

### OpenCode
- **With project:** Requires AGENTS.md with skills section (via `openskills sync`)
- **Without project:** Use `openskills read <name>` to manually load skills
- Uses `openskills read <name>` via Bash when AGENTS.md is synced

### Cursor
- **With project:** Requires AGENTS.md with skills section (via `openskills sync`)
- **Without project:** Use `openskills read <name>` to manually load skills
- Uses `openskills read <name>` via Bash when AGENTS.md is synced

### Codex
- **With project:** Requires AGENTS.md with skills section (via `openskills sync`)
- **Without project:** Use `openskills read <name>` to manually load skills
- Uses `openskills read <name>` via Bash when AGENTS.md is synced

### Sync Strategy

**Before project setup:** Use `openskills read <name>` to manually load skills into prompts

**After project setup:** Run `openskills sync` in your project directory to enable automatic skill discovery via AGENTS.md

Run `openskills sync` after any skill changes to ensure all tools have the updated list.

## Skill Naming Convention

This repository uses the `rr-` prefix for custom skills to distinguish them from Anthropic's marketplace skills.

**Patterns used:**
- `rr-<domain>` - Domain-specific skills (e.g., `rr-typescript`, `rr-solidity`)
- `rr-<framework>` - Framework skills (e.g., `rr-orpc`, `rr-tanstack`)
- `rr-<workflow>` - Workflow skills (e.g., `rr-gitops`, `rr-system`)

## Contributing

Contributions welcome! To add a new skill:

1. Follow existing skill structure
2. Validate with `./.github/validate-all.sh`
3. Add entry to root `marketplace.json`
4. Update this README
5. Submit pull request

## Troubleshooting

### Skills not appearing in list

Check install location:

```bash
ls -la ~/.claude/skills/
```

### Agent not loading skills

1. Verify AGENTS.md has skills section:

```bash
grep -A 10 "<skills_system>" AGENTS.md
```

2. Re-sync:

```bash
openskills sync
```

3. Restart your AI tool

### Skill not reading correctly

Verify SKILL.md format:

```bash
openskills read skill-name
```

Ensure frontmatter has `name` and `description`.

## Requirements

- **Homebrew** (macOS/Linux) - Preferred installation method
- **Bun** or **Node.js** 20.6+ (for openskills and fallback installations)
- **Git** (for installing from GitHub)
- **Bash** (for agents to invoke openskills)
- **Python** 3.11+ (for validation scripts)

**Installation preference order:**
1. `brew install <package>` (preferred - easiest updates and management)
2. `bun add -g <package>` (fallback - when not in Homebrew)
3. `npm i -g <package>` or `pnpm add -g <package>` (alternatives)

## Resources

- [OpenSkills GitHub](https://github.com/numman-ali/openskills)
- [Anthropic Skills Marketplace](https://github.com/anthropics/skills)
- [Anthropic Skills Blog Post](https://www.anthropic.com/engineering/equipping-agents-for-the-real-world-with-agent-skills)

## Support

- **Documentation**: See individual skill README files
- **Issues**: [GitHub Issues](https://github.com/roderik/ai-rules/issues)
- **Repository**: [github.com/roderik/ai-rules](https://github.com/roderik/ai-rules)

## License

MIT License - see individual skill directories for details.

---

**Note**: OpenSkills is not affiliated with Anthropic. It implements Anthropic's open skills specification.
