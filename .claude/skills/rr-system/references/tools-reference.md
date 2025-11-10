# System Tools Reference

**⚠️ CRITICAL: ALWAYS VERIFY WITH OFFICIAL DOCUMENTATION**

This reference provides an overview of installed tools. Before providing usage instructions or configuration advice:

1. **Search for the official documentation** of the specific tool online
2. **Verify the exact CLI flags and options** - tools update frequently
3. **Check GitHub repositories** for the latest examples and best practices
4. **Confirm compatibility** with the user's installed version

## Official Documentation Links

**ALWAYS consult these official sources before providing specific commands or configuration:**

### File Operations & Core Tools

- **bat**: https://github.com/sharkdp/bat
- **eza**: https://eza.rocks/ | https://github.com/eza-community/eza
- **fd**: https://github.com/sharkdp/fd
- **ripgrep (rg)**: https://github.com/BurntSushi/ripgrep

### Development & Editors

- **neovim**: https://neovim.io/doc/ | https://github.com/neovim/neovim
- **LazyVim**: https://www.lazyvim.org/ | https://github.com/LazyVim/LazyVim
- **lazygit**: https://github.com/jesseduffield/lazygit
- **lazydocker**: https://github.com/jesseduffield/lazydocker
- **fzf**: https://github.com/junegunn/fzf
- **ast-grep**: https://ast-grep.github.io/ | https://github.com/ast-grep/ast-grep

### Linting & Code Quality

- **actionlint**: https://github.com/rhysd/actionlint
- **shellcheck**: https://www.shellcheck.net/ | https://github.com/koalaman/shellcheck

### Navigation & Shell Enhancement

- **zoxide**: https://github.com/ajeetdsouza/zoxide
- **atuin**: https://atuin.sh/ | https://github.com/atuinsh/atuin
- **direnv**: https://direnv.net/ | https://github.com/direnv/direnv
- **starship**: https://starship.rs/ | https://github.com/starship/starship
- **Fish shell**: https://fishshell.com/docs/current/
- **Zsh**: https://zsh.sourceforge.io/Doc/

### Version Managers

- **fnm**: https://github.com/Schniz/fnm
- **uv**: https://docs.astral.sh/uv/ | https://github.com/astral-sh/uv

### System Tools

- **procs**: https://github.com/dalance/procs
- **hexyl**: https://github.com/sharkdp/hexyl
- **broot**: https://dystroy.org/broot/ | https://github.com/Canop/broot
- **git-delta**: https://github.com/dandavison/delta
- **difftastic**: https://difftastic.wilfred.me.uk/ | https://github.com/Wilfred/difftastic

### Cloud & Infrastructure

- **kubectl**: https://kubernetes.io/docs/reference/kubectl/
- **kubectx/kubens**: https://github.com/ahmetb/kubectx
- **helm**: https://helm.sh/docs/
- **gh (GitHub CLI)**: https://cli.github.com/manual/
- **aws-cli**: https://docs.aws.amazon.com/cli/
- **azure-cli**: https://learn.microsoft.com/en-us/cli/azure/
- **gcloud**: https://cloud.google.com/sdk/gcloud

### Blockchain Development

- **Foundry**: https://book.getfoundry.sh/ | https://github.com/foundry-rs/foundry
  - **forge**: https://book.getfoundry.sh/forge/
  - **cast**: https://book.getfoundry.sh/cast/
  - **anvil**: https://book.getfoundry.sh/anvil/
  - **chisel**: https://book.getfoundry.sh/chisel/

### Terminal & Session

- **tmux**: https://github.com/tmux/tmux/wiki
- **zellij**: https://zellij.dev/ | https://github.com/zellij-org/zellij

### Package Managers & Runtime

- **Homebrew**: https://docs.brew.sh/
- **Bun**: https://bun.sh/docs

### Git Worktree Management

- **wt**: https://github.com/roderik/wt (Fish shell function)

### AI Assistant CLIs

- **Claude Code**: https://docs.claude.com/en/docs/claude-code
- **OpenCode**: https://opencode.ai/ | https://docs.opencode.ai/
- **Codex**: https://codex.google/docs
- **Gemini CLI**: https://ai.google.dev/gemini-api/docs

### OpenSkills

- **openskills**: https://github.com/numman-ali/openskills

---

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

### Linting & Code Quality

- **actionlint** - GitHub Actions workflow linter
  - Usage: `actionlint` (lint all workflows)
  - Usage: `actionlint .github/workflows/ci.yml` (specific file)
  - Usage: `actionlint -verbose` (detailed output)
  - Detects: Invalid actions, deprecated syntax, shell errors, security issues
- **shellcheck** - Shell script linter
  - Usage: `shellcheck script.sh`
  - Usage: `shellcheck -x script.sh` (follow sourced files)

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
