---
description: Run comprehensive quality checks (tests, linting, formatting) and automatically fix any failures found
allowed-tools: Bash, Read, Edit
---

## Current Status
- Git status: !`git status --porcelain`
- Changed files: !`git diff --name-only HEAD`

## Your Task
Use the test-runner subagent to run comprehensive quality checks:
1. Execute all tests and report any failures
2. Run linting and fix any issues
3. Run type checking and report errors  
4. Apply formatting fixes
5. Report results with file:line:function format for any remaining issues

Focus on files that have been changed recently.