Run diagnostics, tests, lint, typecheck, and formatting—then FIX all issues automatically.

### Workflow
1. Check IDE diagnostics for changed files (use `$ARGUMENTS` to scope if provided)
2. Run quality stack: `bun run test`, `bun run lint`, `bun run typecheck`, formatter
3. **FIX all failures immediately** - don't just report them
4. Re-run checks until everything passes
5. Report final status: "✓ All checks passing" or list remaining blockers

### Scope
- If `$ARGUMENTS` provided: focus on those paths/patterns
- Otherwise: prioritize changed files from `git status`
- Expand to full suite if scoped checks pass

### Error Handling
- Format each issue: `file:line:function - message`
- Apply automated fixes for lint/format issues
- For test failures: analyze with IDE context and fix root cause
- For type errors: add proper types or fix type mismatches

### Exit Criteria
- All tests passing
- Zero lint errors
- No type errors
- Code formatted
- If unfixable blockers remain: explain why and request guidance
