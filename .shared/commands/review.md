# Code Review

## IMPORTANT: Full Delegation to Agent

**This command ONLY delegates to the @code-reviewer agent. Do NOT perform any analysis yourself.**

## Context

- Current git status: !`git status`
- Current git diff (staged and unstaged): !`git diff HEAD`
- Current branch: !`git branch --show-current`
- Recent commits: !`git log --oneline -10`

## Your Task

User focus request: $ARGUMENTS

Trigger the @code-reviewer agent to perform a comprehensive review of all current changes including unstaged, staged, and branch commits.

Simply invoke the code-reviewer agent using the Task tool:

```
If "$ARGUMENTS" is not empty:
  - Include "User focus request: $ARGUMENTS" at the beginning of the prompt
  - The agent will prioritize areas related to the focus

If "$ARGUMENTS" is empty:
  - Use the standard review prompt without the focus directive
  - The agent will perform a comprehensive standard review
```

The agent will prioritize reviewing areas related to the user's focus while still performing a comprehensive review.

The code-reviewer agent MUST (with mandatory MCP usage):

1. Gather repository context WITH `mcp__octocode__githubViewRepoStructure`
2. Collect diffs AND search similar with `mcp__octocode__githubSearchCode`
3. Fetch PR context AND related PRs with `mcp__octocode__githubSearchPullRequests`
4. Search Linear tickets WITH `mcp__linear__get_issue` (MANDATORY)
5. Fetch documentation WITH `mcp__context7__get-library-docs` (MANDATORY)
6. Search best practices WITH `mcp__deepwiki__ask_question` AND WebSearch
7. Check Sentry for patterns WITH `mcp__sentry__search_events` (MANDATORY)
8. MANDATORY multi-model: `mcp__gemini-cli__ask-gemini --model gemini-2.5-pro` + `mcp__codex-cli__codex` validation
9. Use ultrathink for complex sections
10. Output MCP-enriched comprehensive review

### Expected Output

The agent will provide:

- **Review Confidence Score**: Context completeness, analysis depth, validation status
- **Process Checklist**: Shows all completed review steps
- **Code Review Summary**: Strengths and issues found
- **Critical Issues**: Must-fix bugs, security flaws
- **Important Findings**: Performance and maintainability issues
- **Suggestions**: Style and minor optimizations
- **Specific Fix Templates**: Before/after code with explanations
- **Actionable Task List**: Prioritized fixes with file locations

## Output Handling

When the code-reviewer agent returns its results, process the output as follows:

1. **Check for Preserved Output Markers**: If the agent's response contains `===START-PRESERVED-OUTPUT===` and `===END-PRESERVED-OUTPUT===` markers:
   - Extract everything between these markers
   - Display it exactly as-is without any modification
   - This preserves the agent's visual formatting (Unicode boxes, progress bars, etc.)

2. **Handle Pretty Formats**: If the agent returns output with visual elements:
   - Unicode box characters (╔═╗║╚╝)
   - Progress bars (████████░░░░)
   - Visual separators (═══════)
   - Structured sections with emoji indicators
     Then display this formatting completely without summarizing or reformatting.

3. **Direct Display**: Simply output the agent's formatted report directly to the user.
   - Do not add explanations or summaries
   - Only add a terminal compatibility note if Unicode is used:
     ```
     Note: This output uses Unicode characters. Ensure your terminal supports UTF-8.
     ```

4. **Fallback**: If no special formatting is detected, display the agent's output normally.