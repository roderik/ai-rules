# AI Configuration Schemas

## Overview

This reference documents the configuration file formats and locations for all AI assistants in the rr- development environment. Use this when editing or validating AI assistant configurations.

## Feature Parity Principle

**Critical**: All AI assistants should maintain near-identical configurations to ensure consistent capabilities across platforms. When adding/removing MCP servers or updating configurations:

1. **Apply changes to ALL platforms**: Claude, Codex, Gemini, OpenCode
2. **Keep MCP servers synchronized**: Same server names, commands, and args
3. **Adapt only syntax**: Format differences (JSON vs TOML, stdio vs local) are acceptable
4. **Maintain consistency**: Environment variables, permissions, feature flags

Only deviate when features are genuinely unavailable on a specific platform.

## Configuration File Locations

### macOS/Linux

- **Claude Code**: `~/.claude/settings.json` (was `~/.claude.json`)
- **Codex CLI**: `~/.codex/config.toml`
- **Gemini CLI**: `~/.gemini/settings.json`
- **OpenCode**: `~/.config/opencode/opencode.json`
- **Cursor**: `~/.cursor/mcp.json`

### Windows

- **Claude Code**: `%USERPROFILE%\.claude\settings.json`
- **Codex CLI**: `%USERPROFILE%\.codex\config.toml`
- **Gemini CLI**: `%USERPROFILE%\.gemini\settings.json`
- **OpenCode**: `%USERPROFILE%\.config\opencode\opencode.json`
- **Cursor**: `%USERPROFILE%\.cursor\mcp.json`

## Claude Code Configuration

**File**: `~/.claude/settings.json` (JSON format)

### Structure

```json
{
  "includeCoAuthoredBy": false,
  "env": {
    "ENABLE_BACKGROUND_TASKS": "1",
    "FORCE_AUTO_BACKGROUND_TASKS": "1",
    "CLAUDE_CODE_ENABLE_UNIFIED_READ_TOOL": "1",
    "CLAUDE_BASH_MAINTAIN_PROJECT_WORKING_DIR": "1",
    "BASH_MAX_TIMEOUT_MS": "6000000",
    "BASH_DEFAULT_TIMEOUT_MS": "6000000",
    "BASH_MAX_OUTPUT_LENGTH": "50000",
    "MCP_TIMEOUT": "30000",
    "MCP_TOOL_TIMEOUT": "600000",
    "MAX_MCP_OUTPUT_TOKENS": "50000",
    "DISABLE_COST_WARNINGS": "1"
  },
  "statusLine": {
    "type": "command",
    "command": "bun x ccusage statusline --visual-burn-rate emoji",
    "padding": 0
  },
  "enableAllProjectMcpServers": true,
  "mcpServers": {
    "linear": {
      "type": "sse",
      "url": "https://mcp.linear.app/sse"
    },
    "context7": {
      "type": "stdio",
      "command": "bun",
      "args": ["x", "-y", "@upstash/context7-mcp@latest"],
      "env": {}
    },
    "octocode": {
      "type": "stdio",
      "command": "bun",
      "args": ["x", "-y", "octocode-mcp@latest"],
      "env": {}
    },
    "shadcn": {
      "type": "stdio",
      "command": "bun",
      "args": ["x", "-y", "shadcn@latest", "mcp"],
      "env": {}
    },
    "chrome-devtools": {
      "type": "stdio",
      "command": "bun",
      "args": ["x", "-y", "chrome-devtools-mcp@latest"],
      "env": {}
    }
  },
  "hooks": {
    "PostToolUse": [
      {
        "matcher": "Edit|MultiEdit|Write",
        "hooks": [
          {
            "type": "command",
            "command": "jq -r '.tool_input.file_path // empty' | while read file_path; do if [[ -f \"$file_path\" ]]; then if [[ \"$file_path\" == *.sol ]]; then if command -v forge >/dev/null 2>&1; then forge fmt \"$file_path\" 2>/dev/null || true; fi; else bunx prettier --write \"$file_path\" --ignore-unknown 2>/dev/null || true; fi; fi; done"
          }
        ]
      }
    ]
  }
}
```

### Key Sections

**env**: Environment variables for Claude Code behavior

- Timeouts, token limits, feature flags
- All values are strings

**statusLine**: Custom status line configuration

- `type`: "command" or "text"
- `command`: Shell command to execute
- `padding`: Spacing around status line

**mcpServers**: MCP server configurations

- Each server has `type`, `command`, `args`, `env`
- Types: "stdio" (local) or "sse" (remote)

