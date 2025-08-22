# Task Completion Requirements

## MANDATORY AUTOMATIC AGENTS (CRITICAL)

**AFTER ANY CODE CHANGE, YOU MUST AUTOMATICALLY RUN:**

1. **test-runner agent** (via Task tool) - Runs tests, linting, formatting
2. **code-reviewer agent** (via Task tool) - Reviews code quality  
3. **code-commenter agent** (via Task tool) - Adds documentation

**These are PROACTIVE agents - they MUST run AUTOMATICALLY after EVERY code edit.**
**DO NOT wait for the user to ask. DO NOT skip for "small" changes.**
**Fix ALL errors before proceeding with ANY other task.**

## Quality Control Process

### Before Any Commit
1. **MANDATORY**: Run test-runner AND code-reviewer agents
2. **DO NOT commit** if agents report errors - fix them first
3. Show git diff before committing
4. Use conventional commit format: `type(scope): description`

### Testing Strategy
- **NEVER** run `bun run test`, `npm test`, or test commands directly via Bash
- **ALWAYS** use test-runner agent via Task tool
- Agents return focused error lists with file:line:function format
- Continue running agents until ALL errors are resolved
- Prefer unit tests with clear test names
- Mock external dependencies

### Code Quality Standards
- Run linting/formatting before showing final code
- When debugging, check logs first, then add targeted logging
- For performance issues, measure first, optimize second
- Validate all user input
- Check dependencies for known vulnerabilities

## Multi-Model Collaboration

**CRITICAL**: Other models provide analysis/insights ONLY - Claude does ALL coding/implementation

- **Gemini (Analysis Only)**: `mcp__gemini-cli__ask-gemini` for validation and analysis
- **GPT-5 (Analysis Only)**: `mcp__codex-cli__codex` for debugging insights
- **Claude**: Handle ALL implementation, coding, writing, and file modifications

## Tool Usage Requirements
- Use modern tools (fd, rg, eza, bat) with correct syntax
- Use Serena MCP tools for semantic code analysis
- MANDATORY: Use `mcp__serena__find_symbol` and related tools for code structure work
- Never create documentation unless explicitly requested