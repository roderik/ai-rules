---
description: Create comprehensive PR with quality checks
allowed-tools: Bash, Read, Edit, Write, Glob, Grep, Task, WebFetch, WebSearch, TodoWrite
---

# Pull Request Creation

Complete this workflow. All context is provided in the prompt - execute all steps in order.

## Sub-Agent Strategy

For large PRs with many changes, use sub-agents to parallelize work:

1. **Analyze & Group Changes**: Review all uncommitted/unpushed changes and group by:
   - Package/app (e.g., all changes in `packages/dalp/api`)
   - Feature area (e.g., authentication, database, API)
   - Change type (e.g., features, tests, docs, config)

2. **Launch Sub-Agents**: For quality checks on large PRs, launch sub-agents for:
   - Running tests for specific packages
   - Type-checking specific areas
   - Linting specific file groups

3. **Coordination**: Main agent coordinates and ensures:
   - All quality checks complete
   - All issues are fixed before proceeding
   - Final verification passes

## Gather Context

Check for existing PR:
!`gh pr view --json number,url,title,state -q 'if .number then "\(.number): \(.title) (\(.url)) [\(.state)]" else "No PR exists" end' 2>&1 || echo "No PR exists"`

Current branch:
!`git branch --show-current`

Tracking status:
!`git status -sb | head -1`

Full PR scope analysis (ALL changes in this branch):
!`bash -c 'STAT=$(git diff --stat origin/main 2>&1); if [ $? -ne 0 ]; then STAT=$(git diff --stat main 2>&1); BASE="main"; else BASE="origin/main"; fi; echo "=== Changed files (top 25) ==="; echo "$STAT" | head -26; FILE_COUNT=$(echo "$STAT" | grep -c "^ " || echo "0"); if [ "$FILE_COUNT" -gt 25 ]; then echo "... ($FILE_COUNT total files)"; fi; echo ""; echo "=== Commits (last 15) ==="; git log "$BASE"..HEAD --format="%h %s" --no-decorate 2>&1 | head -15; COMMIT_COUNT=$(git rev-list --count "$BASE"..HEAD 2>/dev/null || echo "0"); if [ "$COMMIT_COUNT" -gt 15 ]; then echo "... ($COMMIT_COUNT total commits)"; fi; echo ""; echo "=== File types changed ==="; git diff --name-status "$BASE" 2>&1 | head -30 | awk "{print \$2}" | sed "s|.*\.||" | sort | uniq -c | sort -rn | head -10'`

Uncommitted changes:
!`git status --short 2>&1`

Full diff vs origin/main (or main) - limited preview:
!`bash -c 'STAT=$(git diff --stat origin/main 2>&1); if [ $? -ne 0 ]; then STAT=$(git diff --stat main 2>&1); BASE="main"; else BASE="origin/main"; fi; LAST_LINE=$(echo "$STAT" | tail -1); TOTAL=$(echo "$LAST_LINE" | awk "{print \$4+\$6}" 2>/dev/null || echo "0"); if [ -z "$TOTAL" ] || [ "$TOTAL" = "0" ]; then FILE_COUNT=$(echo "$STAT" | grep -c "^ " || echo "0"); TOTAL=$FILE_COUNT; fi; if [ "$TOTAL" -gt 100 ]; then echo "=== Overview (diff too large: $TOTAL+ lines) ==="; echo "$STAT" | head -30; if [ "$(echo "$STAT" | grep -c "^ ")" -gt 30 ]; then echo "... (see full diff with: git diff $BASE)"; fi; echo ""; echo "=== Commit messages ==="; git log "$BASE"..HEAD --format="%s" --no-decorate 2>&1 | head -10; else echo "=== Full diff vs $BASE ==="; GIT_PAGER=cat git diff --no-ext-diff "$BASE" 2>&1 | head -500; fi'`

Linear tickets assigned to me:
!`bash -c 'if which linctl >/dev/null 2>&1; then AUTH_STATUS=$(linctl auth status --json 2>&1); if echo "$AUTH_STATUS" | jq -e ".authenticated == true" >/dev/null 2>&1; then linctl issue list --assignee me --plaintext 2>&1; else echo "linctl not authenticated"; fi; else echo "linctl not installed"; fi'`

## Workflow Steps

### Step 1: Branch Confirmation

**Check the "Current branch" output above.**

- If on feature branch: proceed to Step 2
- If on main/master: STOP - create a feature branch first:
  ```bash
  git checkout -b feat/descriptive-name
  ```

