# System Installation Guide

Complete installation and setup instructions for the rr- development environment.

## Prerequisites

- macOS or Ubuntu/Debian Linux
- Internet connection
- Terminal access
- Sudo privileges (for shell registration and system configurations)

## Installation Overview

The system uses automated scripts for zero-interaction installation:

1. **install-tools.sh** - Installs Homebrew and all development tools
2. **brew upgrade** - Upgrades all packages to latest versions (MANDATORY)
3. **install-shell-config.sh** - Installs Fish/Zsh/Bash configurations
4. **install-ai-configs.sh** - Installs AI assistant configurations

All scripts are idempotent (safe to run multiple times) and include verification.

## Step-by-Step Installation

### Step 1: Install Development Tools

```bash
cd .claude/skills/rr-system
bash scripts/install-tools.sh
```

**What this does:**

- Installs Homebrew (if not present, works on macOS and Linux)
- Installs all CLI tools from `Brewfile` (cross-platform)
- Installs macOS apps from `Brewfile.macos` (macOS only, auto-skipped on Linux)
- Configures git, atuin, shell completions
- Verifies all critical tools are working

**Brewfile Structure:**

- `Brewfile` - Cross-platform CLI tools (works on macOS and Linux)
  - Shells (Fish, Zsh, Bash)
  - Modern CLI tools (bat, eza, fd, ripgrep, fzf, jq, yq, btop)
  - Development tools (git, neovim, node, go, python, mkcert)
  - Cloud CLIs (AWS, Azure, GCloud, kubectl, helm, k9s)
  - Terminal tools (tmux, zellij, lazygit, lazydocker)
  - AI CLI tools (gemini-cli, opencode)

- `Brewfile.macos` - macOS-only GUI applications
  - Password & Security (1Password, 1Password CLI)
  - Communication (Slack, Zoom, Linear)
  - Development (Cursor, Ghostty, Tower)
  - AI Assistants (Claude, ChatGPT, Codex, Claude Code)
  - Productivity (Raycast, Granola, Shottr)
  - Cloud SDKs (Google Cloud SDK)

**Verification:**
Script automatically verifies core tools (fish, zsh, bash, bat, eza, fd, rg, fzf, jq, yq, git, gh) and warns about optional tools (node, go, python3, kubectl, helm).

### Step 2: Upgrade All Homebrew Packages

```bash
brew upgrade
```

**MANDATORY STEP:** After installing Homebrew and tools, upgrade all packages to latest versions. This ensures you have the most recent versions with security patches and features.

### Step 3: Install Shell Configurations

```bash
bash scripts/install-shell-config.sh
```

**What this does:**

- Installs Fish shell configuration (config.fish + conf.d modules + wt function)
- Installs Zsh configuration (.zshrc + conf.d modules)
- Installs Bash configuration (.bashrc, .bash_profile + conf.d modules)
- Installs Starship prompt configuration
- Installs Ghostty terminal configuration (macOS only)
- Registers Fish/Zsh in /etc/shells (requires sudo)
- Fixes Zsh completion directory permissions (requires sudo)
- Enables Touch ID for sudo (macOS only, requires sudo)
- Verifies all config files exist and are valid

**Verification:**
Script checks all config files, shell functions (including wt), and configurations are properly installed.

### Step 4: Install AI Configurations

```bash
bash scripts/install-ai-configs.sh
```

**What this does:**

- Installs Claude Code settings
- Installs Codex CLI config
- Installs Gemini CLI settings
- Installs OpenCode config
- Validates all JSON/TOML syntax
- Creates necessary directories
- Overwrites existing configs with latest templates

**Verification:**
Script validates JSON and TOML syntax for all configuration files.

### Step 5: Post-Installation

```bash
# Restart terminal to load new tools and configs
# Then start Fish shell
fish

# Optional: Make Fish your default shell
chsh -s $(which fish)
```

### Step 6: Verify Installation

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

# Check wt (Fish shell function)
ls ~/.config/fish/functions/wt.fish
fish -c "wt help"
```

## Updating Existing Installation

### Update Workflow

**CRITICAL: Always run `brew upgrade` first:**

```bash
# Step 1: Upgrade all Homebrew packages (MANDATORY FIRST STEP)
brew upgrade

# Step 2: Update development tools
bash scripts/install-tools.sh