**hooks**: Post-tool-use automation

- `PostToolUse`: Array of hook configurations
- `matcher`: Regex pattern for tool names
- `hooks`: Array of commands to execute

### Validation

```bash
# Validate JSON syntax
jq empty ~/.claude/settings.json

# Pretty print
jq . ~/.claude/settings.json

# Check specific field
jq '.mcpServers | keys' ~/.claude/settings.json
```

## Codex CLI Configuration

**File**: `~/.codex/config.toml` (TOML format)

### Structure

```toml
file_opener = "cursor"
profile = "full-auto"

[features]
web_search_request = true
rmcp_client = true
unified_exec = true
streamable_shell = true
apply_patch_freeform = true
ghost_commit = true

[profiles.full-auto]
model = "gpt-5-codex"
model_provider = "openai"
model_reasoning_effort = "medium"
full-auto = true
bypass-approvals = true
trusted-workspace = true
bypass-sandbox = true
approval_policy = "never"
sandbox_mode = "danger-full-access"

[profiles.safe]
model = "gpt-5-codex"
model_provider = "openai"
model_reasoning_effort = "medium"
full-auto = false
bypass-approvals = false
trusted-workspace = false
bypass-sandbox = false
approval_policy = "on-request"
sandbox_mode = "workspace-write"

[shell_environment_policy]
inherit = "all"
set = { AGENT = "1" }

[mcp_servers.context7]
command = "bun"
args = ["x", "-y", "@upstash/context7-mcp@latest"]

[mcp_servers.octocode]
command = "bun"
args = ["x", "-y", "octocode-mcp@latest"]

[mcp_servers.shadcn]
command = "bun"
args = ["x", "-y", "shadcn@latest", "mcp"]

[mcp_servers.chrome_devtools]
command = "bun"
args = ["x", "-y", "chrome-devtools-mcp@latest"]

[tui]
notifications = true
```

### Key Sections

**profiles**: Named configuration profiles

- `full-auto`: Unrestricted automation mode
- `safe`: Limited permissions mode
- Switch with `profile = "name"`

**features**: Feature flags for experimental capabilities

**mcp_servers**: MCP server configurations

- Each server is a `[mcp_servers.name]` section
- `command`: Executable path
- `args`: Array of arguments

**shell_environment_policy**: Environment variable handling

- `inherit`: "all", "none", or specific vars
- `set`: Dictionary of vars to set

### Validation

```bash
# Validate TOML syntax (requires toml CLI tool)
toml validate ~/.codex/config.toml

# Or use Python
python3 -c "import tomllib; tomllib.load(open('$HOME/.codex/config.toml', 'rb'))"

# View with syntax highlighting
bat ~/.codex/config.toml
```

## Gemini CLI Configuration

**File**: `~/.gemini/settings.json` (JSON format)

### Structure

```json
{
  "model": "gemini-2.5-pro",
  "sandbox": false,
  "context": {
    "fileName": ["AGENTS.md", "GEMINI.md"]
  },
  "checkpointing": {
    "enabled": true
  },
  "tools": {
    "requireConfirmation": false,
    "shellCommand": {
      "requireConfirmation": false
    },
    "fileSystem": {
      "requireConfirmation": false
    }
  },
  "mcpServers": {
    "linear": {
      "type": "sse",
      "url": "https://mcp.linear.app/sse"
    },
    "context7": {
      "type": "stdio",
      "command": "bun",
      "args": ["x", "-y", "@upstash/context7-mcp@latest"],
      "env": {}
    },
    "octocode": {
      "type": "stdio",
      "command": "bun",
      "args": ["x", "-y", "octocode-mcp@latest"],
      "env": {}
    },
    "shadcn": {
      "type": "stdio",
      "command": "bun",
      "args": ["x", "-y", "shadcn@latest", "mcp"],
      "env": {}
    },
    "chrome-devtools": {
      "type": "stdio",
      "command": "bun",
      "args": ["x", "-y", "chrome-devtools-mcp@latest"],
      "env": {}
    }
  },
  "confirmationMode": "none"
}
```

### Key Sections

**model**: Gemini model identifier

- Example: "gemini-2.5-pro"

**context**: Files to include in context

- `fileName`: Array of markdown files

**tools**: Tool permission settings

- `requireConfirmation`: Global setting
- Per-tool overrides: `shellCommand`, `fileSystem`

**mcpServers**: MCP server configurations

- Same format as Claude Code

**checkpointing**: Conversation state management

- `enabled`: Boolean for checkpoint saving

### Validation

