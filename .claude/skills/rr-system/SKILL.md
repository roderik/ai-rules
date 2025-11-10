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

### 1. Complete System Setup (3-Step Installation)

Install complete development environment on **macOS or Linux** using three automated scripts:

**Step 1: Install Development Tools**

```bash
bash scripts/install-tools.sh
```

Installs and verifies:
- Homebrew (if not present, works on macOS and Linux)
- All CLI tools from `Brewfile` (cross-platform, works on macOS and Linux)
- All macOS apps from `Brewfile.macos` (GUI applications, macOS only - automatically skipped on Linux)
- Configures git, atuin, and shell completions
- **Verification:** Checks all critical tools are present and working
- **Linux support:** Shared CLI tools work on Linux; macOS-only apps are automatically skipped

**Step 2: Install Shell Configurations**

```bash
bash scripts/install-shell-config.sh
```

Installs and verifies:
- Fish shell (config.fish + conf.d modules + wt function)
- Zsh (.zshrc + conf.d modules)
- Bash (.bashrc, .bash_profile + conf.d modules)
- Starship prompt configuration
- Ghostty terminal configuration (macOS only)
- **System configuration:**
  - Registers Fish/Zsh in /etc/shells (requires sudo)
  - Fixes Zsh completion directory permissions (requires sudo)
  - Enables Touch ID for sudo (macOS only, requires sudo)
- **Verification:** Confirms all config files exist and are valid

**Step 3: Install AI Configurations**

```bash
bash scripts/install-ai-configs.sh
```

Installs and verifies:
- Claude Code settings
- Codex CLI config
- Gemini CLI settings
- OpenCode config
- **Verification:** Validates all JSON/TOML syntax and file presence

All scripts run with **zero interaction** (no prompts, no backups) and include automatic verification to ensure successful installation. Some steps require `sudo` password (shell registration, permission fixes, Touch ID configuration).

### 2. Brewfile Structure

The system uses **two Brewfiles** for organized package management:

**`Brewfile` - Shared CLI Tools (macOS & Linux):**
Cross-platform command-line tools that work on macOS and Linux via Homebrew:
- Shells (Fish, Zsh, Bash)
- Modern CLI tools (bat, eza, fd, ripgrep, fzf, jq, yq, btop)
- Development tools (git, neovim, node, go, python, mkcert)
- Cloud CLIs (AWS, Azure, GCloud, kubectl, helm, k9s)
- Terminal tools (tmux, zellij, lazygit, lazydocker)
- AI CLI tools (gemini-cli, opencode)

**`Brewfile.macos` - macOS-Only Applications:**
GUI applications and macOS-specific tools:
- Password & Security (1Password, 1Password CLI)
- Communication (Slack, Zoom, Linear)
- Development (Cursor, Ghostty, Tower)
- AI Assistants (Claude, ChatGPT, Codex, Claude Code)
- Productivity (Raycast, Granola, Shottr)
- Cloud SDKs (Google Cloud SDK)

**Adding Tools:**
- Edit `Brewfile` for CLI tools: `brew "tool-name"`
- Edit `Brewfile.macos` for macOS apps: `cask "app-name"`
- Run `bash scripts/install-tools.sh` to install

### 3. Verification and Success Checks

All installation scripts include built-in verification:

**install-tools.sh verifies:**
- Core tools (fish, zsh, bash, bat, eza, fd, rg, fzf, jq, yq, git, gh)
- Development tools (node, go, python3, neovim) - warnings only
- Cloud tools (kubectl, helm, awscli) - warnings only

**install-shell-config.sh verifies:**
- Fish config.fish and conf.d modules
- Fish wt.fish function
- Zsh .zshrc and conf.d modules
- Bash .bashrc, .bash_profile, and conf.d modules
- Starship configuration
- Ghostty configuration

**install-ai-configs.sh verifies:**
- Claude Code settings.json (validates JSON)
- Codex config.toml (validates TOML)
- Gemini settings.json (validates JSON)
- OpenCode opencode.json (validates JSON)

All verifications report:
- ✓ Success with green checkmarks
- ✗ Errors with red X marks
- ⚠ Warnings with yellow warning symbols
- Total check count and error summary

### 4. AI Configuration Management

Manage AI assistant configuration files using automated installation or manual editing.

**Supported AI Assistants:**

- Claude Code (`~/.claude/settings.json`)
- Codex CLI (`~/.codex/config.toml`)
- Gemini CLI (`~/.gemini/settings.json`)
- OpenCode (`~/.config/opencode/opencode.json`)

**Quick Install (Recommended):**

Install all AI configurations automatically from the latest templates:

```bash
# Install configurations (overwrites existing configs)
bash scripts/install-ai-configs.sh
```

The script:

- Validates all configuration files (JSON and TOML syntax)
- Creates necessary directories
- Overwrites existing configs with latest from `assets/ai-configs/`
- Provides clear feedback and error messages

**Template Configurations:**

Template config files available in `assets/ai-configs/`:

- `claude-settings.json` - Claude Code configuration
- `codex-config.toml` - Codex CLI configuration
- `gemini-settings.json` - Gemini CLI configuration
- `opencode-config.json` - OpenCode configuration

Use the installation script for automated setup, or reference these templates for manual configuration.

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
2. Reference template: `assets/ai-configs/claude-settings.json` for format
3. Identify `mcpServers` section
4. Add new server entry with proper format
5. Validate JSON: `jq empty ~/.claude/settings.json`
6. Test: Restart Claude Code and verify server loads

