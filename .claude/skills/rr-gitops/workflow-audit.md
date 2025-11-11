# Workflow Audit for rr-gitops

## ✓ Passed

- Development Workflow section exists ("Standard Workflows" starting line 117)
- Multiple numbered/sequential workflows present:
  - Creating a Commit (4 steps)
  - Creating a Pull Request (3 steps)
  - Updating a PR (4 steps)
  - Monitoring CI/CD (multiple commands)
  - Linting GitHub Actions Workflows (clear steps)
  - Getting Review Comments (multiple approaches)
  - Merging a PR (3 steps)
- Excellent checklists throughout:
  - Commit Checklist (line 500, 6 items)
  - PR Checklist (line 509, 8 items)
  - Safety Checklist (line 520, 7 items)
- Strong Plan-Validate-Execute pattern in PR workflow
- Comprehensive conditional workflows:
  - Pre-Commit Validation (line 301)
  - CI Failures handling (line 463)
  - PR Conflicts resolution (line 482)
- Excellent feedback loops:
  - "Always monitor CI runs after PR creation"
  - Error handling workflows with recovery steps
  - Multi-agent coordination guidance
- Good safety guards and destructive operation warnings

## ✗ Missing/Needs Improvement

- "Creating a Commit" workflow lacks explicit checklist format (uses numbered prose)
- "Creating a Pull Request" workflow lacks explicit checkboxes
- "Updating a PR" workflow lacks explicit checkboxes
- "Monitoring CI/CD" section is commands-only, no workflow structure
- No explicit rollback procedures for bad commits
- Missing "if CI fails repeatedly" escalation guidance
- No workflow for handling merge conflicts during rebase
- "Branch Management" section lacks workflow structure
- Pre-Commit Validation has steps but no checkboxes
- Missing workflow for handling failed PR merges

## Recommendations

1. **Convert "Creating a Commit" to checklist format**:

   ````markdown
   ### Creating a Commit

   - [ ] **Check status**: Run `git status` to review changes
   - [ ] **Verify branch**: Ensure not on main/master
     ```bash
     BRANCH=$(git branch --show-current)
     if [ "$BRANCH" = "main" ] || [ "$BRANCH" = "master" ]; then
       echo "ERROR: Never commit directly to main/master"
       exit 1
     fi
     ```
   ````

   - [ ] **Review changes**: Run `git diff` to verify what's changing
   - [ ] **Commit atomically**: Commit with explicit file list and conventional format

     ```bash
     git commit -m "$(cat <<'EOF'
     feat(feature): add new functionality

     Detailed description of changes.
     EOF
     )" -- src/file1.ts src/file2.ts
     ```

   - [ ] **Verify commit**: Check `git log -1` to confirm commit is correct

   ```

   ```

2. **Convert "Creating a Pull Request" to checklist format**:

   ````markdown
   ### Creating a Pull Request

   - [ ] **Push branch**: Ensure branch is pushed to remote
     ```bash
     git push -u origin $(git branch --show-current)
     ```
   ````

   - [ ] **Create PR**: Use gh CLI with formatted body

     ```bash
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
     ```

   - [ ] **Get run ID**: Capture CI run ID for monitoring
     ```bash
     RUN_ID=$(gh run list --limit=1 --json databaseId --jq '.[0].databaseId')
     ```
   - [ ] **Watch CI**: Monitor CI run until completion
     ```bash
     gh run watch $RUN_ID
     ```
   - [ ] **Handle CI failures**: If CI fails, investigate and fix (see CI Failure workflow)

   ```

   ```

3. **Add "Handling CI Failures" workflow**:

   ````markdown
   ### Handling CI Failures

   When CI fails after creating or updating a PR:

   - [ ] **View failed logs**: `gh run view --log-failed`
   - [ ] **Identify failure cause**: Review error messages and stack traces
   - [ ] **Investigate specific job**: `gh run view --job=<job-name> --log`
   - [ ] **Fix the issue**: Make necessary code changes
   - [ ] **Commit fix**: Create atomic commit with fix
     ```bash
     git commit -m "fix(test): resolve test failures" -- fixed-file.ts
     ```
   ````

   - [ ] **Push changes**: `git push`
   - [ ] **Monitor new run**: `gh run watch`
   - [ ] **If still failing**: Repeat diagnosis and fix steps
   - [ ] **If persistently failing**: Seek help or revert changes

   ```

   ```

4. **Add "Handling Merge Conflicts" workflow**:

   ```markdown
   ### Handling Merge Conflicts

   When rebasing or merging causes conflicts:

   - [ ] **Identify conflicts**: Git will list conflicted files
   - [ ] **Review each conflict**: Open conflicted files and examine markers
   - [ ] **Resolve conflicts**: Choose correct resolution for each conflict
   - [ ] **Remove conflict markers**: Delete `<<<<<<<`, `=======`, `>>>>>>>` lines
   - [ ] **Test resolution**: Ensure code still works after resolution
   - [ ] **Stage resolved files**: `git add <resolved-files>`
   - [ ] **Continue operation**:
     - For rebase: `git rebase --continue`
     - For merge: `git commit`
   - [ ] **Verify resolution**: Run tests to confirm everything works
   - [ ] **Force push if rebased** (with approval): `git push --force-with-lease`
   ```

