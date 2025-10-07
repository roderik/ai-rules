Create a PR on GitHub

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

3. **Create PR**: Push branch and create PR via GitHub CLI
   - Title: Use `$ARGUMENTS` or generate from commits (semantic release format for the title)
   - Body: What/why, breaking changes, testing, tickets
   - Command: `gh pr create --title "..." --body "..."`

### Commands
```bash
git branch --show-current
git log main..HEAD --oneline
git diff main..HEAD --stat
git status
gh pr create --title "$TITLE" --body "$BODY"
```

### Exit Criteria
- All quality checks passing
- Critical code issues fixed
- PR created on GitHub
- PR URL displayed