# Step 3: Update shell configurations
bash scripts/install-shell-config.sh

# Step 4: Update AI configurations
bash scripts/install-ai-configs.sh

# Step 5: Restart terminal
# Load updated configurations
```

### Adding New Tools

**To add CLI tools:**

1. Edit `Brewfile`
2. Add line: `brew "tool-name"`
3. Run: `bash scripts/install-tools.sh`

**To add macOS apps:**

1. Edit `Brewfile.macos`
2. Add line: `cask "app-name"`
3. Run: `bash scripts/install-tools.sh`

## Verification and Success Checks

### install-tools.sh Verification

**Core tools (must pass):**

- fish, zsh, bash
- bat, eza, fd, rg (ripgrep), fzf
- jq, yq
- git, gh

**Development tools (warnings only):**

- node, go, python3, neovim

**Cloud tools (warnings only):**

- kubectl, helm, awscli

### install-shell-config.sh Verification

**Fish:**

- config.fish
- conf.d/ modules
- functions/wt.fish

**Zsh:**

- .zshrc
- conf.d/ modules

**Bash:**

- .bashrc
- .bash_profile
- conf.d/ modules

**Other:**

- Starship configuration
- Ghostty configuration

### install-ai-configs.sh Verification

**Claude Code:**

- settings.json (validates JSON syntax)

**Codex CLI:**

- config.toml (validates TOML syntax)

**Gemini CLI:**

- settings.json (validates JSON syntax)

**OpenCode:**

- opencode.json (validates JSON syntax)

### Success Indicators

All verifications report:

- ✓ Success with green checkmarks
- ✗ Errors with red X marks
- ⚠ Warnings with yellow warning symbols
- Total check count and error summary

## Troubleshooting

### Homebrew Issues

**Homebrew not in PATH (macOS):**

```bash
# Apple Silicon
eval "$(/opt/homebrew/bin/brew shellenv)"

# Intel
eval "$(/usr/local/bin/brew shellenv)"
```

**Homebrew installation failed:**

```bash
# Check system requirements
uname -a

# Try manual install
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
```

### Shell Issues

**Shell not found after installation:**

```bash
# Add shell to /etc/shells (requires sudo)
sudo sh -c "echo $(which fish) >> /etc/shells"
sudo sh -c "echo $(which zsh) >> /etc/shells"
```

**Configuration not loading:**

```bash
# Reload configuration
source ~/.config/fish/config.fish  # Fish
source ~/.zshrc                    # Zsh
source ~/.bashrc                   # Bash

# Check file exists
ls -la ~/.config/fish/config.fish
```

**Permission issues (Zsh):**

```bash
# Fix insecure directories
compaudit | xargs sudo chmod 755

# Or use install script (includes this fix)
bash scripts/install-shell-config.sh
```

### Tool Issues

**Tool not working after installation:**

```bash
# Check if tool in PATH
command -v <tool>
which <tool>

# Check tool installed via Homebrew
brew list | grep <tool>

# Reinstall if needed
brew reinstall <tool>

# Reload shell config
source ~/.config/fish/config.fish
```

**Tool commands not recognized:**

```bash
# Ensure Homebrew in PATH
echo $PATH | grep homebrew

# Add to current session (macOS Apple Silicon)
eval "$(/opt/homebrew/bin/brew shellenv)"

# Restart terminal
```

### wt Issues

**wt command not found:**

```bash
# Check if Fish function file exists
ls -la ~/.config/fish/functions/wt.fish

# If file exists, switch to Fish shell
fish
wt help

# Or run from bash/zsh
fish -c "wt help"

# If file doesn't exist, reinstall shell configs
bash scripts/install-shell-config.sh
```

**wt only works in Fish:**

`wt` is a Fish shell function, not a standalone binary. It's only available in Fish shell.

**To use wt:**

- From Fish: `wt help`
- From bash/zsh: `fish -c "wt help"`
- Or switch to Fish: `fish`

### AI Configuration Issues

**Config file syntax error:**

```bash
# Validate JSON
jq empty ~/.claude/settings.json
jq empty ~/.gemini/settings.json
jq empty ~/.config/opencode/opencode.json

