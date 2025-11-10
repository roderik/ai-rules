# GitHub Actions Workflows

## validate-skills.yml

Validates all skills in `.claude/skills/` using multiple approaches:

### What it validates

1. **SKILL.md structure** — Checks for valid YAML frontmatter with required fields (`name`, `description`)
2. **Naming conventions** — Validates hyphen-case naming (lowercase, hyphens only)
3. **Description format** — Ensures descriptions don't contain invalid characters
4. **openskills compatibility** — Tests that skills work with the openskills CLI
5. **Resource directories** — Validates structure of `references/`, `scripts/`, `assets/`

### When it runs

- On push to `main` or `feat/**` branches when skills change
- On pull requests that modify skills
- Manual trigger via workflow dispatch

### Local validation

Run validation locally before pushing:

```bash
# Validate all skills
./.github/validate-all.sh

# Or validate a specific skill
python3 .claude/skills/rr-skill-creator/scripts/quick_validate.py .claude/skills/rr-tanstack
```

### Requirements

- Python 3.11+
- Node.js 20+
- openskills CLI (installed via npm in workflow)