5. **Add "Branch Management Workflow"**:

   ````markdown
   ### Branch Management Workflow

   **Creating a feature branch:**

   - [ ] Ensure on latest main: `git checkout main && git pull`
   - [ ] Create feature branch: `git checkout -b feat/feature-name`
   - [ ] Verify branch created: `git branch --show-current`
   - [ ] Make first commit to establish branch
   - [ ] Push to remote: `git push -u origin feat/feature-name`

   **Keeping branch up to date:**

   - [ ] Fetch latest changes: `git fetch origin main`
   - [ ] Set up environment for rebase:
     ```bash
     export GIT_EDITOR=:
     export GIT_SEQUENCE_EDITOR=:
     ```
   ````

   - [ ] Rebase on main: `git rebase origin/main --no-edit`
   - [ ] If conflicts occur, follow "Handling Merge Conflicts" workflow
   - [ ] Force push updates: `git push --force-with-lease` (with approval)
   - [ ] Verify branch is up to date: `git log --oneline -5`

   **Cleaning up merged branches:**
   - [ ] After PR merged, delete remote branch: `gh pr merge --delete-branch`
   - [ ] Delete local branch: `git branch -d feat/feature-name`
   - [ ] Verify branch deleted: `git branch --list`

   ```

   ```

6. **Add "Rollback Procedures" workflow**:

   ```markdown
   ### Rollback Procedures

   **Undo last commit (not pushed):**

   - [ ] Review what will be undone: `git log -1`
   - [ ] Soft reset to keep changes: `git reset --soft HEAD~1`
   - [ ] Verify changes are unstaged: `git status`
   - [ ] Make corrections and recommit

   **Revert pushed commit:**

   - [ ] Identify commit to revert: `git log --oneline`
   - [ ] Create revert commit: `git revert <commit-hash>`
   - [ ] Review revert commit: `git show HEAD`
   - [ ] Push revert: `git push`
   - [ ] Update PR if applicable: `gh pr edit --body "Reverted X due to Y"`

   **Abandon PR and start over:**

   - [ ] Close PR: `gh pr close <number>`
   - [ ] Delete remote branch: `git push origin --delete branch-name`
   - [ ] Delete local branch: `git branch -D branch-name`
   - [ ] Create fresh branch from main: `git checkout -b feat/new-approach`
   ```

7. **Add "Monitoring CI/CD" workflow structure**:

   ```markdown
   ### Monitoring CI/CD Workflow

   **After pushing changes:**

   - [ ] **Check PR status**: `gh pr status`
   - [ ] **Watch PR checks**: `gh pr checks --watch`
   - [ ] **If checks fail**: Follow "Handling CI Failures" workflow
   - [ ] **If checks pass**: Proceed to request reviews

   **Monitoring specific run:**

   - [ ] **List recent runs**: `gh run list`
   - [ ] **View run details**: `gh run view <run-id>`
   - [ ] **Watch run live**: `gh run watch <run-id>`
   - [ ] **View failed logs only**: `gh run view <run-id> --log-failed`
   - [ ] **Download logs**: `gh run download <run-id>`

   **Handling stuck or hung runs:**

   - [ ] **Check run status**: `gh run view <run-id>`
   - [ ] **Cancel hung run**: `gh run cancel <run-id>`
   - [ ] **Rerun failed jobs**: `gh run rerun <run-id> --failed`
   - [ ] **Rerun all jobs**: `gh run rerun <run-id>`
   ```

8. **Add "Merge Failure Recovery" workflow**:

   ```markdown
   ### Merge Failure Recovery

   If `gh pr merge` fails:

   - [ ] **Check merge requirements**: `gh pr checks` - all must pass
   - [ ] **Verify approvals**: `gh pr view --json reviews` - must be approved
   - [ ] **Check branch protection**: Ensure branch protection rules are met
   - [ ] **Update branch if stale**: Rebase on latest main
   - [ ] **Resolve conflicts**: Follow "Handling Merge Conflicts" workflow
   - [ ] **Retry merge**: `gh pr merge --squash --delete-branch`
   - [ ] **If still failing**: Merge manually via web UI and document why
   ```

9. **Enhance Pre-Commit Validation with checkboxes**:

   ```markdown
   ### Pre-Commit Validation Checklist

   Before ANY commit, verify:

   - [ ] **Not on main**: `[ "$(git branch --show-current)" != "main" ]`
   - [ ] **Review status**: `git status` shows expected files
   - [ ] **Review diff**: `git diff --staged` shows expected changes
   - [ ] **Quality checks pass**: Run tests/lint via test-runner
   - [ ] **Lint workflows** (if .github/workflows/ modified): `actionlint`
   - [ ] **Conventional commit format**: Message follows `<type>(<scope>): <description>`
   - [ ] **Explicit file paths**: Commit lists specific files, not `git add .`
   - [ ] **No secrets**: No .env files or credentials in staged changes
   ```

10. **Add escalation guidance for persistent failures**:

    ```markdown
    ### Escalation Guidance

    **If CI fails repeatedly (3+ times):**

    - [ ] Review all error messages from all failures
    - [ ] Check if failure is flaky (intermittent) or consistent
    - [ ] If flaky: Document in PR, request maintainer review
    - [ ] If consistent: Debug locally with same test conditions
    - [ ] Seek help from team members familiar with codebase
    - [ ] Consider alternative implementation approach
    - [ ] Document investigation steps in PR comments
    ```
