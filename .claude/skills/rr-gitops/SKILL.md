---
name: rr-gitops
description: Comprehensive Git and GitHub workflow management using conventional commits, atomic commits, gh CLI for all GitHub operations, and safe git practices. Use this skill for any git operation, commit creation, PR management, CI monitoring, or GitHub interaction. Essential for maintaining clean git history and professional GitHub workflows.
---

# GitOps Skill

Professional Git and GitHub workflow management with emphasis on safety, conventional commits, and GitHub CLI integration.

## When to Use This Skill

Use this skill for:

- Creating commits with proper conventional commit format
- Creating, viewing, editing, or managing pull requests
- Monitoring GitHub Actions CI/CD workflows
- Interacting with GitHub issues, comments, or reviews
- Any git operation requiring safety validation
- Branch management and git workflows
- Getting PR review comments and status
- Watching CI runs after PR creation or push

## Core Principles

### 1. Always Use GitHub CLI (gh)

**NEVER use web UI or raw API calls**. Use `gh` for all GitHub operations:

- Pull requests: `gh pr create`, `gh pr view`, `gh pr edit`
- Issues: `gh issue create`, `gh issue list`
- CI monitoring: `gh run watch`, `gh pr checks`
- Comments and reviews: `gh pr comment`, `gh pr review`

See `references/gh-cli-reference.md` for comprehensive command reference.

### 2. Conventional Commits

All commits MUST follow conventional commit format:

```
<type>(<scope>): <description>

[optional body]
```

**Common types**: feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert

Use HEREDOC format for proper formatting:

```bash
git commit -m "$(cat <<'EOF'
feat(auth): implement OAuth2 flow

Add OAuth2 authentication with Google and GitHub providers.
EOF
)"
```

See `references/conventional-commits.md` for detailed format and examples.

### 3. Atomic Commits

Commit only files you touched, with explicit paths:

```bash
# For tracked files
git commit -m "message" -- path/to/file1 path/to/file2

# For new files
git restore --staged :/
git add "path/to/file1" "path/to/file2"
git commit -m "message" -- "path/to/file1" "path/to/file2"
```

**Always quote** paths with brackets or parentheses:

```bash
git commit -m "message" -- "src/app/[id]/page.tsx" "src/(auth)/login.tsx"
```

### 4. Git Safety

**NEVER run destructive operations without explicit user permission:**

- ❌ `git reset --hard`
- ❌ `git push --force`
- ❌ `git commit --amend` (without approval)
- ❌ `git restore` on files authored by others
- ❌ Editing `.env` or secrets files

**Always safe:**

- ✓ `git status`, `git log`, `git diff`
- ✓ Creating branches
- ✓ Regular commits
- ✓ Pushing to feature branches

See `references/git-safety.md` for comprehensive safety guidelines.

### 5. Monitor CI After PR

**ALWAYS monitor CI runs** after creating PR or pushing changes:

```bash
# Create PR
gh pr create --title "Title" --body "Description"

# Get run ID
RUN_ID=$(gh run list --limit=1 --json databaseId --jq '.[0].databaseId')

# Watch CI run
gh run watch $RUN_ID
```

See `references/github-actions.md` for monitoring workflows.

## Standard Workflows

### Creating a Commit

```bash
# 1. Check status
git status

# 2. Verify branch (never commit to main)
BRANCH=$(git branch --show-current)
if [ "$BRANCH" = "main" ] || [ "$BRANCH" = "master" ]; then
  echo "ERROR: Never commit directly to main/master"
  exit 1
fi

# 3. Review changes
git diff

# 4. Commit with explicit file list
git commit -m "$(cat <<'EOF'
feat(feature): add new functionality

Detailed description of changes.
EOF
)" -- src/file1.ts src/file2.ts
```

### Creating a Pull Request

```bash
# 1. Ensure branch is pushed
git push -u origin $(git branch --show-current)

# 2. Create PR with formatted body
gh pr create --title "feat: title" --body "$(cat <<'EOF'
## Summary
- Change 1
- Change 2

## Test plan
- [x] Test 1
- [x] Test 2

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"

# 3. Watch CI
gh run watch
```

### Updating a PR

```bash
# 1. Make changes and commit
git add file.ts
git commit -m "fix: address review feedback" -- file.ts

# 2. Push changes
git push

# 3. Update PR description
gh pr edit --body "$(cat <<'EOF'
## Updated Summary
New changes added based on feedback
EOF
)"

# 4. Watch new CI run
gh run watch
```

### Monitoring CI/CD

```bash
# Check PR status
gh pr status

# Watch PR checks
gh pr checks --watch

# View specific run
gh run view 123456 --log

# Watch run live
gh run watch 123456

# View failed logs
gh run view 123456 --log-failed
```

### Linting GitHub Actions Workflows

**ALWAYS lint workflows before committing:**

```bash
# Lint all workflows
actionlint

# Lint specific workflow
actionlint .github/workflows/ci.yml

# Run in strict mode (fail on warnings)
actionlint -verbose

# Auto-fix issues (when available)
actionlint -format '{{json .}}'
```

**Common issues detected:**

- Invalid action versions or references
- Missing required inputs
- Deprecated syntax
- Shell script errors in run steps
- Invalid YAML structure
- Security issues (e.g., script injection)

**Integration with pre-commit:**
Actionlint runs automatically during pre-commit validation when workflow files are staged.

### Getting Review Comments

