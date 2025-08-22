# AI Rules Project Overview

## Purpose
Professional AI assistant configurations for Claude Code, Codex CLI, OpenCode and Gemini CLI with enterprise-grade defaults for Solidity and TypeScript development. This repository provides unified configuration management across multiple AI platforms with shared MCP servers, agents, and hooks.

## Tech Stack
- **Shell Scripts**: Bash-based installation/uninstallation system
- **Python**: Test scripts and MCP conversion utilities
- **JSON/TOML**: Configuration files for different AI platforms
- **Markdown**: Agent definitions and documentation
- **Bun**: Primary package manager and execution environment
- **jq**: JSON processing utility for configuration merging

## Key Features
- Multi-AI Support (Claude Code, Codex CLI, Gemini CLI, OpenCode)
- Shared MCP (Model Context Protocol) servers
- Automated AI agents (code-reviewer, test-runner, pr-creator, etc.)
- Security-focused hooks and validation
- Intelligent JSON merging that preserves user settings
- Status line integration with ccusage

## Repository Structure
```
ai-rules/
├── .claude/           # Claude Code configuration
├── .codex/           # Codex CLI configuration  
├── .gemini/          # Gemini CLI configuration
├── .opencode/        # OpenCode configuration
├── .shared/          # Shared agent content
├── .serena/          # Serena MCP server project config
├── CLAUDE.md         # Global Claude instructions
├── AGENTS.md         # Global agent instructions
├── install.sh        # Main installer script
├── uninstall.sh      # Uninstaller script
├── test-install.sh   # Test script for installation
└── test-mcp-conversion.py # MCP conversion testing
```