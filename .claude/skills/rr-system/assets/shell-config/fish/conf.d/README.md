# Fish Configuration Modules

This directory contains modular Fish shell configuration files that are automatically loaded in alphabetical order.

## File Structure

Files are numbered to control load order:

- **00-09**: Core system setup (Homebrew, environment, paths)
- **10-19**: Tool-specific configurations (Node.js, 1Password)
- **20-29**: Interactive tools (FZF)
- **30-39**: Aliases
- **40-49**: Custom functions
- **50-59**: Abbreviations
- **60-69**: Modern tool integrations (direnv, zoxide, atuin)
- **70-79**: Prompt configuration
- **90-99**: Terminal-specific integrations

## Modules

| File                           | Purpose                                    |
| ------------------------------ | ------------------------------------------ |
| `00-homebrew.fish`             | Homebrew setup for M-series and Intel Macs |
| `01-environment.fish`          | Core environment variables (EDITOR, etc.)  |
| `02-paths.fish`                | Path configuration for various tools       |
| `10-node.fish`                 | Fast Node Manager (fnm) setup              |
| `11-1password.fish`            | 1Password CLI completions                  |
| `20-fzf.fish`                  | FZF fuzzy finder configuration             |
| `30-aliases.fish`              | Command aliases (ls→eza, etc.)             |
| `40-git-functions.fish`        | Git utility functions                      |
| `41-docker-functions.fish`     | Docker cleanup utilities                   |
| `42-claude-function.fish`      | Claude Code wrapper                        |
| `50-abbreviations.fish`        | Fish abbreviations (expand on space)       |
| `60-modern-tools.fish`         | Modern CLI tools (direnv, zoxide, atuin)   |
| `70-prompt.fish`               | Starship prompt initialization             |
| `99-terminal-integration.fish` | Terminal-specific integrations             |

## Customization

To add your own configurations:

1. Create a new `.fish` file in this directory
2. Use appropriate numbering for load order
3. Keep each file focused on a single purpose

## User Configuration

For personal customizations that shouldn't be version controlled, create:
`~/.config/fish/user_config.fish`

This file is sourced from the main `config.fish` if it exists.
