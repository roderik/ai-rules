# GEMINI.md

## Configuration Loading

On startup, read all CLAUDE.md files from current directory to project root:

1. Start in working directory
2. Check for CLAUDE.md in current folder
3. Walk up directory tree to project root (git root or filesystem root)
4. Load each CLAUDE.md found, with deeper files overriding higher-level ones
5. Apply user's global ~/.claude/CLAUDE.md if exists (highest priority)

## CLAUDE.md Inheritance

Priority order (highest to lowest):

1. User's global: ~/.claude/CLAUDE.md
2. Project root: /path/to/project/CLAUDE.md
3. Parent directories: ../CLAUDE.md (each level up)
4. Current directory: ./CLAUDE.md

Merge strategy: Later files override earlier ones, section by section.

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
- Always run tests before suggesting commits

## Common Commands & Aliases

### Frequently Used Commands

- Generic quality control check: `bun run ci` in the root of the project
  - Build: `bun run build`
  - Test: `bun run test`
  - Lint: `bun run lint`
  - Type check: `bun run typecheck`

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

- Run tests after implementing features
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

- Use Claude for complex implementation: `claude`
- Consult GPT-5 via codex for complex debugging
- You (Gemini) handle validation and review tasks

## Quick Reference Reminders

- Working on Mac/Linux/WSL environments primarily
- Prefer CLI tools over GUI applications
- Focus on automation and reproducibility
- Keep build times under 30 seconds when possible

## Important Reminders

- Do what has been asked; nothing more, nothing less
- NEVER create files unless they're absolutely necessary
- ALWAYS prefer editing an existing file to creating a new one
- NEVER proactively create documentation files (\*.md) or README files

## Tooling for shell interactions

**CRITICAL**: This system uses MODERN TOOLS ONLY. Traditional commands are ALIASED to modern alternatives.
**WARNING**: Parameter syntax DIFFERS from traditional tools. ALWAYS use the modern tool syntax.

### MANDATORY Tool Usage:

- Finding FILES? **USE `fd`** (NOT find - even though `find` is aliased to `fd`)
- Finding TEXT/strings? **USE `rg`** (NOT grep - even though `grep` is aliased to `rg`)
- Finding CODE STRUCTURE? **USE `ast-grep`**
- SELECTING from results? **PIPE TO `fzf`**
- Interacting with JSON? **USE `jq`**
- Interacting with YAML/XML? **USE `yq`**

## Modern Tool Aliases (IMPORTANT: TRADITIONAL COMMANDS ARE ALIASED)

**⚠️ CRITICAL: The traditional commands below are ALIASED to modern tools. Using `ls` actually runs `eza`, using `cat` runs `bat`, etc.**
**⚠️ ALWAYS use the modern tool's syntax and parameters, NOT the traditional command's syntax.**

This system has modern alternatives installed and ALIASED:

| Modern Tool | Description                                  | ALIASED FROM (⚠️)  | Additional Info        |
| ----------- | -------------------------------------------- | ------------------ | ---------------------- |
| neovim/nvim | Modern Vim with LazyVim configuration        | vim (ALIASED)      | Also aliased as 'n'    |
| bat         | Syntax highlighting and Git integration      | cat (ALIASED)      | Plain style by default |
| eza         | Modern listing with icons and git status     | ls, tree (ALIASED) | Multiple ls aliases    |
| ripgrep/rg  | Ultra-fast text search                       | grep (ALIASED)     | Use rg syntax only!    |
| fd          | User-friendly file finder                    | find (ALIASED)     | Use fd syntax only!    |
| fzf         | Fuzzy finder for files and history           | -                  | Integrated with bat    |
| lazygit     | Terminal UI for git commands                 | -                  | Aliases: lg, lzg       |
| lazydocker  | Terminal UI for docker management            | -                  | Aliases: ld, lzd       |
| fnm         | Fast Node.js version manager                 | -                  | Replaces nvm           |
| git-delta   | Beautiful git diffs with syntax highlighting | -                  | Auto-configured        |
| hexyl       | Hex viewer with colored output               | hexdump (ALIASED)  | Alias: hex             |
| procs       | Modern process viewer                        | ps (ALIASED)       | Aliases: pst, psw      |
| broot       | Interactive tree view with search            | -                  | Has br launcher        |
| zoxide      | Smarter directory navigation                 | -                  | NOT aliased to cd      |
| atuin       | Better shell history with sync               | -                  | Auto-initialized       |
| direnv      | Per-project environment variables            | -                  | Auto-initialized       |
| chafa       | Terminal graphics viewer                     | -                  | Aliases: img, image    |
| ast-grep    | Structural code search/replace               | -                  | Aliases: ag, ags, agr  |
| starship    | Cross-shell prompt                           | -                  | If installed           |
| tmux        | Terminal multiplexer                         | -                  | Various tm\* aliases   |
| zellij      | Modern terminal multiplexer                  | -                  | Aliases: zj, zja, zjs  |
| tilt        | Local Kubernetes development                 | -                  | Aliases: tu, td        |
| uv          | Python package/project manager               | -                  | Aliases: uvs, uvi, uvr |
| op          | 1Password CLI                                | -                  | Auto-integrated        |
| forge/cast  | Foundry blockchain tools                     | -                  | Multiple aliases       |

### ⚠️ CRITICAL REMINDERS:

1. **NEVER use traditional command syntax** - Even though `ls` exists, it's actually `eza`
2. **ALWAYS use modern tool parameters** - `fd` syntax NOT `find` syntax
3. **When in doubt, use the modern tool directly** - Use `eza` instead of `ls`, `bat` instead of `cat`
4. **Examples of CORRECT usage:**
   - `fd . -t f` (NOT `find . -type f`)
   - `rg "pattern"` (NOT `grep "pattern"`)
   - `eza -la` (NOT `ls -la` even though it might work)
   - `bat file.txt` (NOT `cat file.txt` even though it's aliased)
