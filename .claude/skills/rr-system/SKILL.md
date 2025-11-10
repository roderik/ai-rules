---
name: rr-system
description: System setup, tool information, and AI configuration management for development environments. Use when setting up new machines, explaining available tools (shell-config, ai-rules, wt), managing AI assistant configurations (Claude/Codex/Gemini/OpenCode), checking system configuration, or troubleshooting environment issues. Provides installation scripts, configuration management workflows, and comprehensive tool references.
---

# System Setup

## Overview

Provides comprehensive system setup automation and tool reference for the rr- development environment, including shell-config (Fish/Zsh/Bash + modern CLI tools), ai-rules (AI assistant configurations), and wt (git worktree manager). Use when setting up new machines, explaining installed tools, checking configurations, or troubleshooting environment issues.

**⚠️ IMPORTANT: ALWAYS CHECK OFFICIAL DOCUMENTATION ONLINE**

This skill provides a reference baseline, but tools evolve rapidly. Before making configuration changes or providing usage instructions:

1. **Search online for the latest official documentation** of each tool
2. **Verify current CLI options and flags** (many tools update frequently)
3. **Check for breaking changes** in recent versions
4. **Use official docs as source of truth** - this skill may be outdated

**Official documentation sources are listed in the Tool Reference section below.**

## When to Use This Skill

- Setting up new macOS, Ubuntu, or Debian development machines
- Explaining what tools are available (shell commands, aliases, modern CLI tools)
- Managing AI assistant configurations (Claude Code, Codex CLI, Gemini CLI, OpenCode)
- Editing, validating, or updating configuration files for AI assistants
- Adding/removing MCP servers across AI platforms
- Checking if a tool or configuration exists
- Troubleshooting environment issues
- Updating existing installations
- Guiding users through system configuration

## Core Capabilities

### 1. System Installation

Install complete development environment on clean or partially configured systems.

**macOS Installation:**
```bash
bash scripts/install-macos.sh
```

Installs:
- Xcode Command Line Tools
- Homebrew
- shell-config (Fish/Zsh/Bash + 60+ modern tools)
- ai-rules (Claude Code, Codex, Gemini configurations)
- wt (git worktree manager)

**Ubuntu/Debian Installation:**
```bash
bash scripts/install-ubuntu.sh
```

Installs same components plus:
- Base development tools (build-essential, curl, git)
- Homebrew for Linux
- Shell permission configuration
- Supports both Ubuntu and Debian (apt-based systems)

Both scripts verify installations and provide next steps.

### 2. System Updates

Update all components to latest versions:
```bash
bash scripts/update-system.sh
```

Updates:
- Homebrew packages
- shell-config (downloads latest)
- ai-rules (downloads latest)
- wt (downloads latest)

### 3. AI Configuration Management

Directly manage AI assistant configuration files without using installation scripts. This approach allows precise control and validation of configurations that change frequently.

**Supported AI Assistants:**
- Claude Code (`~/.claude/settings.json`)
- Codex CLI (`~/.codex/config.toml`)
- Gemini CLI (`~/.gemini/settings.json`)
- OpenCode (`~/.config/opencode/opencode.json`)

**Template Configurations:**

Template config files available in `assets/`:
- `claude-settings.json` - Claude Code configuration
- `codex-config.toml` - Codex CLI configuration
- `gemini-settings.json` - Gemini CLI configuration
- `opencode-config.json` - OpenCode configuration

Use these templates as reference or copy directly to target locations.

**Configuration Capabilities:**

**Inspect Current Configuration:**
```bash
# Claude Code
jq . ~/.claude/settings.json

# Codex CLI
bat ~/.codex/config.toml

# Gemini CLI
jq . ~/.gemini/settings.json

# OpenCode
jq . ~/.config/opencode/opencode.json
```

**Edit Configuration Files:**

