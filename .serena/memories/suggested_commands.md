# Suggested Commands for AI Rules Project

## Installation & Testing
```bash
# Install configurations (default)
./install.sh

# Preview changes without installing (dry run)
./install.sh --dry-run

# Force overwrite existing configurations
./install.sh --force

# Test installation logic
./test-install.sh

# Test MCP conversion
python3 test-mcp-conversion.py
```

## Uninstallation
```bash
# Interactive uninstall
./uninstall.sh

# Preview what will be removed
./uninstall.sh --dry-run

# Skip confirmation prompt
./uninstall.sh --force
```

## Git Operations
```bash
# Check status
git status

# View diffs
git diff

# Commit with conventional format
git commit -m "type(scope): description"
```

## Quality Control
- **CRITICAL**: Use test-runner agent via Claude Code Task tool - NEVER run commands directly
- For build-only tasks: `bun run build` (can be run directly)
- For type-checking only: `bun run typecheck` (can be run directly)

## System Commands (Darwin/macOS)
- Use modern tool alternatives as defined in AGENTS.md
- `fd` instead of `find`
- `rg` instead of `grep`  
- `eza` instead of `ls`
- `bat` instead of `cat`

## Dependencies
- `jq` - JSON processor (required)
- `git` - Version control (required)
- `bun` - Package manager and runtime
- `forge` - Solidity formatting (optional)
- `ccusage` - Status line integration (optional)