Fetch PR review threads, fix the issues, and resolve conversations.

### Workflow
1. **Fetch unresolved threads**
   ```bash
   gh pr view $ARGUMENTS --json reviewThreads \
     --jq '.reviewThreads[] | select(.isResolved == false)'
   ```

2. **For each unresolved thread:**
   - Read the concern
   - Apply the fix to code
   - Run tests to verify
   - Reply with what was fixed and test results
   - Mark thread as resolved

3. **Push fixes**
   ```bash
   git add .
   git commit -m "fix: address PR review comments"
   git push
   ```

### Commands
```bash
# View all comments
gh pr view $ARGUMENTS --comments

# View timeline
gh pr view $ARGUMENTS --json timelineItems

# Reply to comment
gh pr comment $ARGUMENTS --body "Fixed by..."

# Get PR number
gh pr view --json number --jq .number
```

### Rules
- Reference specific commits/lines in replies
- Verify fixes with tests before marking resolved
- For blockers: fix and explain; don't just acknowledge
- Use `$ARGUMENTS` for `--repo org/repo --pr 123` if needed
