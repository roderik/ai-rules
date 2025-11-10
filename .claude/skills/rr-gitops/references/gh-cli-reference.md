# GitHub CLI (gh) Reference

## Core Principle

**ALWAYS use `gh` for GitHub operations**. Never use the web UI or raw API calls when `gh` can handle it.

## Pull Requests

### Create PR

```bash
# Basic PR creation
gh pr create --title "Title" --body "Description"

# With HEREDOC for formatted body
gh pr create --title "Title" --body "$(cat <<'EOF'
## Summary
- Change 1
- Change 2

## Test plan
- [ ] Test 1
- [ ] Test 2

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"

# Interactive mode
gh pr create --web

# Set base branch
gh pr create --base main --head feature-branch

# Add reviewers
gh pr create --reviewer @user1,@user2

# Add assignees
gh pr create --assignee @user

# Add labels
gh pr create --label bug,urgent

# Add to project
gh pr create --project "Project Name"

# Mark as draft
gh pr create --draft
```

### View PR

```bash
# View PR in terminal
gh pr view 123

# View PR in browser
gh pr view 123 --web

# View current branch's PR
gh pr view

# View PR with comments
gh pr view 123 --comments

# View PR diff
gh pr diff 123
```

### List PRs

```bash
# List PRs
gh pr list

# Filter by state
gh pr list --state open
gh pr list --state closed
gh pr list --state merged
gh pr list --state all

# Filter by author
gh pr list --author @me
gh pr list --author username

# Filter by assignee
gh pr list --assignee @me

# Filter by label
gh pr list --label bug

# Limit results
gh pr list --limit 10
```

### Edit PR

```bash
# Edit PR title
gh pr edit 123 --title "New title"

# Edit PR body
gh pr edit 123 --body "New description"

# Edit with HEREDOC
gh pr edit 123 --body "$(cat <<'EOF'
Updated description
EOF
)"

# Add reviewers
gh pr edit 123 --add-reviewer @user

# Remove reviewers
gh pr edit 123 --remove-reviewer @user

# Add labels
gh pr edit 123 --add-label bug

# Remove labels
gh pr edit 123 --remove-label bug

# Add to project
gh pr edit 123 --add-project "Project Name"

# Convert to draft
gh pr ready 123 --undo

# Mark ready for review
gh pr ready 123
```

### PR Status

```bash
# Check PR status
gh pr status

# Check specific PR
gh pr checks 123

# Watch checks (live updates)
gh pr checks 123 --watch
```

### Review PR

```bash
# Start a review
gh pr review 123

# Approve PR
gh pr review 123 --approve

# Request changes
gh pr review 123 --request-changes --body "Please fix X"

# Comment on PR
gh pr review 123 --comment --body "Looks good"

# Add review comments
gh pr review 123 --comment --body "$(cat <<'EOF'
Comments:
- Issue 1
- Issue 2
EOF
)"
```

### Merge PR

```bash
# Merge PR (default strategy)
gh pr merge 123

# Merge with squash
gh pr merge 123 --squash

# Merge with rebase
gh pr merge 123 --rebase

# Merge and delete branch
gh pr merge 123 --delete-branch

# Auto-merge when checks pass
gh pr merge 123 --auto

# Merge with custom message
gh pr merge 123 --squash --body "Custom merge message"
```

### Close PR

```bash
# Close PR
gh pr close 123

# Close with comment
gh pr close 123 --comment "Reason for closing"

# Reopen PR
gh pr reopen 123
```

### Checkout PR

```bash
# Checkout PR locally
gh pr checkout 123

# Create new branch from PR
gh pr checkout 123 --branch new-branch-name
```

## Issues

### Create Issue

```bash
# Create issue
gh issue create --title "Title" --body "Description"

# With labels
gh issue create --title "Bug" --label bug,urgent

# With assignees
gh issue create --title "Task" --assignee @me

# With project
gh issue create --title "Feature" --project "Roadmap"
```

### View Issue

```bash
# View issue
gh issue view 456

# View in browser
gh issue view 456 --web

# View with comments
gh issue view 456 --comments
```

### List Issues

```bash
# List issues
gh issue list

# Filter by state
gh issue list --state open
gh issue list --state closed
gh issue list --state all

# Filter by author
gh issue list --author @me

# Filter by assignee
gh issue list --assignee @me

# Filter by label
gh issue list --label bug

# Limit results
gh issue list --limit 10
```

### Edit Issue

