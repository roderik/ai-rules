# MCP Servers and AI Agents Configuration

## MCP Servers (Shared Across All Platforms)

### Core Servers
- **linear**: Linear issue tracking integration (SSE)
- **context7**: Library documentation and code examples (SSE)
- **playwright**: Browser automation and testing (stdio, bun)
- **octocode**: GitHub code exploration (stdio, bun)
- **gemini-cli**: Gemini CLI integration (stdio, bun)
- **codex-cli**: Codex CLI integration (stdio, bun)

### Serena MCP Server (Advanced Codebase Analysis)
**CRITICAL for CODE ANALYSIS** - provides semantic understanding beyond traditional file operations

Key Tools:
- `mcp__serena__find_symbol`: Global symbol search with semantic matching
- `mcp__serena__get_symbols_overview`: File structure analysis  
- `mcp__serena__search_for_pattern`: Pattern-based code search
- `mcp__serena__find_referencing_symbols`: Reference tracking
- `mcp__serena__replace_symbol_body`: Semantic code replacement
- `mcp__serena__write_memory`: Project knowledge management
- `mcp__serena__list_dir`: Intelligent directory listing

## AI Agents (Proactive - Run Automatically)

### Mandatory Agents (Auto-execute after code changes)
1. **test-runner**: Runs tests, linting, formatting - returns focused error lists
2. **code-reviewer**: Reviews code quality, security, architecture patterns
3. **code-commenter**: Adds "why-first" documentation and TSDoc comments

### On-demand Agents
4. **pr-creator**: PR creation and lifecycle management when requested
5. **repo-onboarder**: Repository analysis and documentation generation
6. **content-writer**: Technical writing in specific communication style

## Agent Usage Patterns
- Use Task tool to launch agents, not direct execution
- Agents return structured feedback for main thread to process
- Fix ALL errors before proceeding with other tasks
- Multiple agents can run concurrently for efficiency

## Environment Configuration
```json
{
  "ENABLE_BACKGROUND_TASKS": "1",
  "FORCE_AUTO_BACKGROUND_TASKS": "1", 
  "MCP_TIMEOUT": "30000",
  "MCP_TOOL_TIMEOUT": "600000",
  "MAX_MCP_OUTPUT_TOKENS": "50000"
}
```