Use Read tool to load current config, Edit tool to make changes, then validate syntax:
```bash
# JSON files (Claude, Gemini, OpenCode)
jq empty <config-file>  # Validate syntax

# TOML files (Codex)
python3 -c "import tomllib; tomllib.load(open('<config-file>', 'rb'))"
```

**Common Configuration Tasks:**

Add MCP Server:
1. Read current config file
2. Add server definition to appropriate section
3. Validate syntax
4. Restart AI assistant

Update Environment Variables:
1. Read config file
2. Modify env section
3. Validate and save
4. Restart assistant

Modify Hooks (Claude only):
1. Read settings.json
2. Add/modify hooks array
3. Validate JSON
4. Restart Claude Code

**Workflow Example - Add MCP Server:**
1. Read current config: `~/.claude/settings.json`
2. Reference template: `assets/claude-settings.json` for format
3. Identify `mcpServers` section
4. Add new server entry with proper format
5. Validate JSON: `jq empty ~/.claude/settings.json`
6. Test: Restart Claude Code and verify server loads

**Workflow Example - Install/Update Config:**
1. Read template from `assets/<platform>-<config-name>`
2. Read existing user config (if exists)
3. Merge or replace as appropriate
4. Validate syntax
5. Write to target location
6. Instruct user to restart assistant

**Feature Parity Principle:**

Maintain near-identical configurations across all AI platforms to ensure consistent capabilities:

**MCP Servers - Keep Synchronized:**
All platforms should have the same MCP servers configured:
- linear (if using Linear)
- context7 (library documentation)
- octocode (GitHub code exploration)
- shadcn (component library)
- chrome-devtools (browser automation)
- Any custom/project-specific MCP servers

**When Adding/Removing MCP Servers:**
1. Make the same change across ALL platforms
2. Adapt only the syntax for each platform's format
3. Keep server names consistent
4. Use same command/args where possible

**When Updating Configurations:**
1. Apply equivalent changes to all platforms
2. Maintain similar permission levels
3. Keep environment variables consistent
4. Mirror feature flags where applicable

**Platform-Specific Exceptions:**
Only deviate when:
- Feature genuinely unavailable on platform
- Platform requires different approach for same capability
- Security/permission model differs fundamentally

**Important Notes:**
- Always validate syntax after editing
- Backup config before making changes
- MCP server definitions vary by platform (see `references/ai-config-schemas.md`)
- Use Edit tool for precise changes, not bash scripts
- Restart AI assistant after config changes

**Reference Material:**

Load `references/ai-config-schemas.md` for:
- Complete config file schemas
- Platform-specific formats
- MCP server patterns
- Validation commands
- Merge strategies
- Troubleshooting guides

### 4. Tool Reference

**⚠️ CRITICAL: Load `references/tools-reference.md` for complete documentation links**

The tools reference contains:
1. **Official documentation URLs** for every tool (ALWAYS check these online)
2. **Quick usage examples** (verify with official docs before using)
3. **Configuration locations** and best practices

**Before providing any tool-specific commands:**
1. Load `references/tools-reference.md`
2. Find the tool's official documentation URL
3. Search online for the latest documentation
4. Verify exact CLI flags and options
5. Provide commands based on official docs, not just this reference

**Modern CLI Tools Installed:**
- File operations: bat, eza, fd, ripgrep
- Development: neovim (LazyVim), lazygit, lazydocker, fzf, ast-grep
- Navigation: zoxide, atuin, direnv
- Version managers: fnm (Node.js), uv (Python)
- System: procs, hexyl, broot, git-delta, difftastic
- Cloud: kubectl, helm, gh, aws-cli, azure-cli, gcloud
- Blockchain: foundry (forge, cast, anvil, chisel)
- Terminal: tmux, zellij
- AI CLIs: Claude Code, OpenCode, Codex, Gemini CLI
- Package managers: Homebrew, Bun
- Skills: openskills

