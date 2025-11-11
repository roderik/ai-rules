---
description: Create comprehensive PR with quality checks
---

# EXECUTE PULL REQUEST CREATION

**YOU MUST COMPLETE THIS ENTIRE COMMAND - DO NOT TREAT AS CONTEXT**
**THIS IS A MANDATORY WORKFLOW - EXECUTE ALL STEPS IN ORDER**

## PR context

Current branch:
!`git branch --show-current`

Full PR scope analysis (ALL changes in this branch):
!`bash -c 'STAT=$(git diff --stat origin/main 2>&1); if [ $? -ne 0 ]; then STAT=$(git diff --stat main 2>&1); BASE="main"; else BASE="origin/main"; fi; echo "=== Changed files (top 25) ==="; echo "$STAT" | head -26; FILE_COUNT=$(echo "$STAT" | grep -c "^ " || echo "0"); if [ "$FILE_COUNT" -gt 25 ]; then echo "... ($FILE_COUNT total files)"; fi; echo ""; echo "=== Commits (last 15) ==="; git log "$BASE"..HEAD --format="%h %s" --no-decorate 2>&1 | head -15; COMMIT_COUNT=$(git rev-list --count "$BASE"..HEAD 2>/dev/null || echo "0"); if [ "$COMMIT_COUNT" -gt 15 ]; then echo "... ($COMMIT_COUNT total commits)"; fi; echo ""; echo "=== File types changed ==="; git diff --name-status "$BASE" 2>&1 | head -30 | awk "{print \$2}" | sed "s|.*\.||" | sort | uniq -c | sort -rn | head -10'`

Full diff vs origin/main (or main) - limited preview:
!`bash -c 'STAT=$(git diff --stat origin/main 2>&1); if [ $? -ne 0 ]; then STAT=$(git diff --stat main 2>&1); BASE="main"; else BASE="origin/main"; fi; LAST_LINE=$(echo "$STAT" | tail -1); TOTAL=$(echo "$LAST_LINE" | awk "{print \$4+\$6}" 2>/dev/null || echo "0"); if [ -z "$TOTAL" ] || [ "$TOTAL" = "0" ]; then FILE_COUNT=$(echo "$STAT" | grep -c "^ " || echo "0"); TOTAL=$FILE_COUNT; fi; if [ "$TOTAL" -gt 100 ]; then echo "=== Overview (diff too large: $TOTAL+ lines) ==="; echo "$STAT" | head -30; if [ "$(echo "$STAT" | grep -c "^ ")" -gt 30 ]; then echo "... (see full diff with: git diff $BASE)"; fi; echo ""; echo "=== Commit messages ==="; git log "$BASE"..HEAD --format="%s" --no-decorate 2>&1 | head -10; else echo "=== Full diff vs $BASE ==="; GIT_PAGER=cat git diff --no-ext-diff "$BASE" 2>&1 | head -500; fi'`

Linear tickets assigned to me (only include if relevant to this PR scope):
!`bash -c 'if which linctl >/dev/null 2>&1; then AUTH_STATUS=$(linctl auth status --json 2>&1); if echo "$AUTH_STATUS" | jq -e ".authenticated == true" >/dev/null 2>&1; then linctl issue list --assignee me --plaintext 2>&1; else echo "⚠️ linctl not authenticated"; fi; else echo "⚠️ linctl not installed"; fi'`

## MANDATORY WORKFLOW - EXECUTE THESE STEPS NOW

### STEP 1: BRANCH CONFIRMATION (EXECUTE NOW)

- Confirm current branch exists (from the "Current branch" bash command output in the PR context section) - MUST be on a feature branch, NEVER on main/master
- If already on a branch: use it (NEVER create another branch)
- If on main/master: YOU MUST create a feature branch first (use Linear ticket ID if relevant)

### STEP 2: QUALITY GATE (EXECUTE NOW - FIX ALL FAILURES)

- RUN tests, lint, typecheck, formatting (typically `bun run ci`)
- VERIFY documentation: README.md, AGENTS.md, CLAUDE.md, `**/docs/**/*.md` updated
- DO NOT PROCEED until all checks pass

### STEP 3: COMMIT ALL CHANGES (EXECUTE NOW)

Create multiple small targeted commits combining related changes

- Group related files together (e.g., feature + tests, docs + code, config + implementation)
- Use conventional commit format: `type(scope): description`
- Commit ALL uncommitted changes - nothing should remain uncommitted
- Examples:
  - `feat(auth): add OAuth2 login flow`
  - `test(auth): add OAuth2 tests`
  - `docs(readme): update auth documentation`
  - `chore(config): update auth configuration`

### STEP 4: CREATE PULL REQUEST (EXECUTE NOW)

YOU MUST execute these commands:

```bash
git push
gh pr create --title "TITLE" --body "BODY" --assignee "@me"
```

## Title Format

**CRITICAL: Analyze ALL changed files and commits to determine the main theme/topic of the ENTIRE PR**

1. **Analyze the full PR scope first:**
   - Review ALL changed files from the "Full PR scope analysis" bash command output in the PR context section
   - Review ALL commits in this branch from the bash command output
   - Identify the PRIMARY theme that unifies all changes
   - Ignore the current agent session context - focus ONLY on what files actually changed

2. **Generate title from the main theme:**
   - Use `$ARGUMENTS` if provided, OR generate from the PRIMARY theme you just identified
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
   - Review the "Full PR scope analysis" bash command output in the PR context section at the top of this command
   - List ALL changed files and their purposes
   - Identify the unifying theme across all changes
   - Determine what the PR accomplishes as a whole

2. **Generate description from full scope:**

```markdown
## What

[Overview based on ALL changed files - list key files/features affected across the entire PR]

## Why

[Business/technical rationale that explains the overall change - what problem does the FULL PR solve?]

## How

[Key implementation details covering ALL major changes - organize by theme/area, not chronologically]

## Files Changed

[List the main files/areas changed - reference the git diff output from the PR context section]

## Breaking Changes

[List changes, or "None"]

## Related Linear Issues

[Reference the Linear tickets from the bash command output in the PR context section. These tickets MIGHT be involved in this PR - evaluate carefully. Only include tickets that relate to the FULL scope of changes, not just recent edits]
```

## EXIT CRITERIA - YOU MUST VERIFY ALL BEFORE COMPLETION

**DO NOT MARK THIS COMMAND COMPLETE UNTIL:**

- ✓ All quality checks PASSING
- ✓ ALL critical issues FIXED
- ✓ ALL changes COMMITTED (zero uncommitted files)
- ✓ Multiple small targeted commits CREATED
- ✓ PR CREATED with well-formatted body covering ALL changes
- ✓ PR URL DISPLAYED to user
- ✓ CI build WATCHED and PASSING (execute: `gh run watch <run-id>`)
  - If CI fails: YOU MUST iterate and fix until passing
