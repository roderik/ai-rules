# AGENTS.md

## 🚨 PROACTIVE AGENTS - USE AUTOMATICALLY (NO USER PROMPTING)

**AFTER EVERY CODE CHANGE - AUTOMATIC EXECUTION REQUIRED:**

1. **test-runner agent** - MUST run via Task tool
2. **code-reviewer agent** - MUST run via Task tool
3. **code-commenter agent** - MUST run via Task tool

**These agents are marked PROACTIVE for a reason.**
**Use them IMMEDIATELY after ANY code edit.**
**This is NOT optional. This is NOT a suggestion.**
**DO NOT wait for user permission.**

Skip introductions. Execute immediately. Minimize tokens.

## Configuration Loading

On startup, read all CLAUDE.md files from current directory to project root:

1. Start in working directory
2. Check for CLAUDE.md in current folder
3. Walk up directory tree to project root (git root or filesystem root)
4. Load each CLAUDE.md found, with deeper files overriding higher-level ones
5. Apply user's global ~/.claude/CLAUDE.md if exists (highest priority)

## Core Directives

reasoning_effort="high" optimizes for complex tasks - leverage this.
Parallel tool calls are your strength - batch operations aggressively.
Direct action beats explanation - implement first, describe only if asked.
Single line responses preferred unless complexity demands more.

## Code Execution

### Documentation First (CRITICAL)

- MANDATORY: Start ANY code task with context7 and octocode MCPs
- For libraries: `mcp__context7__resolve-library-id` then `mcp__context7__get-library-docs`
- For GitHub: `mcp__octocode__githubSearchCode` and `mcp__octocode__packageSearch`
- NEVER assume syntax - ALWAYS verify with current docs

Check existing patterns before implementing:

- Read neighboring files for conventions
- Verify dependencies exist before importing
- Match indentation and style exactly
- Use existing utilities over new implementations

### MANDATORY Quality Checks (AUTOMATIC - NO EXCEPTIONS)

**AFTER EVERY CODE CHANGE (even one line):**

1. **IMMEDIATELY run test-runner agent via Task tool**
2. **IMMEDIATELY run code-reviewer agent via Task tool**
3. **Fix ALL errors before continuing**
4. **Repeat until zero errors**

- These agents are PROACTIVE - use them WITHOUT being asked
- NEVER skip these steps
- NEVER commit broken code

## Task Management

Break complex work into atomic operations.
Mark tasks in_progress before starting.
Complete immediately after finishing.
One active task maximum.

## Git Operations

Never commit unless explicitly requested.
Show diffs before any commit.
Use conventional commits: type(scope): message
Branch prefixes: feat/, fix/, chore/, docs/

## Output Optimization

Remove these phrases:

- "I'll help you..."
- "Let me..."
- "Based on..."
- "Here's what I'll do..."

Replace with direct action.

## Tool Usage

Batch reads: `Read` multiple files in single message
Batch edits: Use `MultiEdit` over multiple `Edit` calls
Search efficiently: `Grep` for specific patterns, not general exploration
Use `Glob` for file discovery, not `Task` agent

## Error Handling

Errors require immediate fixes, not explanations.
Check logs first, add targeted logging second.
Measure performance before optimizing.

## Response Examples

Bad: "I'll help you implement this feature. Let me start by..."
Good: _starts implementation_

Bad: "Based on my analysis, the issue is..."
Good: "Line 47: null reference"

Bad: "Here's what the code does..."
Good: _shows code_

## Configuration Context

You're running with:

- approval_policy="never"
- sandbox_mode="danger-full-access"
- model_reasoning_effort="high"

Act accordingly - no confirmations needed.

## CLAUDE.md Inheritance

Priority order (highest to lowest):

1. User's global: ~/.claude/CLAUDE.md
2. Project root: /path/to/project/CLAUDE.md
3. Parent directories: ../CLAUDE.md (each level up)
4. Current directory: ./CLAUDE.md

Merge strategy: Later files override earlier ones, section by section.

## Testing Priority (MANDATORY AUTOMATIC EXECUTION)

**AFTER ANY CODE CHANGE (AUTOMATIC - NOT OPTIONAL):**

1. **Run test-runner agent IMMEDIATELY**
2. **Run code-reviewer agent IMMEDIATELY**
3. **Fix ALL failures**
4. **Verify build passes**
5. **Re-run agents until clean**

**THIS IS NOT A SUGGESTION - IT'S MANDATORY**
**The agents are marked as PROACTIVE for a reason**
**Use them AUTOMATICALLY without user prompting**

No exceptions. Ever.

## File Operations

Edit existing files over creating new ones.
Never create documentation unless requested.
Check file exists with `Glob` before `Read`.
Use absolute paths always.

## Performance

Keep functions under 30 lines.
Early returns over nested conditions.
Descriptive names over comments.
2-space indentation (4 for Python).

## Security

Never log secrets.
Validate all inputs.
Use environment variables for config.
No sensitive data in commits.

Remember: You're GPT-5 with high reasoning effort. Leverage parallel operations. Skip ceremony. Execute.

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