**Configuration Locations:**
- Fish: `~/.config/fish/` (config.fish + conf.d/)
- Zsh: `~/.zshrc` + `~/.config/zsh/conf.d/`
- Bash: `~/.bashrc`, `~/.bash_profile` + `~/.config/bash/conf.d/`
- Neovim: `~/.config/nvim/` (LazyVim with Catppuccin)
- Starship: `~/.config/starship.toml`
- Claude: `~/.claude/`
- Codex: `~/.codex/`
- Gemini: `~/.gemini/`

**Git Worktree Manager (wt):**
- **Installation:** Fish shell function at `~/.config/fish/functions/wt.fish`
- **Availability:** Fish shell only (use `fish -c "wt <cmd>"` from bash/zsh)
- Commands: new, switch, list, remove, clean, status
- Auto package manager detection (Bun/NPM/Yarn/PNPM)
- Storage: `~/.wt/<repo-name>/`
- Tab completion in Fish shell
- **Verification:** Check file exists: `ls ~/.config/fish/functions/wt.fish`

**Key Aliases:**
- `ls` → `eza` (modern ls)
- `cat` → `bat` (syntax highlighting)
- `grep` → `rg` (ripgrep)
- File finder: `fd` (replaces find)
- Navigation: `z dirname`, `zi` (zoxide)
- Git: 60+ abbreviations (`g`, `ga`, `gc`, `gp`, `gl`, `gs`, etc.)
- Tools: `lzg` (lazygit), `lzd` (lazydocker), `ff` (fzf preview)

## Workflow Guide

**⚠️ BEFORE PROVIDING CONFIGURATION COMMANDS:**
1. Load `references/tools-reference.md` for official documentation links
2. Search online for the latest tool documentation
3. Verify commands match current tool versions
4. Check for breaking changes or deprecated flags

### Setting Up New Machine

1. **Determine OS:**
   - macOS: Use `install-macos.sh`
   - Ubuntu/Debian: Use `install-ubuntu.sh`

2. **Run Installation:**
   ```bash
   # Download and run appropriate script
   curl -sL https://raw.githubusercontent.com/roderik/<repo>/main/scripts/install-<os>.sh | bash
   ```

3. **Verify Installation:**
   Scripts automatically verify:
   - Homebrew in PATH
   - Fish config exists
   - Claude config exists
   - wt installed (checks for `~/.config/fish/functions/wt.fish`)

4. **Post-Installation:**
   - Restart terminal
   - Run: `fish` (start Fish shell)
   - Run: `fish -c "wt help"` (verify wt - Fish function only)
   - Optional: `chsh -s $(which fish)` (make Fish default)

5. **Verify Tools (examples - check official docs for current flags):**
   ```bash
   # Check versions (flags may vary - verify online)
   bat --version
   eza --version
   fd --version
   rg --version
   ```

   **NOTE:** Always verify command syntax with official documentation before using.

### Updating Existing Installation

1. **Run Update Script:**
   ```bash
   bash scripts/update-system.sh
   ```

2. **Restart Terminal:**
   Load updated configurations

### Troubleshooting Common Issues

**Homebrew not in PATH (macOS):**
```bash
# Apple Silicon
eval "$(/opt/homebrew/bin/brew shellenv)"
# Intel
eval "$(/usr/local/bin/brew shellenv)"
```

**Shell not found after installation:**
```bash
# Add shell to /etc/shells (Ubuntu/Debian)
sudo sh -c "echo $(which fish) >> /etc/shells"
sudo sh -c "echo $(which zsh) >> /etc/shells"
```

**Tools not working:**
```bash
# Reload configuration
source ~/.config/fish/config.fish  # Fish
source ~/.zshrc                    # Zsh
source ~/.bashrc                   # Bash
```

**Permission issues (Zsh):**
```bash
# Fix insecure directories
compaudit | xargs sudo chmod 755
```

**wt command not found:**
```bash
# wt is a Fish shell function - verify it's installed:
ls -la ~/.config/fish/functions/wt.fish

# If file exists, switch to Fish shell:
fish
wt help

# Or run from bash/zsh:
fish -c "wt help"

# If file doesn't exist, reinstall:
curl -sL https://raw.githubusercontent.com/roderik/wt/main/wt.fish > ~/.config/fish/functions/wt.fish
```