```bash
# Validate JSON syntax
jq empty ~/.gemini/settings.json

# Pretty print
jq . ~/.gemini/settings.json

# Check MCP servers
jq '.mcpServers | keys' ~/.gemini/settings.json
```

## OpenCode Configuration

**File**: `~/.config/opencode/opencode.json` (JSON format)

### Structure

```json
{
  "$schema": "https://opencode.ai/config.json",
  "plugin": ["opencode-openai-codex-auth@3.0.0"],
  "permission": {
    "edit": "allow",
    "bash": {
      "*": "allow",
      "rm -rf *": "deny",
      "rm -rf /*": "deny",
      "sudo *": "ask",
      "dd if=* of=/dev/*": "deny",
      "mkfs.* /dev/*": "deny",
      ":(){ :|:& };:": "deny"
    },
    "webfetch": "allow"
  },
  "mcp": {
    "context7": {
      "type": "local",
      "command": ["bun", "x", "-y", "@upstash/context7-mcp@latest"],
      "enabled": true
    },
    "octocode": {
      "type": "local",
      "command": ["bun", "x", "-y", "octocode-mcp@latest"],
      "enabled": true
    },
    "shadcn": {
      "type": "local",
      "command": ["bun", "x", "-y", "shadcn@latest", "mcp"],
      "enabled": true
    },
    "chrome-devtools": {
      "type": "local",
      "command": ["bun", "x", "-y", "chrome-devtools-mcp@latest"],
      "enabled": true
    }
  },
  "lsp": {
    "biome": {
      "command": ["bun", "x", "-y", "biome", "lsp-proxy"],
      "extensions": [
        ".js",
        ".jsx",
        ".ts",
        ".tsx",
        ".json",
        ".jsonc",
        ".css",
        ".html"
      ]
    }
  },
  "keybinds": {
    "session_child_cycle": "<leader>right",
    "session_child_cycle_reverse": "<leader>left"
  },
  "provider": {
    "openai": {
      "options": {
        "reasoningEffort": "medium",
        "reasoningSummary": "auto",
        "textVerbosity": "medium",
        "include": ["reasoning.encrypted_content"],
        "store": false
      },
      "models": {
        "gpt-5-codex-low": {
          "name": "GPT 5 Codex Low (OAuth)",
          "limit": {
            "context": 272000,
            "output": 128000
          },
          "options": {
            "reasoningEffort": "low"
          }
        }
      }
    }
  }
}
```

### Key Sections

**plugin**: Array of OpenCode plugins

- Format: "plugin-name@version"

**permission**: Fine-grained permission control

- `edit`: "allow" or "deny"
- `bash`: Pattern-based command filtering
- `webfetch`: Network access control

**mcp**: MCP server configurations

- `type`: "local" (stdio)
- `command`: Array of command parts
- `enabled`: Boolean flag

**lsp**: Language Server Protocol integrations

- Per-language server configuration
- `command`: Executable and args
- `extensions`: File extensions to handle

**provider**: Model provider configurations

- OpenAI, Anthropic, etc.
- Per-model settings and limits

### Validation

```bash
# Validate JSON syntax
jq empty ~/.config/opencode/opencode.json

# Pretty print
jq . ~/.config/opencode/opencode.json

# Check MCP servers
jq '.mcp | keys' ~/.config/opencode/opencode.json

# Validate against schema
curl -s https://opencode.ai/config.json | jq . > /tmp/schema.json
# Then validate using a JSON schema validator
```

## Cursor Configuration

**File**: `~/.cursor/mcp.json` (JSON format)

### Structure

```json
{
  "mcpServers": {
    "Context7": {
      "url": "https://mcp.context7.com/mcp",
      "headers": {}
    },
    "Octocode": {
      "command": "bunx octocode-mcp@latest",
      "env": {},
      "args": []
    }
  }
}
```

### Key Sections

**mcpServers**: MCP server configurations

- Supports two formats: URL-based (remote) and command-based (local)
- URL-based: `url` for remote MCP endpoints, optional `headers`
- Command-based: `command` string, `args` array, optional `env`

### Server Types

**Remote MCP (URL-based):**

```json
"ServerName": {
  "url": "https://mcp.example.com/endpoint",
  "headers": {}
}
```

**Local MCP (command-based):**

```json
"ServerName": {
  "command": "bunx package-name@latest",
  "env": {},
  "args": []
}
```

### Validation

```bash
# Validate JSON syntax
jq empty ~/.cursor/mcp.json

# Pretty print
jq . ~/.cursor/mcp.json

# Check MCP servers
jq '.mcpServers | keys' ~/.cursor/mcp.json
```

