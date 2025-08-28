---
description: IDE-enhanced comprehensive code review with LSP-powered security, performance, and best practices analysis
argument-hint: [focus-area]
allowed-tools: Bash, Read, mcp__ide__getDiagnostics, mcp__ide__executeCode
---

## Current Changes

- Git diff: !`git diff --stat`
- Recent commits: !`git log --oneline -5`
- IDE diagnostics summary: !`mcp__ide__getDiagnostics`

## IDE-Enhanced Review Task

Use the code-reviewer subagent with IDE intelligence to perform comprehensive review:

### 1. LSP-Powered Analysis

- Use `mcp__ide__getDiagnostics` for immediate error/warning detection
- Leverage IDE to understand symbol relationships and dependencies
- Check for unused imports, dead code, and unreachable statements

### 2. Traditional Review Areas

- Analyze all changed files for code quality issues
- Check for security vulnerabilities and potential risks
- Review performance implications and optimization opportunities
- Ensure adherence to coding standards and best practices
- Verify proper error handling and edge case coverage
- Check test coverage for new functionality

### 3. IDE-Specific Checks

- Type safety violations detected by LSP
- Missing documentation warnings from IDE
- Complexity metrics from language server
- Dependency cycle detection

Focus area: $ARGUMENTS

Provide actionable feedback organized by priority:

- 🔴 Critical (LSP errors + security issues)
- 🟡 Warnings (LSP warnings + code smells)
- 🔵 Suggestions (IDE hints + improvements)
