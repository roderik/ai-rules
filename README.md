# AI Rules

Professional Claude Code configuration with enterprise-grade defaults for Solidity and TypeScript development.

## Features

### 🎯 Smart Configuration
- **Optimized Environment Variables**: Extended timeouts, enhanced output limits, deep thinking tokens
- **Professional Hooks**: Auto-formatting with Prettier and Forge, security warnings, sensitive file protection
- **Status Line Integration**: Real-time usage tracking with `ccusage`
- **MCP Server Support**: Auto-approval for project MCP servers
- **AI Agents**: Automatic code review agent that runs after code changes
- **Custom Commands**: `/review` command for manual code review triggers

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

## Configuration Location

Configuration is installed to: `~/.claude/`

## What Gets Installed

### AI Agents
- **code-reviewer**: Automatically reviews code changes for quality, security, and best practices
  - Invoke directly with `@code-reviewer` in Claude Code
  - Runs automatically after code modifications
  - Checks for security vulnerabilities
  - Validates architecture patterns
  - Suggests improvements

### Custom Commands  
- **/review**: Manual trigger for comprehensive code review
  - Alternative: Use `@code-reviewer` to invoke the agent directly
  - Reviews unstaged, staged, and branch commits
  - Provides detailed feedback

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

### MCP Servers
Pre-configured MCP (Model Context Protocol) servers:
- **memory**: Persistent memory across sessions (`@modelcontextprotocol/server-memory`)
- **filesystem**: File system access with home directory as root (`@modelcontextprotocol/server-filesystem`)

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
├── .claude/
│   ├── agents/
│   │   └── code-reviewer.md  # AI code review agent
│   ├── commands/
│   │   └── review.md         # Manual review command
│   ├── settings/
│   │   └── settings.json     # Environment variables and features
│   ├── hooks/
│   │   └── hooks.json         # Pre/Post tool hooks
│   └── mcp/
│       └── mcp.json           # MCP server configurations
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
