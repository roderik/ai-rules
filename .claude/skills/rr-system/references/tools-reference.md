# System Tools Reference

## Modern CLI Tools (from shell-config)

### File Operations
- **bat** - Cat replacement with syntax highlighting
  - Usage: `bat file.txt`
  - Alias: `cat` → `bat`
- **eza** - Modern ls replacement
  - Usage: `eza -la`, `eza -T` (tree view)
  - Aliases: `ls`, `l`, `ll`, `la`, `lt`
- **fd** - Fast file finder
  - Usage: `fd pattern -t f` (files), `fd pattern -t d` (dirs)
  - Replaces: `find`
- **ripgrep (rg)** - Fast text search
  - Usage: `rg "pattern" -n`, `rg -i` (case-insensitive)
  - Alias: `grep` → `rg`

### Development Tools
- **neovim** - Modern Vim with LazyVim
  - Config: `~/.config/nvim/`
  - Theme: Catppuccin Macchiato
- **lazygit** - Terminal UI for git
  - Usage: `lazygit` or `lzg`
- **lazydocker** - Terminal UI for docker
  - Usage: `lazydocker` or `lzd`
- **fzf** - Fuzzy finder
  - Usage: `ff` (with preview), Ctrl+R (history), Ctrl+T (files)
- **ast-grep** - Structural code search
  - Usage: `ast-grep --lang ts -p 'pattern'`

### Navigation & History
- **zoxide** - Smarter cd
  - Usage: `z dirname`, `zi` (interactive)
- **atuin** - Shell history with sync
  - Usage: Automatic, Ctrl+R for search
- **direnv** - Per-project environment
  - Usage: Create `.envrc` in project root

### Version Managers
- **fnm** - Fast Node.js manager
  - Usage: `fnm install 20`, `fnm use 20`
- **uv** - Python project manager
  - Usage: `uv venv`, `uv pip install`

### System Tools
- **procs** - Modern ps
  - Usage: `procs`, `procs -A`
- **hexyl** - Hex viewer
  - Usage: `hexyl file` or `hex file`
- **broot** - Interactive tree
  - Usage: `broot` or `br`
- **git-delta** - Beautiful diffs
  - Configured automatically in git
- **difftastic** - Syntax-aware diffs
  - Usage: `git diff` (configured globally)

### Cloud & Infrastructure
- **kubectl** - Kubernetes CLI
  - Completions: Available in all shells
- **kubectx/kubens** - Context/namespace switcher
  - Usage: `kubectx`, `kubens`
- **helm** - Kubernetes package manager
  - Completions: Available in all shells
- **gh** - GitHub CLI
  - Usage: `gh pr create`, `gh pr view`
- **aws-cli** - AWS CLI
  - Usage: `aws s3 ls`
- **azure-cli** - Azure CLI
  - Usage: `az login`
- **gcloud** - Google Cloud CLI
  - Usage: `gcloud init`

### Blockchain Development
- **foundry** - Ethereum development toolkit
  - Tools: `forge`, `cast`, `anvil`, `chisel`
  - Usage: `forge init`, `forge test`, `cast call`

### Terminal Multiplexers
- **tmux** - Terminal multiplexer
  - Many `tm*` aliases available
- **zellij** - Modern terminal workspace
  - Usage: `zellij`

### Other Tools
- **1password-cli** - 1Password integration
  - Usage: `op item list`
- **shellcheck** - Shell script linter
  - Usage: `shellcheck script.sh`

## Shell Configuration

### Fish Shell
- Config: `~/.config/fish/config.fish`
- Modular config: `~/.config/fish/conf.d/`
- Functions: `~/.config/fish/functions/`
- Features: Autosuggestions, syntax highlighting, smart completions

### Zsh
- Config: `~/.zshrc`
- Modular config: `~/.config/zsh/conf.d/`
- Plugins: zsh-syntax-highlighting, zsh-autosuggestions, zsh-completions

### Bash
- Config: `~/.bashrc`, `~/.bash_profile`
- Modular config: `~/.config/bash/conf.d/`
- Modern features enabled

### Starship Prompt
- Config: `~/.config/starship.toml`
- Theme: Catppuccin Macchiato
- Features: Git status, language versions, execution time

## AI Assistant Configuration (ai-rules)

### Claude Code
- Config: `~/.claude/settings.json`
- Agents: `~/.claude/agents/`
- Commands: `~/.claude/commands/`
- Hooks: `~/.claude/hooks/`
- MCP Servers: `~/.claude/mcp/`

### Codex CLI
- Config: `~/.codex/config.toml`
- Prompts: `~/.codex/prompts/`
- Agent instructions: `~/.codex/AGENTS.md`

### Gemini CLI
- Config: `~/.gemini/settings.json`
- Commands: `~/.gemini/commands.toml`
- Agent instructions: `~/.gemini/AGENTS.md`

### MCP Servers
- **linear** - Linear issue tracking
- **context7** - Library documentation
- **octocode** - GitHub code exploration
- **sentry** - Error tracking
- **playwright** - Browser automation

## Git Worktree Manager (wt)

### Commands
- `wt new <branch>` - Create worktree
- `wt switch <branch>` - Switch to worktree
- `wt list` - List all worktrees
- `wt remove <branch>` - Remove worktree
- `wt clean [--all]` - Clean up worktrees
- `wt help` - Show help

### Features
- Auto package manager detection (Bun/NPM/Yarn/PNPM)
- Organized storage in `~/.wt/<repo>/`
- Tab completion support
- Editor integration (--claude, --cursor, --all)

### Directory Structure
```
~/.wt/
└── <repo-name>/
    ├── feature-branch/
    ├── bugfix-branch/
    └── experiment-branch/
```

## Environment Variables

### Development
- `NODE_NO_WARNINGS=1` - Suppress Node warnings
- `EDITOR=nvim` - Default editor
- `VISUAL=nvim` - Visual editor

### Claude Code
- `FORCE_AUTO_BACKGROUND_TASKS=1` - Enable background tasks
- `ENABLE_BACKGROUND_TASKS=1` - Enable task execution
- `CLAUDE_CODE_ENABLE_UNIFIED_READ_TOOL=1` - Unified read tool
- `MAX_THINKING_TOKENS=32768` - Extended thinking tokens
- `BASH_MAX_TIMEOUT_MS=600000` - Extended bash timeout

## Keyboard Shortcuts

### Fish Shell
- Ctrl+R - Atuin history search
- Ctrl+T - FZF file search
- Ctrl+Alt+F - FZF directory search

### Git Abbreviations (Fish)
- `g` → `git`
- `ga` → `git add`
- `gc` → `git commit`
- `gp` → `git push`
- `gl` → `git pull`
- `gs` → `git status`
- `gco` → `git checkout`

60+ git abbreviations available in Fish shell.
