---
description: Run comprehensive quality checks using IDE diagnostics and traditional tests, automatically fix any failures found
allowed-tools: Bash, Read, Edit, mcp__ide__getDiagnostics, mcp__ide__executeCode
---

## Current Status

- Git status: !`git status --porcelain`
- Changed files: !`git diff --name-only HEAD`
- IDE diagnostics: !`mcp__ide__getDiagnostics`

## Your Task

Use IDE-enhanced quality checking with the test-runner subagent:

### 1. IDE Diagnostics First

- Use `mcp__ide__getDiagnostics` to get all workspace errors/warnings
- Focus on changed files but check entire workspace
- Report TypeScript/ESLint errors with precise locations

### 2. Traditional Testing

- Execute all tests and report any failures
- Run linting and fix any issues
- Run type checking and report errors
- Apply formatting fixes

### 3. Combined Reporting

- Merge IDE diagnostics with test results
- Report in file:line:function format
- Prioritize critical errors over warnings
- Suggest fixes based on LSP intelligence

Focus on files that have been changed recently, but use IDE to catch related issues.
