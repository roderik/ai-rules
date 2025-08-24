---
description: Run comprehensive quality checks (tests, linting, formatting) and automatically fix any failures found
agent: test-runner
---

## Current Status
Current git status: !`git status --porcelain`
Changed files: !`git diff --name-only HEAD`

## Your Task

1. Execute all tests and fix any failures (typically `bun run ci` will run all required tasks)
2. Run linting and fix any issues
3. Run type checking and report errors
4. Apply formatting fixes
5. Report results with file:line:function format for any remaining issues

