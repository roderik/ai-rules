# AI Assistant Configuration Templates

This directory contains template configuration files for various AI assistants.

## Quick Start

Install all configurations automatically:

```bash
# From the ai-rules repository root
cd .claude/skills/rr-system

# Install configurations (overwrites existing)
bash scripts/install-ai-configs.sh
```

## Configuration Files

### Claude Code
- **File:** `claude-settings.json`
- **Target:** `~/.claude/settings.json`
- **Format:** JSON
- **Features:**
  - Environment variables for timeouts and features
  - Status line configuration (ccusage)
  - MCP servers (linear, context7, octocode, shadcn, chrome-devtools)
  - Post-tool-use hooks for auto-formatting

### Codex CLI
- **File:** `codex-config.toml`
- **Target:** `~/.codex/config.toml`
- **Format:** TOML
- **Features:**
  - Profiles (full-auto, safe)
  - Feature flags (web search, unified exec, streamable shell)
  - MCP servers (context7, octocode, shadcn, chrome-devtools)
  - Shell environment policy

### Gemini CLI
- **File:** `gemini-settings.json`
- **Target:** `~/.gemini/settings.json`
- **Format:** JSON
- **Features:**
  - MCP servers (context7, octocode, shadcn, chrome-devtools)
  - Environment variables
  - Model configuration

### OpenCode
- **File:** `opencode-config.json`
- **Target:** `~/.config/opencode/opencode.json`
- **Format:** JSON
- **Features:**
  - Extended MCP server configurations
  - Environment variables for timeouts
  - Keyboard shortcuts

## Manual Installation

If you prefer manual installation:

### Claude Code
```bash
mkdir -p ~/.claude
cp claude-settings.json ~/.claude/settings.json
jq empty ~/.claude/settings.json  # Validate
```

### Codex CLI
```bash
mkdir -p ~/.codex
cp codex-config.toml ~/.codex/config.toml
python3 -c "import tomllib; tomllib.load(open('~/.codex/config.toml', 'rb'))"  # Validate
```

### Gemini CLI
```bash
mkdir -p ~/.gemini
cp gemini-settings.json ~/.gemini/settings.json
jq empty ~/.gemini/settings.json  # Validate
```

### OpenCode
```bash
mkdir -p ~/.config/opencode
cp opencode-config.json ~/.config/opencode/opencode.json
jq empty ~/.config/opencode/opencode.json  # Validate
```

## Customization

After installation, you can customize:

1. **MCP Servers:** Add/remove servers based on your needs
2. **Environment Variables:** Adjust timeouts and feature flags
3. **Hooks:** Modify auto-formatting behavior (Claude only)
4. **Profiles:** Switch between full-auto and safe modes (Codex only)

## Validation

### JSON Files
```bash
jq empty <file>
```

### TOML Files
```bash
python3 -c "import tomllib; tomllib.load(open('<file>', 'rb'))"
```

## Installation Behavior

The installation script overwrites existing configurations with the latest versions from the assets directory. If you have custom configurations, consider backing them up manually before running the script.

## Synchronization

These configurations are designed to maintain feature parity across all AI platforms. When adding/removing MCP servers:

1. Apply the same change to all platforms
2. Adapt only the syntax for each platform's format
3. Keep server names and commands consistent

## Troubleshooting

**Config not loading:**
- Validate syntax with commands above
- Check file permissions (should be readable)
- Restart the AI assistant

**MCP server not connecting:**
- Verify the command and args are correct
- Check that Bun is installed (`bun --version`)
- Review AI assistant logs for errors

**Lost customizations after update:**
- Compare with template to identify what changed
- Re-apply your customizations to the new config
- Consider keeping custom configs in version control

## More Information

See the main SKILL.md for comprehensive documentation on AI configuration management.
