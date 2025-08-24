---
description: Add comprehensive documentation comments to code focusing on why-first explanations
agent: code-commenter
---

## Changed Files
Recent changes: !`git diff --name-only HEAD~1..HEAD`
Current status: !`git status --porcelain`

## Documentation Task

1. Focus on recently changed files (or files matching: $ARGUMENTS)
2. Add TSDoc comments to functions explaining the WHY behind decisions
3. Add inline comments for complex business logic
4. Document trade-offs and design decisions
5. Explain non-obvious algorithmic choices
6. Add context for security or performance considerations

Prioritize why-first explanations over what-the-code-does descriptions.