---
description: Analyze repository structure and generate comprehensive AI agent documentation (CLAUDE.md) for efficient AI-assisted development
---

You will:

1. Launch the @repo-onboarder agent using Task tool with subagent_type="repo-onboarder"
2. The agent will analyze the repository and:
   - Create/update root CLAUDE.md with project overview, stack, and commands
   - Set up symlinks for GEMINI.md, AGENTS.md, and .github/copilot-instructions.md
   - For monorepos: generate package-specific CLAUDE.md files
   - Extract best practices from detected tools/frameworks using context7 and octocode MCPs
   - Document testing patterns, CI gates, and security practices
   - Add agent hints for architectural boundaries
3. Review the verification checklist provided by the agent
4. Confirm all documentation has been generated/updated successfully

## Key behaviors:

- **Preserve user content**: Updates only content between `<!-- BEGIN AUTO -->` and `<!-- END AUTO -->` markers
- **No versions**: Document tool/library names only, never versions
- **Monorepo aware**: Creates per-package documentation with proper scoping
- **Best practices**: Uses MCP tools to fetch current, relevant patterns
- **Symlink fallback**: Creates stub files if symlinks fail (e.g., Windows)

The agent follows the comprehensive spec in ~/.claude/agents/repo-onboarder.md for consistent, high-quality documentation.
