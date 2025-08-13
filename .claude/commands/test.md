---
description: Run comprehensive quality checks (tests, linting, formatting) and automatically fix any failures found
---

You will:

1. Launch the @test-runner agent using Task tool with subagent_type="test-runner"
2. Parse the agent's error list (format: file:line - function() - issue)
3. For each error in the list:
   - Read the specific file
   - Navigate to the exact line number
   - Fix the issue using Edit or MultiEdit
4. After ALL fixes applied, launch test-runner agent again
5. Repeat until agent returns "✅ ALL CHECKS PASSED"

## Fix approach by error type:

- **Format errors**: Apply correct indentation/spacing per project rules
- **Lint errors**: Fix unused variables, missing returns, etc.
- **Test failures**: Analyze test expectations and fix implementation
- **Type errors**: Add/correct type annotations

Keep iterating: fix → test → fix → test until clean.
