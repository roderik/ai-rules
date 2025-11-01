---
description: Create comprehensive PR with quality checks
---

## Gather Context (Pre-collect all data)

Current branch:
!`git branch --show-current`

Uncommitted changes:
!`git status --porcelain`

All changes vs main (committed + uncommitted):
!`git diff --stat main...HEAD`
!`git diff main...HEAD`

Committed changes:
!`git log main..HEAD --format="%s" --no-decorate`

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

3. **Commit all changes**: Create multiple small targeted commits combining related changes
   - Group related files together (e.g., feature + tests, docs + code, config + implementation)
   - Use conventional commit format: `type(scope): description`
   - Commit ALL uncommitted changes - nothing should remain uncommitted
   - Examples:
     - `feat(auth): add OAuth2 login flow`
     - `test(auth): add OAuth2 tests`
     - `docs(readme): update auth documentation`
     - `chore(config): update auth configuration`

4. **Create PR**
   ```bash
   git push
   gh pr create --title "TITLE" --body "BODY"
   ```

## Title Format

Use `$ARGUMENTS` or generate from ALL changes: `type(scope): description`
- Combine most relevant user/developer facing changes (limited length)

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
- ALL changes committed (no uncommitted files)
- Multiple small targeted commits created
- PR created with well-formatted body covering ALL changes
- PR URL displayed