# Validate TOML
python3 -c "import tomllib; tomllib.load(open('~/.codex/config.toml', 'rb'))"
```

**Common JSON/TOML errors:**

- Trailing commas in JSON
- Missing quotes around keys
- Mismatched brackets/braces
- Unescaped special characters in strings

**Config file missing:**

```bash
# Reinstall AI configs
bash scripts/install-ai-configs.sh

# Verify directories exist
ls -la ~/.claude/
ls -la ~/.codex/
ls -la ~/.gemini/
ls -la ~/.config/opencode/
```

**AI assistant not loading config:**

1. Validate syntax (see above)
2. Check file permissions: `ls -la ~/.claude/settings.json`
3. Restart AI assistant
4. Check AI assistant logs for errors

## Configuration Locations

### Shell Configurations

- Fish: `~/.config/fish/` (config.fish + conf.d/)
- Zsh: `~/.zshrc` + `~/.config/zsh/conf.d/`
- Bash: `~/.bashrc`, `~/.bash_profile` + `~/.config/bash/conf.d/`
- Starship: `~/.config/starship.toml`
- Ghostty: `~/.config/ghostty/config` (macOS only)

### AI Assistant Configurations

- Claude Code: `~/.claude/settings.json`
- Codex CLI: `~/.codex/config.toml`
- Gemini CLI: `~/.gemini/settings.json`
- OpenCode: `~/.config/opencode/opencode.json`

### Tool Configurations

- Neovim: `~/.config/nvim/` (LazyVim with Catppuccin)
- Git: `~/.gitconfig`
- Git worktrees: `~/.wt/`

## Best Practices

### Installation Strategy

**Clean Machine:**

- Run full installation scripts in order
- Always run `brew upgrade` after installing Homebrew
- Restart terminal after installation

**Partially Configured:**

- Scripts detect existing installations
- Safe to run - will update/overwrite configs
- Use for updating to latest versions

**Fully Configured:**

- Run `brew upgrade` first (MANDATORY)
- Then run installation scripts to refresh configs
- Restart terminal to load updates

### Shell Selection

**Fish Shell (Recommended):**

- Best autosuggestions and completions
- Modular conf.d/ structure
- 60+ git abbreviations
- Full wt integration
- Modern, user-friendly syntax

**Zsh:**

- Good plugin ecosystem
- Compatible with most scripts
- Modern features enabled
- Bash-compatible with enhancements

**Bash:**

- Universal compatibility
- Enhanced with modern features
- Good fallback option
- Ubiquitous on Unix systems

### Tool Usage

**Prefer Modern Alternatives:**

- `bat` instead of `cat`
- `eza` instead of `ls`
- `rg` instead of `grep`
- `fd` instead of `find`
- `z` instead of `cd` for frequent directories

**Use Git Worktrees (wt):**

- Create isolated branch workspaces
- Instant switching between branches
- No stashing required
- Automatic package manager detection

## Common Installation Scenarios

### Fresh macOS Setup

```bash
# 1. Clone ai-rules repository
git clone <repo-url>
cd ai-rules/.claude/skills/rr-system

# 2. Install development tools (includes Homebrew)
bash scripts/install-tools.sh

# 3. Upgrade all packages (MANDATORY)
brew upgrade

# 4. Install shell configs
bash scripts/install-shell-config.sh

# 5. Install AI configs
bash scripts/install-ai-configs.sh

# 6. Restart terminal and verify
fish
bat --version
wt help
```

### Fresh Linux Setup

```bash
# Same as macOS, but:
# - Brewfile.macos automatically skipped
# - No Ghostty terminal config
# - No Touch ID configuration
# - All CLI tools work normally

# Follow same steps as macOS
```

### Update Existing Installation

```bash
cd ai-rules/.claude/skills/rr-system

# ALWAYS upgrade Homebrew packages first
brew upgrade

# Then run installation scripts
bash scripts/install-tools.sh
bash scripts/install-shell-config.sh
bash scripts/install-ai-configs.sh

# Restart terminal
```

### Installing on Multiple Machines

1. Use git to sync ai-rules repository across machines
2. Run installation scripts on each machine
3. Configs will be consistent across all machines
4. Platform-specific differences handled automatically

### Selective Installation

**Only CLI tools:**

```bash
bash scripts/install-tools.sh
brew upgrade
```

**Only shell configs:**

```bash
bash scripts/install-shell-config.sh
```

**Only AI configs:**

```bash
bash scripts/install-ai-configs.sh
```
