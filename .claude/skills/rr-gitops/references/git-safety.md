# Git Safety Guidelines

## Destructive Operations - EXTREME CAUTION

These commands are **CATASTROPHIC** and should **NEVER** be run without explicit, written user instruction:

### Never Run Without Explicit Permission

```bash
# DANGEROUS: Hard reset
git reset --hard

# DANGEROUS: Force checkout to older commit
git checkout <old-commit>
git restore --source=<old-commit>

# DANGEROUS: Remove untracked files
rm -rf *
git clean -fd

# DANGEROUS: Force push
git push --force
git push --force-with-lease  # Slightly safer but still dangerous

# DANGEROUS: Delete branch
git branch -D branch-name

# DANGEROUS: Rewrite history
git rebase -i
git commit --amend  # Only with explicit approval

# DANGEROUS: Reset to remote
git reset --hard origin/main
```

### Force Push Special Cases

```bash
# NEVER force push to main/master
git push --force origin main  # ❌ FORBIDDEN

# Force push to feature branch: warn first
# Only proceed if user explicitly approves
git push --force origin feature-branch  # ⚠️ Get approval

# Safer alternative: force-with-lease
git push --force-with-lease origin feature-branch  # ⚠️ Still get approval
```

## Safe Operations

### Checking State (Always Safe)

```bash
# Always safe to check status
git status
git log
git diff
git branch
git branch -a
git remote -v
git log --oneline --graph
```

### Non-Destructive Operations

```bash
# Creating new branches
git branch new-feature
git checkout -b new-feature

# Committing changes
git add file.txt
git commit -m "message"

# Pushing to feature branches
git push origin feature-branch

# Fetching updates
git fetch
git fetch --all
```

## Working with Other Agents

### Never Revert Other Agents' Work

When multiple agents or developers are working:

```bash
# ❌ WRONG: Reverting files without coordination
git restore path/to/file.ts  # May delete other agent's work

# ✓ CORRECT: Check before reverting
git status
# If file was modified by another agent/developer, stop and coordinate
```

### Atomic Commits

Only commit files you touched:

```bash
# ❌ WRONG: Commit everything
git add .
git commit -m "changes"

# ✓ CORRECT: Explicit file list
git commit -m "feat(auth): add login" -- src/auth/login.ts src/auth/types.ts
```

### Handling New Files

```bash
# For brand new files, use this pattern:
git restore --staged :/  # Unstage everything
git add "path/to/new-file1.ts" "path/to/new-file2.ts"
git commit -m "feat: add new files" -- "path/to/new-file1.ts" "path/to/new-file2.ts"
```

### Quote Special Characters

```bash
# Paths with brackets need quotes
git add "src/app/[candidate]/page.tsx"
git commit -m "message" -- "src/app/[candidate]/page.tsx"

# Paths with parentheses need quotes
git add "src/(auth)/login.tsx"
git commit -m "message" -- "src/(auth)/login.tsx"
```

## Rebase Safety

### Avoid Interactive Editors

```bash
# ❌ WRONG: Opens editor
git rebase main

# ✓ CORRECT: Avoid editor
export GIT_EDITOR=:
export GIT_SEQUENCE_EDITOR=:
git rebase main

# Or use --no-edit flag
git rebase main --no-edit
```

### Never Rebase Public Branches

```bash
# ❌ WRONG: Rebase main
git checkout main
git rebase feature

# ✓ CORRECT: Merge into main
git checkout main
git merge feature
```

## Amend Safety

### Never Amend Without Permission

```bash
# Only amend commits with explicit written approval
git commit --amend

# Check authorship first
git log -1 --format='%an %ae'

# Check if pushed
git status  # Should show "Your branch is ahead"
```

### Safe Amend Workflow

```bash
# 1. Verify you own the commit
AUTHOR=$(git log -1 --format='%an')
if [ "$AUTHOR" != "Your Name" ]; then
  echo "Not your commit, don't amend"
  exit 1
fi

# 2. Verify not pushed
git status | grep "Your branch is ahead" || {
  echo "Commit already pushed, don't amend"
  exit 1
}

# 3. Only then amend
git commit --amend --no-edit
```

## Environment File Safety

### Never Edit Environment Files

```bash
# ❌ FORBIDDEN: Never edit these
.env
.env.local
.env.production
credentials.json
secrets.yaml
config/secrets.yml

# Only user may modify these files
# If changes are needed, tell user and stop
```

## Pre-Commit Checks

### Always Verify Before Commit

```bash
# 1. Check status
git status

# 2. Review diff
git diff --staged

# 3. Verify branch
git branch --show-current

# 4. Verify not on main
if [ "$(git branch --show-current)" = "main" ]; then
  echo "Don't commit to main!"
  exit 1
fi

# 5. Then commit
git commit -m "message" -- file1.ts file2.ts
```

## Recovery Commands (Safe)

### If You Made a Mistake

```bash
# Undo last commit (keeps changes)
git reset --soft HEAD~1

# Undo staging
git restore --staged file.txt

# Discard working directory changes (ask first)
git restore file.txt

# See reflog for history
git reflog
```

### Stashing Changes

```bash
# Safe: Stash current changes
git stash

# List stashes
git stash list

# Apply stash
git stash apply
git stash pop

# Drop stash
git stash drop
```

## Protection Rules

### Pre-Flight Checks

Before ANY git operation:

1. **Check current branch**: `git branch --show-current`
2. **Verify clean state**: `git status`
3. **Review what will change**: `git diff`
4. **Confirm with user if uncertain**

### When to Stop and Ask

Stop and ask user if:

- About to delete files not authored by you
- About to force push
- About to amend a commit
- About to rebase
- About to modify environment files
- About to run any "hard" or "force" command
- Uncertain about the safety of an operation

### Coordination Protocol

When multiple agents are working:

1. **Check for concurrent work**: `git status`
2. **Review recent commits**: `git log --oneline -5`
3. **If other agents have commits**, coordinate before:
   - Reverting changes
   - Deleting files
   - Force operations
   - Branch operations

## Cursor/Codex Web Exception

When working within Cursor IDE or Codex Web, these git limitations do not apply. Use the tooling's built-in capabilities as needed, as these environments provide safety guardrails.
