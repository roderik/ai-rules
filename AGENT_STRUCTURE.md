# Agent Structure Documentation

## Overview

This repository uses a shared content architecture for AI agents to maintain consistency across multiple AI platforms (Claude, OpenCode, Gemini, Codex) while allowing platform-specific configurations.

## Directory Structure

```
.
├── .claude/agents/        # Claude-specific frontmatter
│   ├── code-reviewer.md   # Contains only YAML frontmatter
│   ├── test-runner.md
│   └── ...
│
├── .opencode/agents/      # OpenCode-specific frontmatter
│   ├── code-reviewer.md   # Enhanced frontmatter with permissions
│   ├── test-runner.md
│   └── ...
│
└── .shared/agents/        # Shared agent content (prompts)
    ├── code-reviewer.md   # Actual agent instructions
    ├── test-runner.md
    └── ...
```

## How It Works

1. **Frontmatter Files**: Platform-specific configuration
   - `.claude/agents/*.md` - Contains Claude-specific settings (name, model, color)
   - `.opencode/agents/*.md` - Contains OpenCode-specific settings (permissions, tools, temperature)

2. **Shared Content**: Common agent instructions
   - `.shared/agents/*.md` - Contains the actual agent prompts and instructions

3. **Installation Process**: The `install.sh` script combines them
   - Reads frontmatter from platform-specific folder
   - Appends content from shared folder
   - Writes combined file to target location

## Example

### Claude Frontmatter (.claude/agents/code-reviewer.md)
```yaml
---
name: code-reviewer
description: PROACTIVE agent for quality checks
model: opus
color: red
---
```

### OpenCode Frontmatter (.opencode/agents/code-reviewer.md)
```yaml
---
description: PROACTIVE agent for quality checks
mode: subagent
model: anthropic/claude-3-5-opus-20241022
temperature: 0.1
tools:
  write: false
  edit: false
permission:
  edit: deny
  bash: allow
---
```

### Shared Content (.shared/agents/code-reviewer.md)
```markdown
You are an elite code reviewer specializing in architecture validation...
[Full agent instructions here]
```

### Combined Result (After Installation)
```markdown
---
[Platform-specific frontmatter]
---

You are an elite code reviewer specializing in architecture validation...
[Full agent instructions]
```

## Benefits

1. **DRY Principle**: Agent logic written once, used everywhere
2. **Platform Optimization**: Each platform gets optimized configurations
3. **Easy Maintenance**: Update agent logic in one place
4. **Version Control**: Clear separation of config vs content

## Adding New Agents

1. Create the shared content file:
   ```bash
   touch .shared/agents/my-agent.md
   ```

2. Add Claude frontmatter:
   ```bash
   touch .claude/agents/my-agent.md
   ```

3. Add OpenCode frontmatter:
   ```bash
   touch .opencode/agents/my-agent.md
   ```

4. Run installation:
   ```bash
   ./install.sh
   ```

## Testing

Run the test script to verify structure integrity:
```bash
./test-install.sh
```

This validates:
- All required files exist
- Frontmatter files are properly formatted
- Shared content files have actual content
- Combination logic works correctly