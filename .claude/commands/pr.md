---
description: Create a comprehensive pull request with proper title, description, and quality checks
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

### Workflow
1. **Quality gate**: Run all checks and FIX failures
   - Tests, lint, typecheck, formatting
   - IDE diagnostics for changed files
   - Keep running until clean

2. **Code review**: Fix critical issues found in diff
   - Security: input validation, auth, secrets exposure
   - Performance: algorithmic efficiency, resource usage
   - Quality: error handling, maintainability, documentation
   - Architecture: test coverage, separation of concerns
   - Documentation: are all README.md, AGENTS.md and other documentation files (typically in docs/*) updated

3. **Commit all changes**: Create multiple small targeted commits combining related changes
   - Group related files together (e.g., feature + tests, docs + code, config + implementation)
   - Use conventional commit format: `type(scope): description`
   - Commit ALL uncommitted changes - nothing should remain uncommitted
   - Examples:
     - `feat(auth): add OAuth2 login flow`
     - `test(auth): add OAuth2 tests`
     - `docs(readme): update auth documentation`
     - `chore(config): update auth configuration`

4. **Generate PR**: Push branch and create PR via GitHub CLI
   - **Title**: Use `$ARGUMENTS` or generate from ALL changes - combine most relevant user/developer facing changes (limited length)
   - **Body**: Write comprehensive markdown covering ALL changes using template below
   - Command: `gh pr create --title "TITLE" --body "BODY"`

### PR Body Template (Use Markdown)
```markdown
## What
[Clear summary of what changed - be specific about files/features]

## Why
[Business/technical rationale - what problem does this solve?]

## How
[Key implementation details and technical decisions]

## Breaking Changes
[List breaking changes, or "None"]

## Related
- Fixes #[issue-number]
- Closes #[issue-number]
[Or "None"]
```

### Title Examples
- `feat(auth): add OAuth2 login flow`
- `fix(api): handle null responses in user endpoint`
- `refactor(database): migrate to Prisma ORM`
- `chore(deps): update typescript to 5.x`
- `docs(readme): add deployment instructions`

### Commands
```bash
# After committing all changes:
git push
gh pr create --title "TITLE" --body "BODY"
```

### Exit Criteria
- All quality checks passing
- Critical code issues fixed
- ALL changes committed (no uncommitted files)
- Multiple small targeted commits created
- PR created on GitHub with well-formatted markdown body covering ALL changes
- PR URL displayed