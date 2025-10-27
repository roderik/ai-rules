---
description: Create a comprehensive pull request with proper title, description, and quality checks
---

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

3. **Analyze changes**: Review the diff to understand what changed
   ```bash
   git log main..HEAD --format="%s"
   git diff main..HEAD --stat
   git diff main..HEAD
   ```

4. **Generate PR**: Push branch and create PR via GitHub CLI
   - **Title**: Use `$ARGUMENTS` or generate from commits in format: `type(scope): description`
   - **Body**: Write comprehensive markdown using template below
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
git branch --show-current
git log main..HEAD --format="%s"
git diff main..HEAD --stat
git diff main..HEAD
gh pr create --title "TITLE" --body "BODY"
```

### Exit Criteria
- All quality checks passing
- Critical code issues fixed
- PR created on GitHub with well-formatted markdown body
- PR URL displayed