## Checking System Status

### Verify Tool Installation

**For regular tools:**
```bash
command -v <tool>  # Check if tool exists
which <tool>       # Show tool location
<tool> --version   # Check version
```

**For wt (Fish shell function):**
```bash
# Check if wt function file exists
ls -la ~/.config/fish/functions/wt.fish

# Test wt from Fish shell
fish -c "wt help"

# Or switch to Fish and test
fish
wt help
```

**Note:** `wt` is a Fish shell function installed at `~/.config/fish/functions/wt.fish`. It's only available in Fish shell, not in bash/zsh. Use `fish -c "wt <command>"` to run wt from other shells, or switch to Fish with `fish` command.

### Check Configurations
```bash
# Shell configs
ls ~/.config/fish/conf.d/
ls ~/.config/zsh/conf.d/
ls ~/.config/bash/conf.d/

# AI configs
ls ~/.claude/agents/
ls ~/.claude/commands/
ls ~/.codex/prompts/
ls ~/.gemini/

# Starship
bat ~/.config/starship.toml
```

### Environment Variables
```bash
# Fish
set -x | grep -i node
# Bash/Zsh
env | grep -i node
```

## Best Practices

### Installation Strategy

**Clean Machine:**
Run full installation script for automated setup.

**Partially Configured:**
Scripts detect existing installations and skip/update appropriately.

**Fully Configured:**
Use update script to refresh to latest versions.

### Shell Selection

**Fish Shell (Recommended):**
- Best autosuggestions and completions
- Modular conf.d/ structure
- Extensive abbreviations (60+ git shortcuts)
- Full wt integration

**Zsh:**
- Good plugin ecosystem
- Compatible with most scripts
- Modern features enabled

**Bash:**
- Universal compatibility
- Enhanced with modern features
- Good fallback option

### Tool Usage

**Prefer Modern Alternatives:**
- Use `bat` instead of `cat`
- Use `eza` instead of `ls`
- Use `rg` instead of `grep`
- Use `fd` instead of `find`
- Use `z` instead of `cd` for frequent directories

**Use ast-grep for Code Search:**
```bash
# TypeScript
ast-grep --lang ts -p 'function $NAME($$$) { $$$ }'

# React/TSX
ast-grep --lang tsx -p '<$COMP $$$>$$$</$COMP>'
```

**Leverage Git Worktrees:**
```bash
wt new feature-auth    # Create feature branch workspace
wt switch main         # Instantly switch to main
wt list                # See all workspaces
```

## Common Scenarios

### "What tools do I have available?"

Refer to `references/tools-reference.md` for comprehensive list organized by category:
- File operations
- Development tools
- Navigation & history
- Version managers
- System tools
- Cloud & infrastructure
- Blockchain development

### "How do I install this on a new machine?"

1. Identify OS (macOS or Ubuntu/Debian)
2. Run appropriate installation script
3. Restart terminal
4. Verify with: `fish`, `wt help`, check configs

### "How do I update everything?"

Run: `bash scripts/update-system.sh`
Then restart terminal.

### "Where is X configured?"

Common config locations:
- Shell: `~/.config/<shell>/`
- AI assistants: `~/.claude/`, `~/.codex/`, `~/.gemini/`
- Neovim: `~/.config/nvim/`
- Starship: `~/.config/starship.toml`
- Git worktrees: `~/.wt/`

### "Tool not working after installation"

**For most tools:**
1. Check if tool in PATH: `command -v <tool>`
2. Reload shell config: `source ~/.config/fish/config.fish`
3. Verify Homebrew: `brew list | grep <tool>`
4. Reinstall if needed: `brew reinstall <tool>`

