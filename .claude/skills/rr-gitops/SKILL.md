---
name: rr-gitops
description: Comprehensive Git and GitHub workflow management using conventional commits, atomic commits, gh CLI for all GitHub operations, and safe git practices. Use this skill for any git operation, commit creation, PR management, CI monitoring, or GitHub interaction. Also triggers when working with .git files, GitHub Actions workflows (.yml, .yaml in .github/workflows/), or when performing git operations. Example triggers: "Create a commit", "Make a pull request", "Check CI status", "Watch GitHub Actions", "Create PR", "Fix commit message", "Monitor CI run", "Get PR comments"
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

**NEVER use web UI or raw API calls**. Use `gh` for all GitHub operations.

See `references/gh-cli-reference.md` for comprehensive command reference.

### 2. Conventional Commits

All commits MUST follow conventional commit format:

```
<type>(<scope>): <description>

[optional body]
```

**Common types**: feat, fix, docs, style, refactor, perf, test, build, ci, chore, revert

Example with HEREDOC:

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

See `references/git-safety.md` for comprehensive safety guidelines.

### 5. Monitor CI After PR

**ALWAYS monitor CI runs** after creating PR or pushing changes:

```bash
# Create PR
gh pr create --title "Title" --body "Description"

# Watch CI run
gh run watch
```

See `references/github-actions.md` for monitoring workflows.

## Development Workflow

### Plan → Validate → Execute Pattern

#### Phase 1: PLAN

Before any git operation, validate:

**Pre-Commit Checklist:**

- [ ] Not on main/master branch
- [ ] Reviewed changes with `git status` and `git diff`
- [ ] All tests and linting passed
- [ ] Conventional commit format prepared
- [ ] Explicit file paths identified
- [ ] GitHub Actions workflows linted (if modified)

**Pre-PR Checklist:**

- [ ] Feature branch created and pushed
- [ ] All commits follow conventions
- [ ] PR body drafted with Summary and Test plan
- [ ] Tests added/updated for changes

#### Phase 2: VALIDATE

**For Commits:**

```bash
# 1. Verify branch
BRANCH=$(git branch --show-current)
if [ "$BRANCH" = "main" ] || [ "$BRANCH" = "master" ]; then
  echo "ERROR: Never commit directly to main/master"
  exit 1
fi

# 2. Review changes
git status
git diff

# 3. Lint workflows if needed
if git diff --staged --name-only | grep -q '.github/workflows/'; then
  actionlint
fi
```

**For PRs:**

```bash
# 1. Verify branch is pushed
git push -u origin $(git branch --show-current)

# 2. Check PR doesn't already exist
gh pr list --head $(git branch --show-current)
```

#### Phase 3: EXECUTE

**For Commits:**

```bash
# Commit with explicit files
git commit -m "$(cat <<'EOF'
feat(feature): add new functionality

Detailed description of changes.
EOF
)" -- src/file1.ts src/file2.ts
```

**For PRs:**

```bash
# Create PR
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

# Watch CI
gh run watch
```

## Standard Workflows

### Creating a Commit

```bash
git status  # Check status and verify branch
git diff    # Review changes
git commit -m "$(cat <<'EOF'
feat(feature): add new functionality

Detailed description of changes.
EOF
)" -- src/file1.ts src/file2.ts
```

### Creating a Pull Request

```bash
git push -u origin $(git branch --show-current)
gh pr create --title "feat: title" --body "$(cat <<'EOF'
## Summary
- Changes made

## Test plan
- [x] Tests pass

🤖 Generated with [Claude Code](https://claude.com/claude-code)
EOF
)"
gh run watch  # Monitor CI
```

### Updating a PR

```bash
git commit -m "fix: address review feedback" -- file.ts
git push
gh pr edit --body "Updated changes"  # Optional
gh run watch
```

### Common Operations

```bash
# Monitoring CI/CD
gh pr status
gh pr checks --watch
gh run view 123456 --log-failed

# Linting workflows (ALWAYS before committing)
actionlint

# Review comments
gh pr view 123 --comments
gh pr view 123 --web

# Merging
gh pr checks              # Verify all pass
gh pr view --json reviews # Check approvals
gh pr merge --squash --delete-branch
```

## Branch Management

```bash
# Create feature branch
git checkout -b feat/new-feature  # or fix/, chore/, docs/

# Never commit to main
CURRENT=$(git branch --show-current)
[ "$CURRENT" = "main" ] && echo "Create feature branch first" && exit 1

# Rebase safely
export GIT_EDITOR=:
export GIT_SEQUENCE_EDITOR=:
git rebase main --no-edit  # Never rebase public/main branches
```

## Essential Patterns

### Pre-Commit Validation

```bash
[ "$(git branch --show-current)" != "main" ] || exit 1  # Verify not on main
git status && git diff --staged                          # Review changes
git diff --staged --name-only | grep -q '.github/workflows/' && actionlint  # Lint workflows
git commit -m "message" -- explicit-files.ts             # Commit with explicit files
```

### PR Body Template

```markdown
## Summary

- What changed and why

## Test plan

- [ ] Tests added/updated
- [ ] Manual testing performed

## Related

Fixes #123

🤖 Generated with [Claude Code](https://claude.com/claude-code)
```

### Quick gh Commands

```bash
# PRs: create, view, edit, list, check, merge
gh pr create --title "Title" --body "Body"
gh pr view 123 && gh pr checks 123
gh pr merge 123 --squash

# Issues: create, view, list
gh issue create --title "Title" --body "Body"

# Runs: list, view, watch, rerun
gh run watch 123456
```

See `references/gh-cli-reference.md` for complete command reference.

## Multi-Agent Coordination

```bash
# Before deleting/reverting: check authorship
git log -1 --format='%an' -- path/to/file  # If not you, STOP

# Atomic commits: only your changes
git commit -m "message" -- your-file1.ts your-file2.ts  # NOT: git add .
```

## Error Handling

```bash
# CI failures
gh run view --log-failed
gh run view --job=test --log
git commit -m "fix(test): resolve failures" -- fixed-file.ts && git push
gh run watch

# PR conflicts
git fetch origin main && git rebase origin/main
git add resolved-files.ts && git rebase --continue
git push --force-with-lease  # With approval only
```

## Quick Reference Checklists

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

## Reference Documentation

Comprehensive reference documentation is available:

- **`references/conventional-commits.md`** - Detailed commit format guide with examples
- **`references/gh-cli-reference.md`** - Complete GitHub CLI command reference
- **`references/github-actions.md`** - CI/CD monitoring and interaction guide
- **`references/git-safety.md`** - Comprehensive safety guidelines and recovery commands
- **`references/pr-best-practices.md`** - PR quality guidelines, templates, and review practices
- **`references/git-commands.md`** - Complete git command reference with safety notes

Load these references when detailed information is needed for specific operations.
