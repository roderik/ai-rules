# Style and Conventions for AI Rules Project

## Shell Script Conventions
- Use `#!/usr/bin/env bash` shebang
- Set `set -euo pipefail` for strict error handling
- Color codes for terminal output with emoji indicators
- Path validation to prevent directory traversal attacks
- Comprehensive logging with timestamps
- Backup creation before modifications

## Code Style Guidelines
- **Indentation**: 2 spaces for most languages (4 spaces for Python)
- **Functions**: Keep under 30 lines when possible
- **Variables**: Descriptive names over comments
- **Control Flow**: Early returns over nested conditionals
- **Modern Syntax**: ES6+ for JavaScript/TypeScript, async/await over promises

## Security Practices
- Validate all user input and file paths
- Never log or commit sensitive information
- Protect sensitive files (.env, secrets, SSH configs)
- Warn about dangerous commands (rm -rf, sudo, etc.)
- Use environment variables for configuration

## Git Workflow
- **Branch naming**: `feat/`, `fix/`, `chore/`, `docs/` prefixes
- **Commit format**: `type(scope): description` (conventional commits)
- **Never commit directly** to main/master
- **Show git diff** before committing

## File Organization
- Shared content in `.shared/` directory
- Platform-specific frontmatter in respective directories
- Configuration files use JSON/TOML formats
- Agent definitions in Markdown with YAML frontmatter
- Separate hooks, settings, and MCP configurations

## JSON Configuration Standards
- Intelligent merging preserves existing user settings
- Timestamped backups before modifications
- Environment variables in separate sections
- Consistent structure across platforms