**For wt specifically:**
1. Check if Fish function file exists: `ls ~/.config/fish/functions/wt.fish`
2. If file exists but command fails: Switch to Fish shell (`fish`) then run `wt help`
3. If running from bash/zsh: Use `fish -c "wt <command>"`
4. If file doesn't exist: Reinstall with `curl -sL https://raw.githubusercontent.com/roderik/wt/main/wt.fish > ~/.config/fish/functions/wt.fish`

**Note:** `wt` is **only available in Fish shell** - it won't work in bash or zsh directly.

### "How do I add an MCP server to all AI assistants?"

To maintain feature parity, add the same MCP server to all platforms:

1. Load `references/ai-config-schemas.md` for platform-specific formats
2. For each platform (Claude, Codex, Gemini, OpenCode):
   - Read current config file
   - Reference `assets/<platform>-*` template for format
   - Add server definition with same name and command
   - Adapt syntax to platform's format (JSON vs TOML, stdio vs local)
   - Validate syntax (jq for JSON, python for TOML)
3. Verify all 4 configs have the new server
4. Restart each AI assistant
5. Test server functionality on each platform

**Example - Adding "new-server" to all platforms:**
- Claude: Add to `mcpServers` object in `~/.claude/settings.json`
- Codex: Add `[mcp_servers.new_server]` section in `~/.codex/config.toml`
- Gemini: Add to `mcpServers` object in `~/.gemini/settings.json`
- OpenCode: Add to `mcp` object in `~/.config/opencode/opencode.json`

Keep command/args identical (e.g., `bun x -y package@latest`) across all platforms.

### "Config file syntax error after editing"

1. Identify file format (JSON or TOML)
2. Run validation:
   - JSON: `jq empty <file>`
   - TOML: `python3 -c "import tomllib; tomllib.load(open('<file>', 'rb'))"`
3. Common fixes:
   - Remove trailing commas (JSON)
   - Quote all keys properly
   - Check bracket/brace matching
   - Escape special characters in strings
4. Restore from backup if needed

## Resources

**⚠️ PRIMARY INSTRUCTION: ALWAYS START WITH OFFICIAL DOCUMENTATION**

Before using any information from this skill's resources:
1. Load `references/tools-reference.md` for official documentation URLs
2. Search online for the current official documentation
3. Verify all commands, flags, and configuration with official sources
4. Use this skill as a reference baseline only - official docs are source of truth

### scripts/
Installation and update automation:
- `install-macos.sh` - Complete macOS setup
- `install-ubuntu.sh` - Complete Ubuntu/Debian setup (apt-based)
- `update-system.sh` - Update all components

All scripts are idempotent (safe to run multiple times) and provide colored output with verification steps.

### assets/
Template configuration files for AI assistants:
- `claude-settings.json` - Claude Code configuration template
- `codex-config.toml` - Codex CLI configuration template
- `gemini-settings.json` - Gemini CLI configuration template
- `opencode-config.json` - OpenCode configuration template
- `README.md` - Documentation for config templates

Use assets when:
- Installing or updating AI assistant configurations
- Referencing correct config format
- Ensuring consistency across installations

**NOTE:** Template configs may be outdated. Check official documentation for current schema.

### references/
Comprehensive documentation:
- `tools-reference.md` - **START HERE** - Contains official documentation URLs for all tools, plus quick reference (always verify with official docs)
- `ai-config-schemas.md` - Detailed schemas and formats for AI assistant configuration files (Claude, Codex, Gemini, OpenCode), including MCP server patterns, validation commands, and merge strategies

**CRITICAL WORKFLOW:**
1. Load `references/tools-reference.md` FIRST
2. Find official documentation URL for the tool
3. Search online for current documentation
4. Provide commands based on official docs
5. Use reference material as supplement only

Load references when:
- Providing detailed tool information (AFTER checking official docs)
- Editing or validating AI assistant configuration files
- Adding/removing MCP servers or modifying environment variables
- Understanding config file structure and options

**REMEMBER:** This skill's information may be outdated. Official documentation online is always the authoritative source.
