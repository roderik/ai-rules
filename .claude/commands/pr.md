---
description: Create a pull request with focused commits and Linear integration
argument-hint: [pr-title]
---

# Create Pull Request

## Context

- Current branch: !`git branch --show-current`
- Recent commits: !`git log origin/main..HEAD --oneline`
- Files changed: !`git diff --stat origin/main..HEAD`

## Your Task

When `/pr $ARGUMENTS` is invoked, execute these steps:

### 1. Branch Check

```bash
# Ensure not on protected branch
if [[ "$(git branch --show-current)" =~ ^(main|master)$ ]]; then
  echo "ERROR: Cannot create PR from main branch"
  exit 1
fi
```

### 2. Commit Strategy

Only make commits if on a feature branch:

```bash
current_branch=$(git branch --show-current)

# Only commit during work if on feature branch
if [[ "$current_branch" =~ ^(feat|fix|chore|docs|test|refactor)/ ]]; then
  # Make multiple small, focused commits
  git add <specific-files>
  git commit -m "feat(auth): add token refresh logic"

  git add <other-files>
  git commit -m "test(auth): add token refresh tests"

  git add <config-files>
  git commit -m "chore(config): update auth configuration"
else
  # On non-feature branch: stage changes but don't commit until PR time
  echo "Not on feature branch. Changes will be committed when PR is created."
fi
```

### 3. Identify Main Change

```bash
# Analyze commits to find the most significant change
# Usually the feat/fix commit, or the one with most changes
main_commit=$(git log origin/main..HEAD --oneline | grep -E "^[a-f0-9]+ (feat|fix)" | head -1)

# If no feat/fix, use the commit with most changes
if [ -z "$main_commit" ]; then
  main_commit=$(git log origin/main..HEAD --oneline --shortstat | head -1)
fi

# Extract title from main commit
title=$(echo "$main_commit" | sed 's/^[a-f0-9]* //')

# Get all commits for context
all_commits=$(git log origin/main..HEAD --oneline)
```

### 4. Generate PR Body

```bash
# Build comprehensive PR body following best practices
# Include Linear ticket if available from context
linear_section=""
if [ -n "${linearIssueId}" ]; then
  linear_section="## 🎯 Linear Issue
Resolves: [${linearIssueId}](${linearIssueUrl})

"
fi

body="${linear_section}## What does this PR do?
${title}

## Why are we making this change?
<!-- Describe the problem being solved or the feature being added -->
<!-- Link to any relevant issues, tickets, or discussions -->

## How does it work?
<!-- High-level overview of the implementation approach -->
<!-- Any architectural decisions or trade-offs made -->

## Changes included
\`\`\`
${all_commits}
\`\`\`

## Testing
- [ ] Unit tests added/updated
- [ ] Manual testing completed
- [ ] Edge cases considered

## Review checklist
- [ ] Code follows project conventions
- [ ] No unrelated changes included
- [ ] Documentation updated if needed
- [ ] Breaking changes documented

## Screenshots (if UI changes)
<!-- Add before/after screenshots if applicable -->

## Additional context
<!-- Any deployment considerations, performance impacts, or other notes for reviewers -->"
```

### 5. Create PR

```bash
gh pr create \
  --title "${title}" \
  --body "${body}" \
  --assignee @me
```

### 6. Linear Integration (if issue context exists)

```javascript
// If Linear issue was mentioned in conversation
if (linearIssueId) {
  // Get PR URL
  const prUrl = execSync("gh pr view --json url -q .url").toString().trim();

  // Update Linear
  await mcp__linear__update_issue({
    issueId: linearIssueId,
    state: "in review",
  });

  // Add PR link
  await mcp__linear__create_comment({
    issueId: linearIssueId,
    body: `PR: ${prUrl}`,
  });
}
```

## Commit Guidelines

Make small, focused commits:

- One logical change per commit
- Separate feature, test, and config changes
- Use conventional commit format:
  - `feat(scope): add new capability`
  - `fix(scope): resolve specific issue`
  - `test(scope): add/update tests`
  - `refactor(scope): improve code structure`
  - `chore(scope): update configs/deps`

## Quick Reference

**Expected behavior when user says "create a PR":**

1. Check branch (fail if on main)
2. If on feature branch (feat/_, fix/_, etc.): Multiple commits during work
3. If on other branch: Stage changes, commit when creating PR
4. Identify the main/most important change
5. Create PR with main change as title
6. Link to Linear if context exists
7. Return PR URL to user

**Commit behavior:**

- **Feature branches** (feat/_, fix/_, chore/\*, etc.): Make commits during work
- **Other branches**: Only stage changes, commit when PR is created

**Note:** Quality checks (CI) will run automatically on GitHub after PR creation.