```bash
# View PR with comments
gh pr view 123 --comments

# View PR in browser
gh pr view 123 --web

# Check PR reviews
gh pr view 123 --json reviews --jq '.reviews[].state'

# List PR comments
gh api repos/:owner/:repo/pulls/123/comments
```

### Merging a PR

```bash
# 1. Verify all checks pass
gh pr checks

# 2. Verify reviews
gh pr view --json reviews

# 3. Merge (squash recommended)
gh pr merge --squash --delete-branch
```

## Branch Management

### Create Feature Branch

```bash
# Branch naming: feat/, fix/, chore/, docs/
git checkout -b feat/new-feature
```

### Never Commit to Main

```bash
# Always check current branch
CURRENT=$(git branch --show-current)
if [ "$CURRENT" = "main" ] || [ "$CURRENT" = "master" ]; then
  echo "Create a feature branch first"
  exit 1
fi
```

### Rebase Safely

```bash
# Avoid editor prompts
export GIT_EDITOR=:
export GIT_SEQUENCE_EDITOR=:

# Rebase feature branch
git rebase main --no-edit

# Never rebase public/main branches
```

## Pre-Commit Validation

Before ANY commit, run these checks:

```bash
# 1. Verify not on main
[ "$(git branch --show-current)" != "main" ] || exit 1

# 2. Check status
git status

# 3. Review diff
git diff --staged

# 4. Run tests/lint (via test-runner agent)
# Quality checks MUST pass before commit

# 5. Lint GitHub Actions workflows (if modified)
if git diff --staged --name-only | grep -q '.github/workflows/'; then
  actionlint
fi

# 6. Then commit
git commit -m "message" -- explicit-files.ts
```

## PR Content Standards

### PR Body Structure

```markdown
## Summary

- What changed
- Why it changed
- How it changed

## Test plan

- [ ] Unit tests added/updated
- [ ] Integration tests pass
- [ ] Manual testing performed

## Breaking changes

- List any breaking changes
- Include migration steps

## Screenshots

(if UI changes)

## Related

- Fixes #123
- Related to #456

🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

### Re-run PR Edit After Changes

Whenever commits or context change, update the PR:

```bash
gh pr edit --body "Updated description based on changes"
```

## GitHub CLI Usage Patterns

### Common PR Operations

```bash
# Create PR
gh pr create --title "Title" --body "Body"

# View PR
gh pr view 123

# Edit PR
gh pr edit 123 --title "New title"

# List PRs
gh pr list --state open

# Check PR status
gh pr status

# Check PR checks
gh pr checks 123

# Review PR
gh pr review 123 --approve
gh pr review 123 --comment --body "LGTM"

# Merge PR
gh pr merge 123 --squash

# Close PR
gh pr close 123
```

### Common Issue Operations

```bash
# Create issue
gh issue create --title "Title" --body "Body"

# View issue
gh issue view 456

# List issues
gh issue list

# Comment on issue
gh issue comment 456 --body "Comment"

# Close issue
gh issue close 456
```

### Common Workflow Operations

```bash
# List runs
gh run list

# View run
gh run view 123456

# Watch run
gh run watch 123456

# Rerun failed jobs
gh run rerun 123456

# Cancel run
gh run cancel 123456
```

## Multi-Agent Coordination

### Before Deleting/Reverting Files

```bash
# Check if other agents modified the file
git log -1 --format='%an' -- path/to/file

# If not you, STOP and coordinate
# Never delete others' work
```

### Atomic Commits in Shared Work

```bash
# Only commit your changes
git commit -m "message" -- your-file1.ts your-file2.ts

# NOT: git add . && git commit
```

## Error Handling

### CI Failures

```bash
# View failed jobs
gh run view --log-failed

# Investigate specific job
gh run view --job=test --log

# Fix and push
git add fixed-file.ts
git commit -m "fix(test): resolve test failures" -- fixed-file.ts
git push

# Monitor new run
gh run watch
```

### PR Conflicts

```bash
# Update branch from main
git fetch origin main
git rebase origin/main

# Resolve conflicts
# ... manual resolution ...

git add resolved-files.ts
git rebase --continue

# Force push (with approval)
git push --force-with-lease
```

## Quick Reference

### Commit Checklist

- [ ] Not on main/master branch
- [ ] Conventional commit format
- [ ] Explicit file paths provided
- [ ] Paths with brackets/parens quoted
- [ ] Quality checks passed
- [ ] Git status reviewed

### PR Checklist

- [ ] Feature branch created
- [ ] Commits follow conventions
- [ ] PR body is descriptive
- [ ] Tests added/updated
- [ ] CI monitored after creation
- [ ] Review comments addressed
- [ ] All checks passing
- [ ] Approved by reviewers

### Safety Checklist

- [ ] No force operations without approval
- [ ] No amend without approval
- [ ] No editing environment files
- [ ] No deleting others' work
- [ ] Verified current branch
- [ ] Reviewed changes before commit
- [ ] Coordinated with other agents

## Reference Files

This skill includes comprehensive reference documentation:

- **`references/conventional-commits.md`** - Detailed commit format guide with examples
- **`references/gh-cli-reference.md`** - Complete GitHub CLI command reference
- **`references/github-actions.md`** - CI/CD monitoring and interaction guide
- **`references/git-safety.md`** - Comprehensive safety guidelines and recovery commands
- **`references/pr-best-practices.md`** - PR quality guidelines, templates, and review practices

Load these references when detailed information is needed for specific operations.
