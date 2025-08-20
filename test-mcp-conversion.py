#!/usr/bin/env python3
"""
Test script to verify Claude MCP to OpenCode MCP conversion
"""

import json
import sys

# Sample Claude MCP config
claude_config = {
    "mcpServers": {
        "linear": {
            "type": "sse",
            "url": "https://mcp.linear.app/sse"
        },
        "context7": {
            "type": "sse",
            "url": "https://mcp.context7.com/sse"
        },
        "playwright": {
            "type": "stdio",
            "command": "bun",
            "args": ["x", "-y", "@playwright/mcp@latest"],
            "env": {}
        },
        "grep": {
            "type": "http",
            "url": "https://mcp.grep.app"
        },
        "DeepGraph TypeScript MCP": {
            "description": "TypeScript code analysis",
            "command": "bun",
            "args": ["x", "-y", "mcp-code-graph@latest", "microsoft/TypeScript"]
        }
    }
}

# Convert to OpenCode format
opencode_config = {
    "$schema": "https://opencode.ai/config.json",
    "mcp": {}
}

for server_name, server_config in claude_config.get('mcpServers', {}).items():
    opencode_server = {}
    opencode_server['enabled'] = True
    
    if server_config.get('type') == 'stdio':
        # Convert stdio servers to local type
        opencode_server['type'] = 'local'
        command = [server_config.get('command', 'bun')]
        args = server_config.get('args', [])
        opencode_server['command'] = command + args
        if 'env' in server_config and server_config['env']:
            opencode_server['environment'] = server_config['env']
    
    elif server_config.get('type') in ['sse', 'http']:
        # Convert SSE/HTTP servers to remote type
        opencode_server['type'] = 'remote'
        opencode_server['url'] = server_config.get('url', '')
    
    elif 'command' in server_config:
        # Handle servers with just command (like DeepGraph)
        opencode_server['type'] = 'local'
        command = [server_config.get('command', 'bun')]
        args = server_config.get('args', [])
        opencode_server['command'] = command + args
    
    else:
        # Skip if we can't determine type
        print(f"Skipping {server_name}: cannot determine type", file=sys.stderr)
        continue
    
    # Use sanitized server name (replace spaces with underscores)
    sanitized_name = server_name.replace(' ', '_').replace('/', '_')
    opencode_config['mcp'][sanitized_name] = opencode_server

print("=== OpenCode MCP Configuration ===")
print(json.dumps(opencode_config, indent=2))

print("\n=== Summary ===")
print(f"Converted {len(opencode_config['mcp'])} MCP servers:")
for name, config in opencode_config['mcp'].items():
    print(f"  • {name} ({config['type']})")