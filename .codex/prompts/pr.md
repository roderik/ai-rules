---
description: Create comprehensive PR with quality checks
---

## PR context

Current branch:
!`git branch --show-current`

Changes vs origin/main (or main):
!`bash -c 'echo "=== Uncommitted changes ==="; git status --porcelain 2>&1; echo ""; STAT=$(git diff --stat origin/main 2>&1); if [ $? -ne 0 ]; then STAT=$(git diff --stat main 2>&1); BASE="main"; else BASE="origin/main"; fi; LAST_LINE=$(echo "$STAT" | tail -1); TOTAL=$(echo "$LAST_LINE" | awk "{print \$4+\$6}" 2>/dev/null || echo "0"); if [ -z "$TOTAL" ] || [ "$TOTAL" = "0" ]; then FILE_COUNT=$(echo "$STAT" | grep -c "^ " || echo "0"); TOTAL=$FILE_COUNT; fi; if [ "$TOTAL" -gt 200 ]; then echo "=== Changed files (diff too large: $TOTAL+ lines) ==="; echo "$STAT" | grep -v "^$" | sed "$ d"; echo ""; echo "=== Committed changes ==="; git log "$BASE"..HEAD --format="%s" --no-decorate 2>&1 | head -10; else echo "=== Full diff vs $BASE ==="; GIT_PAGER=cat git diff --no-ext-diff "$BASE" 2>&1; fi'`

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

Use `$ARGUMENTS` or generate from ALL changes: `type(scope): description`
- Combine most relevant user/developer facing changes (limited length)

Examples:
- `feat(auth): add OAuth2 login flow`
- `fix(api): handle null responses`
- `refactor(database): migrate to Prisma`
- `chore(deps): update typescript to 5.x`
- `docs(readme): add deployment instructions`

## Body Template

```markdown
## What
[Clear summary - be specific about files/features]

## Why
[Business/technical rationale - problem solved?]

## How
[Key implementation details and decisions]

## Breaking Changes
[List changes, or "None"]

## Related Linear Issues
[Use the tickets fetched above which MIGHT be involved in the context of this PR. This is NOT a given and should be evaluated closely. Add any issues mentioned in agent context and list them in the format that links them to Linear]

## Exit Criteria

- All quality checks passing
- Critical issues fixed
- ALL changes committed (no uncommitted files)
- Multiple small targeted commits created
- PR created with well-formatted body covering ALL changes
- PR URL displayed
- Watch the CI build to ensure it all works, if not iterate and fix: `gh run watch <run-id>`
