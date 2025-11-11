# Evaluation Scenarios for rr-gitops

## Scenario 1: Basic Usage - Create Conventional Commit

**Input:** "Commit the changes I made to src/auth/login.ts and src/auth/signup.ts. I added OAuth2 authentication."

**Expected Behavior:**

- Automatically activate for commit-related requests
- Check git status first
- Verify not on main/master branch
- Use git diff to see changes
- Create conventional commit with proper format
- Use HEREDOC format for commit message
- Type: "feat" (new feature)
- Scope: "auth"
- Use explicit file paths with --
- Quote file paths properly

**Success Criteria:**

- [ ] Runs git status first
- [ ] Checks branch name, ensures not main/master
- [ ] Runs git diff to see changes
- [ ] Commit message format: "feat(auth): <description>"
- [ ] Uses HEREDOC format: git commit -m "$(cat <<'EOF'...)"
- [ ] Includes body explaining OAuth2 implementation
- [ ] Uses explicit paths: -- src/auth/login.ts src/auth/signup.ts
- [ ] Paths are quoted
- [ ] Follows conventional commit format from SKILL.md

## Scenario 2: Complex Scenario - Create PR with CI Monitoring

**Input:** "Create a pull request for my feature branch that adds user profile editing. Watch the CI run and let me know if tests pass."

**Expected Behavior:**

- Load skill for PR creation
- Ensure branch is pushed to remote
- Use gh pr create with proper format
- Create descriptive PR title
- Use HEREDOC for PR body with:
  - Summary of changes
  - Test plan checklist
- Get the run ID after PR creation
- Monitor CI with gh run watch
- Report CI results (pass/fail)
- If CI fails, analyze logs and suggest fixes
- Reference `references/github-actions.md`

**Success Criteria:**

- [ ] Pushes branch: git push -u origin $(git branch --show-current)
- [ ] Uses gh pr create with --title and --body
- [ ] PR body has Summary section with bullet points
- [ ] PR body has Test plan section with checklist
- [ ] Uses HEREDOC for PR body formatting
- [ ] Gets run ID: gh run list --limit=1 --json databaseId --jq '.[0].databaseId'
- [ ] Watches CI: gh run watch $RUN_ID
- [ ] Reports CI status (success/failure)
- [ ] If failed, checks logs: gh run view $RUN_ID --log-failed
- [ ] Suggests fixes based on failure logs
- [ ] References github-actions.md for monitoring patterns

## Scenario 3: Error Handling - Accidental Commit to Main

**Input:** "I accidentally committed directly to the main branch. How do I undo this?"

**Expected Behavior:**

- Recognize dangerous situation (commit on main)
- Check if commit has been pushed
- If NOT pushed:
  - Use git reset HEAD~1 to undo commit
  - Preserve changes in working directory
  - Create feature branch
  - Recommit on feature branch
- If pushed:
  - WARN user about rewriting published history
  - Explain revert is safer
  - Provide git revert command
  - Explain force push consequences
- Reference `references/git-safety.md`
- Emphasize this violates safety principles

**Success Criteria:**

- [ ] Identifies commit on main as violation of git safety
- [ ] Checks if commit pushed: git status or git log
- [ ] If not pushed: provides git reset HEAD~1 --soft
- [ ] Creates feature branch: git checkout -b feature/fix
- [ ] If pushed: warns about rewriting history
- [ ] Recommends git revert over git reset --hard
- [ ] Shows proper revert syntax
- [ ] Explains why force push to main is dangerous
- [ ] References git-safety.md
- [ ] Provides prevention advice (branch protection rules)