### Step 2: Quality Gate

Run the full CI suite and fix ALL failures before proceeding:

```bash
bun run ci
```

**Quality checklist:**
- [ ] All tests passing
- [ ] Type checking clean (`bun run typecheck`)
- [ ] Linting clean (`bun run lint`)
- [ ] Formatting correct (`bun run format`)

**Documentation checklist (per CLAUDE.md requirements):**
- [ ] README.md exists and is current for touched packages
- [ ] CLAUDE.md exists for touched packages
- [ ] AGENTS.md symlink exists for touched packages
- [ ] TSDoc comments on all exported functions/types
- [ ] Inline comments for non-trivial logic

**If any failures:** Fix them NOW. Do not proceed until clean.

### Step 3: Commit All Changes

**Check the "Uncommitted changes" output above.**

If there are uncommitted changes, create targeted commits:

```bash
# Stage related files together
git add <related-files>
git commit -m "$(cat <<'EOF'
type(scope): description

Optional body explaining the change.

🤖 Generated with [Claude Code](https://claude.com/claude-code)

Co-Authored-By: Claude <noreply@anthropic.com>
EOF
)"
```

**Commit guidelines:**
- Group related files (feature + tests, docs + code)
- Use conventional commit format: `type(scope): description`
- Types: `feat`, `fix`, `docs`, `test`, `refactor`, `chore`, `perf`
- Scope: package name or feature area

**Verify no uncommitted changes remain:**
```bash
git status --short
```

### Step 4: Push Changes

```bash
# Push with upstream tracking
git push -u origin $(git branch --show-current)
```

**Verify push succeeded:**
```bash
git status -sb | head -1
# Should show: ## branch...origin/branch
```

### Step 5: Create Pull Request

**Use HEREDOC for the body to preserve formatting:**

```bash
gh pr create --title "type(scope): description" --assignee "@me" --body "$(cat <<'EOF'
## What

[Overview based on ALL changed files]

## Why

[Business/technical rationale]

## How

[Key implementation details]

## Files Changed

[Organized by package/area]

## Breaking Changes

None

## Testing

- [ ] All tests passing
- [ ] Manual testing completed

## Related Linear Issues

[Reference relevant tickets or "None"]
EOF
)"
```

### Step 6: Watch CI

Get the workflow run ID and watch it:

```bash
# Get the latest run ID for this PR
RUN_ID=$(gh run list --branch "$(git branch --show-current)" --limit 1 --json databaseId -q '.[0].databaseId')
echo "Watching run: $RUN_ID"
gh run watch "$RUN_ID"
```

**If CI fails:**
1. Check the failure: `gh run view $RUN_ID --log-failed`
2. Fix the issue locally
3. Commit and push the fix
4. Watch the new run

## Title Format

Analyze the full PR scope to determine the title:

1. **Review ALL changes** from the context above
2. **Identify the PRIMARY theme** across all changes
3. **Generate title**: `type(scope): description`

Use `$ARGUMENTS` if provided, otherwise generate from the changes.

**Examples:**
- `feat(dfns): implement wallet creation workflow`
- `fix(api): handle null responses in user endpoint`
- `refactor(database): migrate to Drizzle ORM`
- `chore(deps): update TypeScript to 5.x`

## Body Template

```markdown
## What

[Overview based on ALL changed files - list key files/features affected]

## Why

[Business/technical rationale - what problem does this PR solve?]

## How

[Key implementation details - organize by package/area]

## Files Changed

[Group by package:]
- `packages/dalp/api`: [changes]
- `packages/integrations/dfns`: [changes]

## Breaking Changes

[List any breaking changes, or "None"]

## Testing

- All tests passing
- [Additional testing notes]

## Related Linear Issues

[Reference tickets from the Linear output above, or "None"]
```

## Exit Criteria

Execute these verification commands before completing:

```bash
# Verify no uncommitted changes
git status --short

# Verify PR exists
gh pr view --json number,url,state

# Verify CI status
gh pr checks
```

**Checklist:**
- [ ] All quality checks passing (`bun run ci` clean)
- [ ] All changes committed (zero uncommitted files)
- [ ] Changes pushed to remote
- [ ] PR created with descriptive title and body
- [ ] PR URL displayed to user
- [ ] CI build passing (watched with `gh run watch`)

**If any item fails:** Go back and fix it before completing.

## Final Output

Display to user:
- PR URL
- PR number
- CI status
- Any warnings or notes
