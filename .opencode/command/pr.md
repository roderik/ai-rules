---
description: Create comprehensive PR with quality checks
---

## Workflow

1. **Quality gate** (FIX all failures)
   - Tests, lint, typecheck, formatting
   - IDE diagnostics for changed files
   - Keep running until clean

2. **Code review** (fix critical issues)
   - Security: input validation, auth, secrets
   - Performance: efficiency, resource usage
   - Quality: error handling, maintainability, docs
   - Architecture: test coverage, separation of concerns
   - Documentation: README.md, AGENTS.md, docs/* updated

3. **Analyze changes**
   ```bash
   git log main..HEAD --format="%s"
   git diff main..HEAD --stat
   git diff main..HEAD
   ```

4. **Create PR**
   ```bash
   gh pr create --title "TITLE" --body "BODY"
   ```

## Title Format

Use `$ARGUMENTS` or generate from commits: `type(scope): description`

Examples:
- `feat(auth): add OAuth2 login flow`
- `fix(api): handle null responses`
- `refactor(database): migrate to Prisma`
- `chore(deps): update typescript to 5.x`
- `docs(readme): add deployment instructions`

## Body Template

```markdown
## What
[Clear summary - be specific about files/features]

## Why
[Business/technical rationale - problem solved?]

## How
[Key implementation details and decisions]

## Breaking Changes
[List changes, or "None"]

## Related
- Fixes #[issue]
- Closes #[issue]
[Or "None"]
```

## Exit Criteria

- All quality checks passing
- Critical issues fixed
- PR created with well-formatted body
- PR URL displayed
