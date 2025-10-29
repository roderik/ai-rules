---
description: Run diagnostics, tests, lint, typecheck, formatting—FIX all issues
---

## Workflow

1. IDE diagnostics for changed files (scope with `$ARGUMENTS`)
2. Run quality stack: `bun run test`, `lint`, `typecheck`, formatter
3. **FIX all failures immediately**
4. Re-run until everything passes
5. Report: "✓ All checks passing" or list blockers

## Scope

- `$ARGUMENTS` provided: focus on those paths
- Otherwise: prioritize changed files from `git status`
- Expand to full suite if scoped checks pass

## Error Handling

- Format: `file:line:function - message`
- Auto-fix lint/format issues
- Test failures: analyze with IDE, fix root cause
- Type errors: add proper types or fix mismatches

## Exit Criteria

- All tests passing
- Zero lint errors
- No type errors
- Code formatted
- If unfixable: explain why, request guidance
