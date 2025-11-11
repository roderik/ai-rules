# Git Commands Reference

## Basic Commands

### Status and Information

```bash
# Check working directory status
git status

# View commit history
git log

# Compact log view
git log --oneline --graph

# View recent commits
git log --oneline -5

# Show diff of changes
git diff

# Show staged changes
git diff --staged

# Show branches
git branch

# Show all branches (including remote)
git branch -a

# Show remotes
git remote -v

# Show current branch
git branch --show-current
```

## Branch Operations

### Creating Branches

```bash
# Create new branch
git branch feature-name

# Create and switch to branch
git checkout -b feature-name

# Branch naming conventions
git checkout -b feat/new-feature
git checkout -b fix/bug-name
git checkout -b chore/task-name
git checkout -b docs/documentation
```

### Switching Branches

```bash
# Switch to existing branch
git checkout branch-name

# Switch to previous branch
git checkout -
```

### Deleting Branches

```bash
# Delete merged branch (safe)
git branch -d branch-name

# Force delete branch (use with caution)
git branch -D branch-name
```

## Committing

### Adding Files

```bash
# Add specific file
git add path/to/file.ts

# Add multiple files
git add file1.ts file2.ts

# Add all changes (avoid - prefer explicit paths)
git add .

# Add files with special characters (quote them)
git add "src/app/[id]/page.tsx"
git add "src/(auth)/login.tsx"
```

### Creating Commits

```bash
# Basic commit
git commit -m "message"

# Commit with explicit file list (recommended)
git commit -m "message" -- path/to/file1.ts path/to/file2.ts

# Commit with quoted paths
git commit -m "message" -- "src/app/[id]/page.tsx" "src/(auth)/login.tsx"

# Multi-line commit with HEREDOC
git commit -m "$(cat <<'EOF'
feat(auth): implement OAuth2 flow

Add OAuth2 authentication with Google and GitHub providers.
EOF
)"
```

### Handling New Files

```bash
# Pattern for new files (ensures atomic commits)
git restore --staged :/  # Unstage everything
git add "path/to/new-file1.ts" "path/to/new-file2.ts"
git commit -m "feat: add new files" -- "path/to/new-file1.ts" "path/to/new-file2.ts"
```

### Amending Commits (Use with Caution)

```bash
# Amend last commit (only if not pushed and you're the author)
git commit --amend

# Amend without changing message
git commit --amend --no-edit

# Check authorship before amending
git log -1 --format='%an %ae'
```

## Pushing and Pulling

### Push Commands

```bash
# Push to remote
git push

# Push and set upstream
git push -u origin branch-name

# Push specific branch
git push origin branch-name

# Force push (USE WITH EXTREME CAUTION)
git push --force origin branch-name

# Safer force push
git push --force-with-lease origin branch-name
```

### Pull Commands

```bash
# Pull changes
git pull

# Pull with rebase
git pull --rebase

# Fetch without merging
git fetch

# Fetch all remotes
git fetch --all
```

## Rebase Operations

### Basic Rebase

```bash
# Rebase feature branch onto main
git checkout feature-branch
git rebase main

# Rebase with no editor
export GIT_EDITOR=:
export GIT_SEQUENCE_EDITOR=:
git rebase main --no-edit

# Continue rebase after resolving conflicts
git add resolved-files.ts
git rebase --continue

# Abort rebase
git rebase --abort

# Skip current commit
git rebase --skip
```

### Interactive Rebase (Use with Caution)

```bash
# Interactive rebase last N commits
git rebase -i HEAD~N

# Never use interactive rebase on:
# - main/master branch
# - Pushed commits
# - Commits authored by others
```

## Stashing

```bash
# Stash current changes
git stash

# Stash with message
git stash push -m "work in progress"

# List stashes
git stash list

# Apply most recent stash
git stash apply

# Apply and remove most recent stash
git stash pop

# Apply specific stash
git stash apply stash@{0}

# Drop stash
git stash drop

# Clear all stashes
git stash clear
```

