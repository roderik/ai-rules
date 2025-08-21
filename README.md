# AI Rules

Professional AI assistant configurations for Claude Code, Codex CLI, OpenCode and Gemini CLI with enterprise-grade defaults for Solidity and TypeScript development.

## Complete Setup

This repository is part of a comprehensive development environment setup. For the full experience, check out:

- **[Shell Config](https://github.com/roderik/shell-config)** - Shell configuration and dotfiles
- **[AI Rules](https://github.com/roderik/ai-rules)** - AI assistant configurations (this repo)
- **[WT](https://github.com/roderik/wt)** - Windows Terminal configuration

**Author**: [@r0derik](https://x.com/r0derik)

## Features

### 🎯 Smart Configuration

- **Multi-AI Support**: Unified configuration for Claude Code, Codex CLI, and Gemini CLI
- **Optimized Environment Variables**: Extended timeouts, enhanced output limits, deep thinking tokens
- **Professional Hooks**: Auto-formatting with Prettier and Forge, security warnings, sensitive file protection
- **Status Line Integration**: Real-time usage tracking with `ccusage`
- **MCP Server Support**: Shared MCP servers across all AI assistants
- **AI Agents**: Automatic code review, test runner, and PR creator agents
- **Custom Commands**: Unified `/review`, `/test`, and `/pr` commands across platforms

### 🛡️ Security First

- Warns about dangerous commands (`rm -rf`, `sudo`, etc.)
- Protects sensitive files (`.env`, secrets, SSH configs)
- Blocks prompts containing passwords or API keys
- Creates backups before any modifications

### 🎨 Developer Experience

- Beautiful gradient ASCII art banner
- Colorful terminal output with emoji indicators
- Dry-run mode for safe testing
- Selective installation (Code-only or Desktop-only)
- Intelligent JSON merging preserves your settings

## Quick Install

### Basic One-liner

```bash
# Default installation
curl -fsSL https://raw.githubusercontent.com/roderik/ai-rules/main/install.sh | bash
```

### One-liner with Options

```bash
# Preview changes without installing (dry run)
curl -fsSL https://raw.githubusercontent.com/roderik/ai-rules/main/install.sh | bash -s -- --dry-run

# Force overwrite existing configurations
curl -fsSL https://raw.githubusercontent.com/roderik/ai-rules/main/install.sh | bash -s -- --force

# Using wget instead of curl
wget -qO- https://raw.githubusercontent.com/roderik/ai-rules/main/install.sh | bash -s -- --dry-run
```

### Clone and Install

```bash
git clone https://github.com/roderik/ai-rules.git
cd ai-rules
./install.sh
```

## Installation Options

```bash
# Default installation
./install.sh

# Preview changes without installing
./install.sh --dry-run

# Force overwrite existing configurations
./install.sh --force
```

## Configuration Locations

Configurations are installed to:

- **Claude Code**: `~/.claude/`
- **Codex CLI**: `~/.codex/`
- **Gemini CLI**: `~/.gemini/`

## What Gets Installed

### AI Agents (Claude Code)

- **code-reviewer**: Automatically reviews code changes for quality, security, and best practices
  - Invoke directly with `@code-reviewer` in Claude Code
  - Runs automatically after code modifications
  - Checks for security vulnerabilities
  - Validates architecture patterns
  - Suggests improvements

- **test-runner**: Proactive agent for running quality checks
  - Invoke directly with `@test-runner` in Claude Code
  - Runs tests, linting, and formatting
  - Returns focused error list with file:line:function format
  - Critical requirement - runs after ANY code change
  - No exceptions for quality enforcement

- **pr-creator**: PR creation and lifecycle management agent
  - Invoke directly with `@pr-creator` in Claude Code
  - Creates pull requests when explicitly requested
  - Handles branch creation, commits, and pushing
  - Generates PR title and description from changes
  - Returns PR URL for review

### Custom Commands

#### Claude Code & Gemini CLI

- **/review**: Manual trigger for comprehensive code review
  - Claude: Use `@code-reviewer` to invoke the agent directly
  - Gemini: Scripted behavior matching agent functionality
  - Reviews unstaged, staged, and branch commits
  - Provides detailed feedback

- **/test**: Automated test and fix workflow
  - Claude: Launches test-runner agent to check for issues
  - Gemini: Scripted test execution and auto-fix
  - Automatically fixes format, lint, and type errors
  - Iterates until all checks pass
  - Returns focused error list with file:line format

- **/pr**: Create pull requests with a single command
  - Claude: Uses pr-creator agent
  - Gemini: Scripted PR creation workflow
  - Handles complete PR workflow automatically
  - Creates appropriate branch names
  - Commits uncommitted changes
  - Generates PR title and description from changes
  - Supports Linear ticket integration
  - Returns PR URL for review

### Environment Variables

```json
{
  "ENABLE_BACKGROUND_TASKS": "1",
  "FORCE_AUTO_BACKGROUND_TASKS": "1",
  "CLAUDE_CODE_ENABLE_UNIFIED_READ_TOOL": "1",
  "CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR": "1",
  "BASH_MAX_TIMEOUT_MS": "600000",
  "BASH_DEFAULT_TIMEOUT_MS": "600000",
  "BASH_MAX_OUTPUT_LENGTH": "50000",
  "CLAUDE_CODE_MAX_OUTPUT_TOKENS": "8192",
  "MAX_THINKING_TOKENS": "32768",
  "MCP_TIMEOUT": "30000",
  "MCP_TOOL_TIMEOUT": "60000",
  "MAX_MCP_OUTPUT_TOKENS": "50000",
  "DISABLE_COST_WARNINGS": "1",
  "DISABLE_NON_ESSENTIAL_MODEL_CALLS": "1"
}
```

### Hooks

- **PostToolUse**: Auto-format with Prettier and Forge for Solidity
- **PreToolUse**: Security warnings for dangerous operations
- **SessionStart**: Session logging with timestamp
- **UserPromptSubmit**: Sensitive data filtering

### Features

- `ccusage` status line for real-time usage tracking
- Auto-approval for all project MCP servers
- Co-authorship disabled by default

### Multi-AI Collaboration

The configuration supports seamless collaboration between AI assistants:

#### Codex CLI

- **AGENTS.md**: Specialized agent instructions for multi-model collaboration
- **config.toml**: Model selection and prompt customization
- **Role**: Complex implementation and code generation specialist

#### Gemini CLI

- **AGENTS.md**: Shared agent collaboration instructions
- **settings.json**: Shared MCP servers with Claude
- **commands.toml**: Unified command structure (`/pr`, `/review`, `/test`)
- **Role**: Validation, review, and quality assurance specialist

### MCP Servers

Shared MCP (Model Context Protocol) servers across all AI assistants:

#### Shared Across All Platforms

- **linear**: Linear issue tracking integration
- **context7**: Library documentation and code examples
- **deepwiki**: GitHub repository documentation
- **sentry**: Error tracking and monitoring
- **playwright**: Browser automation and testing
- **grep**: Code search across GitHub
- **OpenZeppelinSolidityContracts**: Solidity contract templates
- **octocode**: GitHub code exploration

## Uninstallation

### Basic One-liner

```bash
# Default uninstall
curl -fsSL https://raw.githubusercontent.com/roderik/ai-rules/main/uninstall.sh | bash
```

### One-liner with Options

```bash
# Preview what will be removed (dry run)
curl -fsSL https://raw.githubusercontent.com/roderik/ai-rules/main/uninstall.sh | bash -s -- --dry-run

# Skip confirmation prompt
curl -fsSL https://raw.githubusercontent.com/roderik/ai-rules/main/uninstall.sh | bash -s -- --force

# Using wget instead of curl
wget -qO- https://raw.githubusercontent.com/roderik/ai-rules/main/uninstall.sh | bash -s -- --dry-run
```

### Using Local Script

```bash
./uninstall.sh           # Interactive uninstall
./uninstall.sh --dry-run # Preview what will be removed
./uninstall.sh --force   # Skip confirmation prompt
```

The uninstaller:

- Preserves your personal settings
- Creates timestamped backups
- Only removes AI Rules specific configurations

## Requirements

- `jq` - JSON processor (required)
- `git` - Version control (required)
- `bun` or `npm` - For Prettier formatting
- `forge` - For Solidity formatting (optional)

### Installing Dependencies

**macOS:**

```bash
brew install jq git
```

**Ubuntu/Debian:**

```bash
sudo apt-get install jq git
```

**Fedora/RHEL:**

```bash
sudo yum install jq git
```

**Arch Linux:**

```bash
sudo pacman -S jq git
```

## Advanced Usage

### Custom Installation Directory

```bash
export CLAUDE_CONFIG_ROOT="/custom/path"
./install.sh
```

### Backup Files

Both installer and uninstaller create timestamped backups:

- `settings.json.backup.YYYYMMDD_HHMMSS`
- Preserves your existing configurations before changes

### JSON Merging

The installer intelligently merges configurations:

- Preserves existing user settings
- Appends new hooks without duplicates
- Merges environment variables
- Handles nested JSON structures

## Troubleshooting

### Missing Dependencies

```bash
# Check for required tools
command -v jq >/dev/null || echo "jq not installed"
command -v git >/dev/null || echo "git not installed"
```

### Permission Errors

```bash
# Make scripts executable
chmod +x install.sh uninstall.sh
```

### Forge Not Found

Forge formatting is optional. To enable Solidity formatting:

```bash
# Install Foundry
curl -L https://foundry.paradigm.xyz | bash
foundryup
```

### Status Line Not Working

Install ccusage for the status line feature:

```bash
npm install -g ccusage
# or
bun add -g ccusage
```

## Project Structure

```
ai-rules/
├── .claude/                   # Claude Code configuration
│   ├── agents/
│   │   ├── code-reviewer.md  # AI code review agent
│   │   ├── test-runner.md    # Quality checks agent
│   │   └── pr-creator.md     # PR creation agent
│   ├── commands/
│   │   ├── review.md         # Manual review command
│   │   ├── test.md           # Automated test/fix command
│   │   └── pr.md             # PR creation command
│   ├── settings/
│   │   └── settings.json     # Environment variables and features
│   ├── hooks/
│   │   └── hooks.json        # Pre/Post tool hooks
│   └── mcp/
│       └── mcp.json          # MCP server configurations
├── .codex/                    # Codex CLI configuration
│   ├── config.toml           # Codex settings and model config
│   └── AGENTS.md             # Agent collaboration instructions
├── .gemini/                   # Gemini CLI configuration
│   ├── settings.json         # Gemini settings with MCP servers
│   └── commands.toml         # Custom command definitions
├── CLAUDE.md                  # Global Claude instructions
├── AGENTS.md                  # Global agent instructions
├── install.sh                 # Installer script
├── uninstall.sh               # Uninstaller script
└── README.md                  # This file
```

## Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

### Development

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'feat: Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

MIT - See [LICENSE](LICENSE) file for details

## Support

- Issues: [GitHub Issues](https://github.com/roderik/ai-rules/issues)
- Discussions: [GitHub Discussions](https://github.com/roderik/ai-rules/discussions)
