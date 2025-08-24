## IMPORTANT: Full Delegation to Agent

**This command ONLY delegates to the @test-runner agent. Do NOT perform any testing or analysis yourself.**

You will:

1. Launch the @test-runner agent using Task tool with subagent_type="test-runner"
2. Parse the agent's error list (format: file:line - function() - issue)
3. For each error in the list:
   - Read the specific file
   - Navigate to the exact line number
   - Fix the issue using Edit or MultiEdit
4. After ALL fixes applied, launch test-runner agent again
5. Repeat until agent returns "✅ ALL CHECKS PASSED"

## MCP-Enhanced Fix Approach by Error Type:

For EACH error, use MCP tools:

### Test Failures:

1. `mcp__context7__get-library-docs` for correct API usage
2. `mcp__octocode__githubSearchCode` for similar test patterns
3. `mcp__gemini-cli__ask-gemini --model gemini-2.5-pro` for logic validation
4. `mcp__sentry__search_events` for production correlation

### Lint/Type Errors:

1. `mcp__context7__resolve-library-id` for type definitions
2. `mcp__deepwiki__ask_question` for linting rules
3. `mcp__codex-cli__codex "Analyze this lint error and explain the root cause: [details]"`

## Original Fix Approach:

- **Format errors**: Apply correct indentation/spacing per project rules
- **Lint errors**: Fix unused variables, missing returns, etc.
- **Test failures**: Analyze test expectations and fix implementation
- **Type errors**: Add/correct type annotations

Keep iterating: fix → test → fix → test until clean.