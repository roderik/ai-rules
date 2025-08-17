# CLAUDE.md

## Identity & Communication Style

- Be direct and concise - max 4 lines unless detail requested
- Skip preambles like "I'll help you..." or "Let me..."
- Action over explanation - do first, explain only if asked
- Never use emojis unless explicitly requested

## Coding Standards

### Documentation & Research (CRITICAL)

- MANDATORY: At the start of ANY code task, use context7 and octocode MCPs to fetch latest documentation
- For libraries/frameworks: Use `mcp__context7__resolve-library-id` then `mcp__context7__get-library-docs`
- For GitHub repos: Use `mcp__octocode__githubSearchCode` and `mcp__octocode__packageSearch`
- NEVER assume API syntax - ALWAYS verify with current documentation first

### General Principles

- Prefer editing existing files over creating new ones
- Never create documentation unless explicitly requested
- Follow existing code patterns and conventions in each project
- Always check for existing dependencies before suggesting new ones

### Code Style

- Use 2 spaces for indentation (except Python: 4 spaces)
- Keep functions under 30 lines when possible
- Descriptive variable names over comments
- Early returns over nested conditionals

### Git Workflow

- Branch naming: `feat/`, `fix/`, `chore/`, `docs/` prefixes
- Commit format: `type(scope): description` (conventional commits)
- Never commit directly to main/master
- Always run tests before suggesting commits (via test-runner agent ONLY)

## Common Commands & Aliases

### Frequently Used Commands

- Generic quality control check: Use test-runner agent via Task tool (NOT direct commands)
  - Build: `bun run build` (can be run directly for build-only tasks)
  - Test: MUST use test-runner agent - NEVER run `bun run test` directly
  - Lint: MUST use test-runner agent - NEVER run `bun run lint` directly
  - Type check: `bun run typecheck` (can be run directly for type-checking only)

### System Information

- Default shell: zsh
- Package manager preference: bun > pnpm > npm > yarn
- Editor: Cursor

## Tool Preferences

### Language-Specific

- JavaScript/TypeScript: Prefer modern ES6+ syntax, async/await over promises
- Python: Type hints for functions, use pathlib over os.path
- Shell: Prefer bash over sh, use shellcheck conventions

### Testing

- CRITICAL: ALWAYS use the test-runner agent for ALL test execution - NO EXCEPTIONS
- The test-runner agent MUST be invoked using Task tool after ANY code changes
- NEVER run `bun run test`, `npm test`, or any test commands directly via Bash
- Run tests after implementing features (via test-runner agent)
- Prefer unit tests with clear test names
- Mock external dependencies

## Security & Best Practices

- Never log or commit sensitive information
- Always validate user input
- Prefer environment variables for configuration
- Check dependencies for known vulnerabilities

## Personal Workflow Preferences

- Show me git diff before committing
- Run linting/formatting before showing final code
- When debugging, check logs first, then add targeted logging
- For performance issues, measure first, optimize second

## Multi-Model Collaboration Preferences

- Use Gemini for validation: `mcp__gemini_cli__ask_gemini --changeMode`
- Consult GPT-5 via codex for complex debugging
- You (Claude) handle all implementation

## Quick Reference Reminders

- Working on Mac/Linux/WSL environments primarily
- Prefer CLI tools over GUI applications
- Focus on automation and reproducibility
- Keep build times under 30 seconds when possible

## Tooling for shell interactions
Is it about finding FILES? use 'fd'
Is it about finding TEXT/strings? use 'rg'
Is it about finding CODE STRUCTURE? use 'ast-grep'
Is it about SELECTING from multiple results? pipe to 'fzf'
Is it about interacting with JSON? use 'jq'
Is it about interacting with YAML or XML? use 'yq'