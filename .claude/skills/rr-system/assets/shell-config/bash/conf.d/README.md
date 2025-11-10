# Bash Configuration Directory

This directory contains modular bash configuration files that are automatically loaded by the main `.bashrc` file.

## File Naming Convention

Files are loaded in alphabetical order. The numbering prefix determines the loading sequence:

- `00-*` - Environment variables and early initialization
- `10-*` - Shell options and settings
- `20-*` - Completions
- `30-*` - Aliases
- `40-*` - Functions
- `50-*` - Key bindings
- `60-*` - External tool configurations (fzf, etc.)
- `70-*` - Prompt configuration
- `80-*` - Application-specific configurations

## Files

- `00-environment.bash` - Basic environment variables
- `01-homebrew.bash` - Homebrew initialization
- `02-paths.bash` - PATH modifications
- `10-options.bash` - Shell options and history settings
- `20-completions.bash` - Command completions
- `30-aliases.bash` - Command aliases
- `40-functions.bash` - Shell functions
- `50-keybindings.bash` - Key binding configurations
- `60-fzf.bash` - FZF fuzzy finder configuration
- `70-prompt.bash` - Prompt customization (PS1) and Starship
- `80-claude.bash` - Claude CLI helpers

## Usage

These files are automatically sourced by `~/.bashrc` when placed in `~/.config/bash/conf.d/`.

To reload configuration:

```bash
source ~/.bashrc
```

## Customization

Add your own configuration files following the naming convention. They will be automatically loaded in alphabetical order.
