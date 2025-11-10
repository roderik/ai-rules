# Shell Configuration Templates

This directory contains shell configuration files for Fish, Zsh, Bash, Starship prompt, and Ghostty terminal.

## Quick Start

Install all shell configurations automatically:

```bash
# From the ai-rules repository
cd .claude/skills/rr-system

# Install configurations (overwrites existing)
bash scripts/install-shell-config.sh
```

## Configuration Files

### Fish Shell
- **Files:** `fish/config.fish` + `fish/conf.d/*.fish` + `fish/functions/wt.fish`
- **Target:** `~/.config/fish/`
- **Features:**
  - Modular conf.d structure for easy management
  - 60+ git abbreviations
  - Modern tool integrations (zoxide, fzf, atuin)
  - Cloud CLI integrations (AWS, Azure, GCloud, Kubernetes)
  - Function library for common tasks
  - **wt (git worktree manager)** - Included as a Fish function for parallel development workflows

### Zsh
- **Files:** `zsh/.zshrc` + `zsh/conf.d/*.zsh`
- **Target:** `~/.zshrc` + `~/.config/zsh/conf.d/`
- **Features:**
  - Plugin support (syntax highlighting, autosuggestions)
  - Modular conf.d structure
  - Modern tool integrations
  - Custom keybindings
  - Extensive completion system

### Bash
- **Files:** `bash/.bashrc`, `bash/.bash_profile` + `bash/conf.d/*.bash`
- **Target:** `~/.bashrc`, `~/.bash_profile` + `~/.config/bash/conf.d/`
- **Features:**
  - Modular conf.d structure
  - Modern tool integrations
  - Function library
  - Cloud CLI integrations

### Starship Prompt
- **File:** `starship/starship.toml`
- **Target:** `~/.config/starship.toml`
- **Features:**
  - Fast, cross-shell prompt
  - Git status integration
  - Language version displays
  - Cloud context indicators

### Ghostty Terminal
- **File:** `ghostty/config`
- **Target:** `~/Library/Application Support/com.mitchellh.ghostty/config`
- **Platform:** macOS only
- **Features:**
  - Modern GPU-accelerated terminal
  - Custom color schemes
  - Font configurations

## Manual Installation

If you prefer manual installation:

### Fish Shell
```bash
mkdir -p ~/.config/fish/conf.d ~/.config/fish/functions
cp fish/config.fish ~/.config/fish/
cp fish/conf.d/*.fish ~/.config/fish/conf.d/
cp fish/functions/*.fish ~/.config/fish/functions/
```

### Zsh
```bash
mkdir -p ~/.config/zsh/conf.d
cp zsh/.zshrc ~/.zshrc
cp zsh/conf.d/*.zsh ~/.config/zsh/conf.d/
```

### Bash
```bash
mkdir -p ~/.config/bash/conf.d
cp bash/.bashrc ~/.bashrc
cp bash/.bash_profile ~/.bash_profile
cp bash/conf.d/*.bash ~/.config/bash/conf.d/
```

### Starship
```bash
mkdir -p ~/.config
cp starship/starship.toml ~/.config/
```

### Ghostty (macOS)
```bash
mkdir -p "$HOME/Library/Application Support/com.mitchellh.ghostty"
cp ghostty/config "$HOME/Library/Application Support/com.mitchellh.ghostty/"
```

## Configuration Structure

All shell configurations use a modular `conf.d/` structure with numbered prefixes:

- `00-*` - Environment and core setup
- `10-*` - Aliases and options
- `20-*` - Functions and tools
- `30-*` - Git and abbreviations
- `40-*` - Completions
- `60-*` - Modern tools
- `70-*` - Prompt configuration
- `80-*` - Cloud CLI integrations

This ordering ensures proper dependency loading.

## Customization

After installation, you can customize:

1. **Add your own configs:** Create additional files in the conf.d directories
2. **Modify existing configs:** Edit the installed files in your home directory
3. **Shell-specific features:** Each shell has unique modules you can enable/disable

## Modern Tools Referenced

These configurations integrate with:
- `bat` - Cat with syntax highlighting
- `eza` - Modern ls replacement
- `fd` - Fast file finder
- `ripgrep` - Fast grep alternative
- `fzf` - Fuzzy finder
- `zoxide` - Smart cd command
- `atuin` - Better shell history
- `direnv` - Per-project environments
- `starship` - Cross-shell prompt
- `wt` - Git worktree manager (Fish function, included in Fish configuration)

## Post-Installation

After running the installation script:

1. **Restart your terminal** to load configurations
2. **Test the shell:**
   - Fish: `fish`
   - Zsh: `zsh`
   - Bash: `bash`
3. **Make a shell default (optional):**
   ```bash
   chsh -s $(which fish)  # or zsh/bash
   ```

## Troubleshooting

**Shell not loading config:**
- Verify files exist: `ls ~/.config/fish/config.fish`
- Check for syntax errors: `fish --debug` or `zsh -x` or `bash -x`

**Tools not working:**
- Ensure Homebrew tools are installed
- Check PATH configuration in conf.d files
- Source the config manually: `source ~/.config/fish/config.fish`

**Permission issues:**
- Check file ownership: `ls -la ~/.config/fish/`
- Fix if needed: `chmod 644 ~/.config/fish/config.fish`

## More Information

See the main SKILL.md for comprehensive documentation on shell configuration management and tool references.