**Workflow Example - Install/Update Config:**

1. Read template from `assets/ai-configs/<platform>-<config-name>`
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

### 5. Tool Reference

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
- Linting: actionlint (GitHub Actions), shellcheck (shell scripts)
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

- **Installation:** Included in Fish shell configuration (automatically installed via `install-shell-config.sh`)
- **Location:** `~/.config/fish/functions/wt.fish`
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

**Modern Approach (Recommended):**

1. **Install Development Tools:**

   ```bash
   cd .claude/skills/rr-system
   bash scripts/install-tools.sh
   ```

   This installs Homebrew (if needed) and all development tools via Brewfile.

2. **Install Shell Configurations:**

   ```bash
   bash scripts/install-shell-config.sh
   ```

   This installs Fish, Zsh, Bash configs with wt git worktree manager.

3. **Install AI Assistant Configurations:**

   ```bash
   bash scripts/install-ai-configs.sh
   ```

   This installs Claude, Codex, Gemini, OpenCode configurations.

4. **Post-Installation:**
   - Restart terminal to load new tools and configs
   - Run: `fish` (start Fish shell)
   - Optional: `chsh -s $(which fish)` (make Fish default)

5. **Verify Installation:**

   ```bash
   # Check tools installed
   bat --version
   eza --version
   fish --version

   # Check shell configs exist
   ls ~/.config/fish/config.fish
   ls ~/.zshrc
   ls ~/.config/starship.toml

   # Check AI configs exist
   ls ~/.claude/settings.json
   ls ~/.codex/config.toml
   ```

**Legacy Approach:**

- macOS: `install-macos.sh` (comprehensive but being phased out)
- Ubuntu/Debian: `install-ubuntu.sh` (comprehensive but being phased out)

### Updating Existing Installation

1. **Update Development Tools:**

   ```bash
   bash scripts/install-tools.sh
   ```

   Updates Homebrew and reinstalls/upgrades all tools.

2. **Update Shell Configurations:**

   ```bash
   bash scripts/install-shell-config.sh
   ```

   Overwrites shell configs with latest versions.

3. **Update AI Configurations:**

   ```bash
   bash scripts/install-ai-configs.sh
   ```

   Overwrites AI configs with latest versions.

4. **Restart Terminal:**
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

# If file doesn't exist, reinstall shell configs:
bash .claude/skills/rr-system/scripts/install-shell-config.sh
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

1. Clone the ai-rules repository
2. Run three scripts in order:
   - `bash scripts/install-tools.sh` (installs all tools)
   - `bash scripts/install-shell-config.sh` (installs shell configs)
   - `bash scripts/install-ai-configs.sh` (installs AI configs)
3. Restart terminal
4. Verify with: `bat --version`, `fish`, `wt help`

### "How do I update everything?"

Run all three scripts in order:

```bash
bash scripts/install-tools.sh       # Update all Homebrew tools
bash scripts/install-shell-config.sh  # Update shell configs
bash scripts/install-ai-configs.sh    # Update AI configs
```

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
4. If file doesn't exist: Reinstall shell configs with `bash .claude/skills/rr-system/scripts/install-shell-config.sh`

**Note:** `wt` is **only available in Fish shell** - it won't work in bash or zsh directly.

### "How do I add an MCP server to all AI assistants?"

To maintain feature parity, add the same MCP server to all platforms:

1. Load `references/ai-config-schemas.md` for platform-specific formats
2. For each platform (Claude, Codex, Gemini, OpenCode):
   - Read current config file
   - Reference `assets/ai-configs/<platform>-*` template for format
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

Installation and automation:

- `install-tools.sh` - Install all development tools via Homebrew (uses Brewfile)
- `install-shell-config.sh` - Install shell configurations (Fish, Zsh, Bash, Starship, Ghostty)
- `install-ai-configs.sh` - Install/update AI assistant configurations from templates
- `install-macos.sh` - Complete macOS setup (legacy, being phased out)
- `install-ubuntu.sh` - Complete Ubuntu/Debian setup (legacy, being phased out)

All scripts are idempotent (safe to run multiple times) and provide colored output with verification steps.

### assets/

Contains configuration templates and package lists organized by purpose:

#### assets/Brewfile

Homebrew package list for all development tools:

- Shells (Fish, Zsh, Bash)
- Modern CLI tools (bat, eza, fd, ripgrep, fzf, etc.)
- Development tools (git, neovim, node, etc.)
- Cloud CLIs (AWS, Azure, GCloud, kubectl, helm)
- Terminal tools (tmux, zellij, lazygit, lazydocker)
- AI tools (codex, claude, cursor)
- Cask applications (1Password, ChatGPT, Cursor, etc.)

Install all tools with: `brew bundle --file=assets/Brewfile`

#### assets/ai-configs/

AI assistant configuration files:

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

#### assets/shell-config/

Shell configuration files for Fish, Zsh, Bash, Starship, and Ghostty:

- `fish/` - Fish shell configuration (config.fish + conf.d modules + functions/wt.fish)
- `zsh/` - Zsh configuration (.zshrc + conf.d modules)
- `bash/` - Bash configuration (.bashrc, .bash_profile + conf.d modules)
- `starship/` - Starship prompt configuration
- `ghostty/` - Ghostty terminal configuration

Use the `install-shell-config.sh` script for automated installation. The script automatically installs the wt git worktree manager for Fish shell.

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
