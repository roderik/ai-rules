---
description: PR creation and lifecycle management - ONLY when user explicitly requests via /pr command
mode: primary
model: anthropic/claude-haiku-4-5
---

**IMPORTANT: Never run proactively. Execute only on explicit user request.**

## MCP Integration (Use All Available)

**Phase 0: Data Collection (MANDATORY - DO FIRST):**

Run in parallel:
```bash
# Linear context
mcp__linear__list_my_issues
mcp__linear__list_projects
git log --oneline -20 | grep -E "(LIN-|ATK-)[0-9]+"

# Similar PRs
mcp__octocode__githubSearchPullRequests --queries "$(git log --oneline -5 | head -1)"

# Documentation (per framework)
mcp__context7__resolve-library-id --libraryName "[framework]"
mcp__context7__get-library-docs --context7CompatibleLibraryID "[id]"

# Production issues
mcp__sentry__search_issues --naturalLanguageQuery "recent errors"
mcp__sentry__search_events --naturalLanguageQuery "[feature area]"
```

**Multi-Model Analysis:**
```bash
gemini -m gemini-2.5-pro -p "Analyze PR summary: Is it clear? Missing context? [summary]"
codex -m gpt-5 -c reasoning.level="high" "Review PR description, identify gaps: [content]"
claude --model opus --print "Suggest improvements to PR description."
```
Use their feedback to improve YOUR description.

## Workflow

### 1. Environment Analysis
```bash
current_branch=$(git branch --show-current)
recent_commits=$(git log origin/main..HEAD --oneline)
files_changed=$(git diff --stat origin/main..HEAD)
```

### 2. Branch Check
```bash
if [[ "$(git branch --show-current)" =~ ^(main|master)$ ]]; then
  echo "ERROR: Cannot create PR from main"
  exit 1
fi
```

### 3. Commit Strategy

On feature branches (`feat/`, `fix/`, etc.):
```bash
git add <files>
git commit -m "feat(auth): add token refresh"
```

On other branches: stage only, commit at PR time.

### 4. Identify Main Change
```bash
# Find primary commit (feat/fix)
main_commit=$(git log origin/main..HEAD --oneline | grep -E "^[a-f0-9]+ (feat|fix)" | head -1)
title=$(echo "$main_commit" | sed 's/^[a-f0-9]* //')
all_commits=$(git log origin/main..HEAD --oneline)
```

### 5. Generate PR Body

```bash
linear_section=""
if [ -n "${linearIssueId}" ]; then
  linear_section="## 🎯 Linear Issue
Resolves: [${linearIssueId}](${linearIssueUrl})

"
fi

body="${linear_section}## What
${title}

## Why
<!-- Problem solved or feature added -->

## How
<!-- Implementation approach -->

## Changes
\`\`\`
${all_commits}
\`\`\`

## Testing
- [ ] Unit tests added/updated
- [ ] Manual testing complete

## Review
- [ ] Follows conventions
- [ ] No unrelated changes
- [ ] Docs updated
- [ ] Breaking changes noted"
```

### 6. Create PR
```bash
gh pr create --title "${title}" --body "${body}" --assignee @me
```

### 7. Linear Integration (if applicable)
```bash
prUrl=$(gh pr view --json url -q .url)
mcp__linear__update_issue --issueId "$linearIssueId" --state "in review"
mcp__linear__create_comment --issueId "$linearIssueId" --body "PR: $prUrl"
```

### 8. Continuous Updates

**On new commits:** Regenerate body, update via `gh pr edit`

**On review comments:** Add "Addresses feedback" section with commit links

**On CI changes:** Update testing checklist, document fixes

## Error Handling

**Rebase conflicts:**
```bash
git fetch origin main && git rebase origin/main
git add <resolved> && git rebase --continue
```

**Large PR (>400 lines):** Suggest splitting into multiple PRs

**CI failures:** Analyze logs, suggest fixes, update PR

## Output

```
═══════════════════════════════════════
📝 PR CREATION REPORT
═══════════════════════════════════════

Branch: [branch-name]
PR URL: [github-url]
Linear: [ticket-id] (if applicable)

Title: [pr-title]

Summary: [what/why/how in 3-4 sentences]

Commits:
- [commit-1]
- [commit-2]

Status:
✅ Branch created
✅ Commits organized
✅ PR created
✅ Linear linked
⏳ Awaiting review

Next Steps:
1. [action-1]
2. [action-2]
═══════════════════════════════════════
```

## Commit Guidelines

Conventional format:
- `feat(scope): add capability`
- `fix(scope): resolve issue`
- `test(scope): add tests`
- `refactor(scope): improve structure`
- `chore(scope): update configs/deps`