### Notes

- Cursor uses a simpler MCP configuration format compared to other AI assistants
- Command-based servers use a single `command` string (not separate command + args like Claude)
- Remote servers use `url` field (not `type: "sse"` like Claude)
- Restart Cursor after modifying the configuration

## Common Configuration Patterns

### Adding MCP Server

**Claude Code** (`~/.claude/settings.json`):

```json
"mcpServers": {
  "new-server": {
    "type": "stdio",
    "command": "bun",
    "args": ["x", "-y", "server-package@latest"],
    "env": {}
  }
}
```

**Codex** (`~/.codex/config.toml`):

```toml
[mcp_servers.new_server]
command = "bun"
args = ["x", "-y", "server-package@latest"]
```

**Gemini** (`~/.gemini/settings.json`):

```json
"mcpServers": {
  "new-server": {
    "type": "stdio",
    "command": "bun",
    "args": ["x", "-y", "server-package@latest"],
    "env": {}
  }
}
```

**OpenCode** (`~/.config/opencode/opencode.json`):

```json
"mcp": {
  "new-server": {
    "type": "local",
    "command": ["bun", "x", "-y", "server-package@latest"],
    "enabled": true
  }
}
```

**Cursor** (`~/.cursor/mcp.json`):

```json
"mcpServers": {
  "new-server": {
    "command": "bunx server-package@latest",
    "env": {},
    "args": []
  }
}
```

### Environment Variables

**Claude Code**: Use `env` section in `settings.json`:

```json
"env": {
  "MY_VAR": "value"
}
```

**Codex**: Use `shell_environment_policy`:

```toml
[shell_environment_policy]
set = { MY_VAR = "value" }
```

**Gemini**: Per-MCP server:

```json
"mcpServers": {
  "server": {
    "env": {
      "MY_VAR": "value"
    }
  }
}
```

**OpenCode**: Global or per-provider

### Hooks (Claude Code)

Add post-tool-use automation:

```json
"hooks": {
  "PostToolUse": [
    {
      "matcher": "Edit|Write",
      "hooks": [
        {
          "type": "command",
          "command": "prettier --write $FILE"
        }
      ]
    }
  ]
}
```

## Merging Configuration Updates

When updating configurations, preserve existing settings while adding new ones:

### JSON Files (Claude, Gemini, OpenCode)

```bash
# Merge using jq
jq -s '.[0] * .[1]' existing.json new.json > merged.json

# For MCP servers, override completely
jq -s '.[0] * .[1] | .mcpServers = .[1].mcpServers' existing.json new.json > merged.json
```

### TOML Files (Codex)

```bash
# Manual merge recommended
# Or use Python with toml library
python3 -c "
import tomllib, tomli_w
with open('existing.toml', 'rb') as f:
    existing = tomllib.load(f)
with open('new.toml', 'rb') as f:
    new = tomllib.load(f)
existing.update(new)
with open('merged.toml', 'wb') as f:
    tomli_w.dump(existing, f)
"
```

## Backup Strategy

Before editing configuration files:

```bash
# Backup with timestamp
cp ~/.claude/settings.json ~/.claude/settings.json.backup-$(date +%Y%m%d-%H%M%S)

# Or use versioned backups
git init ~/.config-backups
cp ~/.claude/settings.json ~/.config-backups/claude-settings.json
cd ~/.config-backups && git add . && git commit -m "Backup before changes"
```

## Troubleshooting

### Invalid JSON

```bash
# Find syntax errors
jq empty config.json 2>&1

# Common fixes:
# - Remove trailing commas
# - Quote all keys
# - Escape backslashes in strings
```

### Invalid TOML

```bash
# Validate
python3 -c "import tomllib; tomllib.load(open('config.toml', 'rb'))"

# Common fixes:
# - Use [[array.of.tables]] for arrays
# - Quote strings with special chars
# - Use """ for multiline strings
```

### MCP Server Not Loading

```bash
# Test command manually
bun x -y @upstash/context7-mcp@latest

# Check logs
tail -f ~/.claude/logs/mcp-*.log  # Claude
tail -f ~/.codex/logs/*.log        # Codex

# Verify permissions
ls -la ~/.claude/settings.json
```

### Config Not Taking Effect

```bash
# Restart the AI assistant
# Verify file location
ls -la ~/.claude/settings.json
ls -la ~/.codex/config.toml

# Check for conflicting configs
find ~ -name "settings.json" -o -name "config.toml"
```
