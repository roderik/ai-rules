# Assets Directory

This directory contains configuration templates and package definitions for the rr-system skill.

## Contents

### Brewfile (Shared CLI Tools)
**Purpose:** Cross-platform CLI development tools

**Usage:**
```bash
# Install shared CLI tools only
brew bundle --file=Brewfile

# Install everything (uses install-tools.sh for both files)
bash ../scripts/install-tools.sh
```

**Includes:**
- Shells: Fish, Zsh, Bash
- Modern CLI tools: bat, eza, fd, ripgrep, fzf, zoxide, atuin, jq, yq, btop
- Development tools: git, neovim, node, go, python, fnm, mkcert
- Cloud CLIs: AWS, Azure, GCloud, kubectl, helm, k9s
- Terminal tools: tmux, zellij, lazygit, lazydocker
- AI CLI tools: gemini-cli, opencode

### Brewfile.macos (macOS-Only Applications)
**Purpose:** GUI applications and macOS-specific tools

**Usage:**
```bash
# Install macOS apps only
brew bundle --file=Brewfile.macos

# Install everything (recommended)
bash ../scripts/install-tools.sh
```

**Includes:**
- Password & Security: 1Password, 1Password CLI
- Communication: Slack, Zoom, Linear
- Development: Cursor, Ghostty, Tower
- AI Assistants: Claude, ChatGPT, Codex, Claude Code
- Productivity: Raycast, Granola, Shottr
- Cloud SDKs: Google Cloud SDK

### ai-configs/
**Purpose:** AI assistant configuration templates

**Contents:**
- `claude-settings.json` - Claude Code configuration
- `codex-config.toml` - Codex CLI configuration
- `gemini-settings.json` - Gemini CLI configuration
- `opencode-config.json` - OpenCode configuration
- `README.md` - Detailed documentation

**Usage:**
```bash
bash ../scripts/install-ai-configs.sh
```

### shell-config/
**Purpose:** Shell configuration files for Fish, Zsh, Bash, Starship, and Ghostty

**Contents:**
- `fish/` - Fish shell (config.fish + conf.d modules + functions/wt.fish)
- `zsh/` - Zsh (.zshrc + conf.d modules)
- `bash/` - Bash (.bashrc, .bash_profile + conf.d modules)
- `starship/` - Starship prompt configuration
- `ghostty/` - Ghostty terminal configuration
- `README.md` - Detailed documentation

**Usage:**
```bash
bash ../scripts/install-shell-config.sh
```

## Installation Order

For a fresh machine setup, install in this order:

1. **Tools First:**
   ```bash
   bash scripts/install-tools.sh
   ```
   Installs Homebrew and all development tools.

2. **Shell Configs Second:**
   ```bash
   bash scripts/install-shell-config.sh
   ```
   Installs shell configurations that use the tools.

3. **AI Configs Third:**
   ```bash
   bash scripts/install-ai-configs.sh
   ```
   Installs AI assistant configurations.

4. **Restart Terminal:**
   Load all new tools and configurations.

## Customization

### Adding Tools

**For shared CLI tools**, edit `Brewfile`:
```ruby
brew "tool-name"          # For CLI tools
tap "user/repo"           # For custom taps
```

**For macOS-only GUI apps**, edit `Brewfile.macos`:
```ruby
cask "app-name"           # For macOS GUI applications
```

Then run: `bash scripts/install-tools.sh`

### Modifying Shell Configs
Edit files in `shell-config/` directories, then run:
```bash
bash scripts/install-shell-config.sh
```

### Modifying AI Configs
Edit files in `ai-configs/`, then run:
```bash
bash scripts/install-ai-configs.sh
```

## Maintenance

**Update Everything:**
```bash
bash scripts/install-tools.sh       # Updates all Homebrew packages
bash scripts/install-shell-config.sh  # Overwrites shell configs
bash scripts/install-ai-configs.sh    # Overwrites AI configs
```

All scripts are idempotent and safe to run multiple times.
