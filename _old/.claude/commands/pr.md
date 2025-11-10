---
description: Create comprehensive PR with quality checks
---

## PR context

Current branch:
!`git branch --show-current`

Full PR scope analysis (ALL changes in this branch):
!`bash -c 'STAT=$(git diff --stat origin/main 2>&1); if [ $? -ne 0 ]; then STAT=$(git diff --stat main 2>&1); BASE="main"; else BASE="origin/main"; fi; echo "=== Changed files (top 25) ==="; echo "$STAT" | head -26; FILE_COUNT=$(echo "$STAT" | grep -c "^ " || echo "0"); if [ "$FILE_COUNT" -gt 25 ]; then echo "... ($FILE_COUNT total files)"; fi; echo ""; echo "=== Commits (last 15) ==="; git log "$BASE"..HEAD --format="%h %s" --no-decorate 2>&1 | head -15; COMMIT_COUNT=$(git rev-list --count "$BASE"..HEAD 2>/dev/null || echo "0"); if [ "$COMMIT_COUNT" -gt 15 ]; then echo "... ($COMMIT_COUNT total commits)"; fi; echo ""; echo "=== File types changed ==="; git diff --name-status "$BASE" 2>&1 | head -30 | awk "{print \$2}" | sed "s|.*\.||" | sort | uniq -c | sort -rn | head -10'`

Full diff vs origin/main (or main) - limited preview:
!`bash -c 'STAT=$(git diff --stat origin/main 2>&1); if [ $? -ne 0 ]; then STAT=$(git diff --stat main 2>&1); BASE="main"; else BASE="origin/main"; fi; LAST_LINE=$(echo "$STAT" | tail -1); TOTAL=$(echo "$LAST_LINE" | awk "{print \$4+\$6}" 2>/dev/null || echo "0"); if [ -z "$TOTAL" ] || [ "$TOTAL" = "0" ]; then FILE_COUNT=$(echo "$STAT" | grep -c "^ " || echo "0"); TOTAL=$FILE_COUNT; fi; if [ "$TOTAL" -gt 100 ]; then echo "=== Summary (diff too large: $TOTAL+ lines) ==="; echo "$STAT" | head -30; if [ "$(echo "$STAT" | grep -c "^ ")" -gt 30 ]; then echo "... (see full diff with: git diff $BASE)"; fi; echo ""; echo "=== Commit messages ==="; git log "$BASE"..HEAD --format="%s" --no-decorate 2>&1 | head -10; else echo "=== Full diff vs $BASE ==="; GIT_PAGER=cat git diff --no-ext-diff "$BASE" 2>&1 | head -500; fi'`

Linear tickets assigned to me (only include if relevant to this PR scope):
!`bash -c 'if which linctl >/dev/null 2>&1; then AUTH_STATUS=$(linctl auth status --json 2>&1); if echo "$AUTH_STATUS" | jq -e ".authenticated == true" >/dev/null 2>&1; then linctl issue list --assignee me --plaintext 2>&1; else echo "⚠️ linctl not authenticated"; fi; else echo "⚠️ linctl not installed"; fi'`

## Workflow

1. **Branch confirmation**
   - Confirm current branch exists (from "Current branch" above) - MUST be on a feature branch, NEVER on main/master
   - If already on a branch: use it (NEVER create another branch)
   - If on main/master: create a feature branch first (use Linear ticket ID if relevant)

2. **Quality gate** (FIX all failures)
   - Tests, lint, typecheck, formatting (typically `bun run ci`)
   - Documentation: README.md, AGENTS.md, CLAUDE.md, `**/docs/**/*.md` updated

3. **Commit all changes**: Create multiple small targeted commits combining related changes
   - Group related files together (e.g., feature + tests, docs + code, config + implementation)
   - Use conventional commit format: `type(scope): description`
   - Commit ALL uncommitted changes - nothing should remain uncommitted
   - Examples:
     - `feat(auth): add OAuth2 login flow`
     - `test(auth): add OAuth2 tests`
     - `docs(readme): update auth documentation`
     - `chore(config): update auth configuration`

4. **Create PR**
   ```bash
   git push
   gh pr create --title "TITLE" --body "BODY" --assignee "@me"
   ```

## Title Format

**CRITICAL: Analyze ALL changed files and commits to determine the main theme/topic of the ENTIRE PR**

1. **Analyze the full PR scope first:**
   - Review ALL changed files from "Full PR scope analysis" above
   - Review ALL commits in this branch
   - Identify the PRIMARY theme that unifies all changes
   - Ignore the current agent session context - focus ONLY on what files actually changed

2. **Generate title from the main theme:**
   - Use `$ARGUMENTS` if provided, OR generate from the PRIMARY theme identified above
   - Format: `type(scope): description`
   - The scope should reflect the main area affected across ALL changes
   - The description should capture the overall change, not just recent edits

3. **Examples:**
   - If changes span auth files, API routes, and tests → `feat(auth): add OAuth2 login flow`
   - If changes are only in one component → `fix(api): handle null responses`
   - If changes refactor multiple related files → `refactor(database): migrate to Prisma`
   - If changes update dependencies across project → `chore(deps): update typescript to 5.x`

## Body Template

**CRITICAL: Base the PR description on ALL changed files, not just recent context**

1. **Analyze the full PR scope:**
   - Review "Full PR scope analysis" section above
   - List ALL changed files and their purposes
   - Identify the unifying theme across all changes
   - Determine what the PR accomplishes as a whole

2. **Generate description from full scope:**

```markdown
## What
[Summary based on ALL changed files - list key files/features affected across the entire PR]

## Why
[Business/technical rationale that explains the overall change - what problem does the FULL PR solve?]

## How
[Key implementation details covering ALL major changes - organize by theme/area, not chronologically]

## Files Changed
[List or summarize the main files/areas changed - use the "Full PR scope analysis" data]

## Breaking Changes
[List changes, or "None"]

## Related Linear Issues
[Use the tickets fetched above which MIGHT be involved in the context of this PR. This is NOT a given and should be evaluated closely. Only include tickets that relate to the FULL scope of changes, not just recent edits]
```

## Exit Criteria

- All quality checks passing
- Critical issues fixed
- ALL changes committed (no uncommitted files)
- Multiple small targeted commits created
- PR created with well-formatted body covering ALL changes
- PR URL displayed
- Watch the CI build to ensure it all works, if not iterate and fix: `gh run watch <run-id>`
