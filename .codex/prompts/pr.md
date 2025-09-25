---
description: Create a comprehensive pull request package with clean checks and reviewer-ready summary
argument-hint: [title]
---

## Command Playbook (Claude `/pr`)
- Branch: !`git branch --show-current`
- Commits since main: !`git log main..HEAD --oneline`
- Changed files: !`git diff main..HEAD --stat`

Follow the original sequence:
1. Run the full quality stack and resolve all failures.
2. Conduct a code review sweep covering quality, security, performance, and best practices.
3. Assemble and push a PR titled `$ARGUMENTS` with why/how/verification details using GitHub CLI.

## GPT-5 Role: Combined Test-Runner + Code-Reviewer
You are GPT-5 assuming the duties of both subagents. Guarantee clean gates, surface review feedback, and produce the final PR package.

### Quality Checks (Test-Runner Responsibilities)
1. Run IDE diagnostics across the workspace, prioritizing changed files.
2. Execute `bun run test`, `bun run lint`, `bun run typecheck`, formatter (or equivalents) until clean.
3. Report issues as `path:line:function - message`, including remediation notes.
4. Flag flaky tests, coverage gaps, or tooling problems for follow-up.

### Code Review Assessment (Code-Reviewer Responsibilities)
- **Review Categories**
  - Code Quality: readability, maintainability, consistency, documentation.
  - Security: input validation, authz, sensitive data exposure, dependency risks.
  - Performance: algorithmic efficiency, resource usage, network/database behaviors.
  - Architecture: separation of concerns, error handling, scalability, test coverage.
- **Process**
  1. Gather IDE diagnostics and inspect `git diff` with symbol navigation.
  2. Examine each modified file for unused code, missing error handling, or cross-file impact.
  3. Check that tests and docs exist or note gaps.
  4. Use multi-model analysis for validation when needed; they provide analysis only.
- **Feedback Format**
  - 🔴 Critical (must fix): breaking changes, security vulnerabilities, data integrity risks.
  - 🟡 Warnings (should fix): performance concerns, maintainability issues, missing handling.
  - 🔵 Suggestions (nice to have): style alignments, optimizations, abstractions.
- **Best Practices**
  - Provide precise line references and actionable fixes.
  - Consider broader codebase context and interface boundaries.
  - Be constructive and educational while remaining concise.

### PR Assembly
1. Ensure working tree is clean aside from intended changes.
2. Prepare PR title `$ARGUMENTS` and description covering:
   - What changed and why (with context for reviewers).
   - Breaking changes or migration notes.
   - Testing performed (list commands and results).
   - Relevant tickets/links, screenshots, or evidence.
3. Push the branch and use GitHub CLI (`gh pr create` / `gh pr edit`, re-run after updates).

## Deliverables
- Quality-check summary with remaining blockers called out.
- Review findings grouped under 🔴 / 🟡 / 🔵.
- Final PR title `$ARGUMENTS` and description ready for submission (or note if already submitted).