## Undoing Changes

### Unstaging Files

```bash
# Unstage specific file
git restore --staged file.txt

# Unstage all files
git restore --staged :/
```

### Discarding Changes

```bash
# Discard changes in working directory (ask user first)
git restore file.txt

# Discard all changes (DANGEROUS - ask first)
git restore .
```

### Resetting Commits

```bash
# Undo last commit, keep changes (safe)
git reset --soft HEAD~1

# Undo last commit, unstage changes (safe)
git reset HEAD~1

# Undo last commit, discard changes (DANGEROUS - need permission)
git reset --hard HEAD~1

# Reset to specific commit (DANGEROUS - need permission)
git reset --hard <commit-hash>
```

## Viewing History

### Commit Information

```bash
# View commit details
git show <commit-hash>

# View file at specific commit
git show <commit-hash>:path/to/file

# View who changed what
git blame path/to/file

# View file history
git log -- path/to/file

# View changes in commit
git show <commit-hash>
```

### Reflog (Recovery)

```bash
# View reference log
git reflog

# Recover lost commits
git reflog
git checkout <commit-hash>
```

## Working with Remote

### Remote Management

```bash
# Add remote
git remote add origin https://github.com/user/repo.git

# Remove remote
git remote remove origin

# Rename remote
git remote rename old-name new-name

# Show remote details
git remote show origin

# Update remote URL
git remote set-url origin https://github.com/user/repo.git
```

### Tracking Branches

```bash
# Set upstream branch
git branch --set-upstream-to=origin/branch-name

# Push and set upstream
git push -u origin branch-name

# Show tracking branches
git branch -vv
```

## Conflict Resolution

### During Merge

```bash
# Check conflict status
git status

# View conflicts
git diff

# After resolving conflicts
git add resolved-file.ts
git commit -m "resolve merge conflicts"
```

### During Rebase

```bash
# After resolving conflicts
git add resolved-file.ts
git rebase --continue

# Skip problematic commit
git rebase --skip

# Abort rebase
git rebase --abort
```

## Tags

```bash
# Create tag
git tag v1.0.0

# Create annotated tag
git tag -a v1.0.0 -m "Release version 1.0.0"

# List tags
git tag

# Push tags
git push --tags

# Delete tag
git tag -d v1.0.0

# Delete remote tag
git push --delete origin v1.0.0
```

## Cleaning

```bash
# Remove untracked files (DANGEROUS - ask first)
git clean -fd

# Dry run (shows what would be deleted)
git clean -n

# Remove ignored files too
git clean -fdx
```

## Pre-Commit Validation Script

```bash
#!/bin/bash
# Pre-commit validation

# 1. Verify not on main
BRANCH=$(git branch --show-current)
if [ "$BRANCH" = "main" ] || [ "$BRANCH" = "master" ]; then
  echo "ERROR: Never commit directly to main/master"
  exit 1
fi

# 2. Check status
git status

# 3. Review diff
git diff --staged

# 4. Lint GitHub Actions workflows if modified
if git diff --staged --name-only | grep -q '.github/workflows/'; then
  echo "Linting GitHub Actions workflows..."
  actionlint || exit 1
fi

# 5. Run tests (implement based on project)
# npm test || exit 1

echo "Pre-commit checks passed"
```

## Safety Checklist

Before ANY commit:

- [ ] Verify current branch: `git branch --show-current`
- [ ] Not on main/master
- [ ] Review changes: `git diff --staged`
- [ ] Run tests and linting
- [ ] Use explicit file paths
- [ ] Quote special characters in paths
- [ ] Use conventional commit format

Before ANY destructive operation:

- [ ] Get explicit user permission
- [ ] Check authorship: `git log -1 --format='%an'`
- [ ] Verify not pushed: `git status`
- [ ] Consider safer alternatives
- [ ] Have recovery plan ready