```bash
# Edit issue title
gh issue edit 456 --title "New title"

# Add labels
gh issue edit 456 --add-label bug

# Add assignees
gh issue edit 456 --add-assignee @user
```

### Close Issue

```bash
# Close issue
gh issue close 456

# Close with comment
gh issue close 456 --comment "Fixed in PR #789"

# Reopen issue
gh issue reopen 456
```

## GitHub Actions

### List Workflows

```bash
# List workflows
gh workflow list

# View specific workflow
gh workflow view workflow.yml
```

### List Runs

```bash
# List recent runs
gh run list

# Filter by workflow
gh run list --workflow=ci.yml

# Filter by status
gh run list --status=failure
gh run list --status=success

# Filter by branch
gh run list --branch=main

# Limit results
gh run list --limit 10
```

### View Run

```bash
# View run details
gh run view 123456

# View run in browser
gh run view 123456 --web

# View run logs
gh run view 123456 --log

# View specific job logs
gh run view 123456 --job=build --log
```

### Watch Run

```bash
# Watch run (live updates)
gh run watch 123456

# Get latest run and watch
gh run watch
```

### Rerun Workflow

```bash
# Rerun failed jobs
gh run rerun 123456

# Rerun all jobs
gh run rerun 123456 --all
```

### Cancel Run

```bash
# Cancel run
gh run cancel 123456
```

### Download Artifacts

```bash
# Download all artifacts
gh run download 123456

# Download specific artifact
gh run download 123456 --name artifact-name

# Download to specific directory
gh run download 123456 --dir ./artifacts
```

## Repository

### Clone

```bash
# Clone repository
gh repo clone owner/repo

# Clone to specific directory
gh repo clone owner/repo ./custom-dir

# Clone with submodules
gh repo clone owner/repo -- --recurse-submodules
```

### View

```bash
# View repository
gh repo view

# View specific repository
gh repo view owner/repo

# View in browser
gh repo view --web
```

### Fork

```bash
# Fork repository
gh repo fork

# Fork specific repository
gh repo fork owner/repo

# Fork and clone
gh repo fork owner/repo --clone
```

### Create

```bash
# Create repository
gh repo create my-repo --public

# Create private repository
gh repo create my-repo --private

# Create from template
gh repo create my-repo --template owner/template-repo
```

## Authentication

### Login

```bash
# Login via web
gh auth login

# Login with token
gh auth login --with-token < token.txt

# Check authentication status
gh auth status
```

### Logout

```bash
# Logout
gh auth logout
```

## Comments

### View Comments

```bash
# View PR comments
gh api repos/owner/repo/pulls/123/comments

# View issue comments
gh api repos/owner/repo/issues/456/comments
```

### Add Comment

```bash
# Comment on PR
gh pr comment 123 --body "Comment text"

# Comment on issue
gh issue comment 456 --body "Comment text"

# Comment with HEREDOC
gh pr comment 123 --body "$(cat <<'EOF'
Multi-line comment
- Point 1
- Point 2
EOF
)"
```

## Advanced Usage

### Get PR Number for Current Branch

```bash
# Get current PR number
gh pr view --json number --jq .number
```

### Check if PR Exists

```bash
# Check for PR
gh pr list --head $(git branch --show-current) --json number --jq '.[0].number'
```

### Get Latest Run ID

```bash
# Get latest run ID for workflow
gh run list --workflow=ci.yml --limit=1 --json databaseId --jq '.[0].databaseId'
```

### Wait for Checks

```bash
# Watch checks until completion
gh pr checks --watch

# Get checks status
gh pr checks --json state --jq '.[].state'
```

## Common Workflows

### Create PR and Watch CI

```bash
# Create PR
PR_URL=$(gh pr create --title "feat: new feature" --body "Description" --json url --jq .url)
echo "PR created: $PR_URL"

# Get PR number
PR_NUMBER=$(gh pr view --json number --jq .number)

# Wait for checks
gh pr checks $PR_NUMBER --watch

# Get latest run
RUN_ID=$(gh run list --limit=1 --json databaseId --jq '.[0].databaseId')

# Watch run
gh run watch $RUN_ID
```

### Update PR After Changes

```bash
# Push changes
git push

# Update PR description
gh pr edit --body "$(cat <<'EOF'
## Updated Summary
New changes added
EOF
)"

# Watch new checks
gh pr checks --watch
```

### Merge PR After Approval

```bash
# Check status
gh pr status

# Check reviews
gh pr view --json reviews --jq '.reviews[].state'

# Merge with squash
gh pr merge --squash --delete-branch
```
