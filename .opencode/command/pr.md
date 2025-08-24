---
description: Create a comprehensive pull request with proper title, description, and quality checks
agent: pr-creator
---

## Current Branch Status
Branch: !`git branch --show-current`
Commits since main: !`git log main..HEAD --oneline`
Changed files: !`git diff main..HEAD --stat`

## Pull Request Creation Task

1. Run all tests and fix any failures
2. Run linting and fix issues
3. Ensure code formatting is correct

Finally, create the pull request with:
- Title: $ARGUMENTS or the main change of this pr.
- Comprehensive description including:
  - What changes were made and why
  - Any breaking changes or migration notes
  - Testing approach used
  - Screenshots/examples if relevant

Push branch and create PR using GitHub CLI if available.