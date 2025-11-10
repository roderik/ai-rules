# AI Skills Management

Professional skills for AI assistants: security-first blockchain development and production-ready cloud-native infrastructure.

## Zero to Operational

```bash
# 1. Install Homebrew
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

# 2. Install Bun
brew install bun

# 3. Install AI tools (pick one or more)
brew install claude-code || bun add -g claude-code
# Or: brew install opencode || bun add -g @opencode/cli
# Or: brew install codex || bun add -g @codex/cli
# Or: brew install gemini-cli || bun add -g @google/gemini-cli

# 4. Install openskills
brew install openskills || bun add -g openskills

# 5. Install skills
openskills install roderik/ai-rules --global

# 6. Authenticate (pick your tool)
claude login
# Or: opencode auth login
# Or: codex login
# Or: export GOOGLE_API_KEY="your-key"  # Get from https://aistudio.google.com/app/apikey

# 7. Setup system (optional - installs modern CLI tools)
claude --dangerously-skip-permissions --print "$(openskills read rr-system) Complete system setup."
# Or: opencode run "$(openskills read rr-system) Complete system setup."
# Or: codex exec "$(openskills read rr-system) Complete system setup."  # Note: codex may have --dangerously-bypass-approvals-and-sandbox aliased
# Or: gemini -p "$(openskills read rr-system) Complete system setup."
```

## In Projects

```bash
# Sync skills to project
cd /path/to/project
openskills sync

# Use skills (examples)
claude "Use rr-typescript to setup TypeScript"
opencode run "Use rr-kubernetes to create deployment"
codex "Use rr-solidity to write ERC20 contract"
gemini -p "Use rr-tanstack to setup Query"
```

## Skills

- **[rr-better-auth](./.claude/skills/rr-better-auth/)** - Better Auth authentication framework
- **[rr-gitops](./.claude/skills/rr-gitops/)** - Git workflow & GitHub CLI best practices
- **[rr-kubernetes](./.claude/skills/rr-kubernetes/)** - K8s, Helm & OpenShift production deployments
- **[rr-orpc](./.claude/skills/rr-orpc/)** - Type-safe RPC APIs with oRPC
- **[rr-skill-creator](./.claude/skills/rr-skill-creator/)** - Create new skills
- **[rr-solidity](./.claude/skills/rr-solidity/)** - Security-first Solidity development with Foundry
- **[rr-system](./.claude/skills/rr-system/)** - System setup & modern CLI tools
- **[rr-tanstack](./.claude/skills/rr-tanstack/)** - TanStack ecosystem (Query, Router, Table, Form)
- **[rr-typescript](./.claude/skills/rr-typescript/)** - TypeScript, Bun & Vitest best practices

## Commands

```bash
openskills list                              # List skills
openskills install roderik/ai-rules --global # Install skills
openskills sync                              # Sync to project AGENTS.md
openskills read rr-system                    # View skill content
```

## Resources

- [marketplace.json](./marketplace.json) - Full skill catalog
- [OpenSkills](https://github.com/numman-ali/openskills)
- [Anthropic Skills](https://github.com/anthropics/skills)
