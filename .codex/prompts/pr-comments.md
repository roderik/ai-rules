Fetch all PR comments (threads + inline file comments), fix issues, and resolve conversations.

### Workflow
1. **Fetch all comments**
   ```bash
   # Get unresolved review threads
   gh pr view $ARGUMENTS --json reviewThreads \
     --jq '.reviewThreads[] | select(.isResolved == false)'
   
   # Get inline file comments with locations
   gh pr view $ARGUMENTS --json reviewThreads \
     --jq '.reviewThreads[] | select(.path != null) | 
           {file: .path, line: .line, comment: .comments[0].body, resolved: .isResolved}'
   
   # View diff to see context
   gh pr diff $ARGUMENTS
   ```

2. **For each comment (thread or inline):**
   - **Inline file comments**: Navigate to `file:line` mentioned in comment
   - **Thread comments**: Read the full conversation context
   - Apply the requested fix to code
   - Run tests to verify the fix works
   - Reply with what was fixed and test results
   - Reference commit SHA in reply

3. **Handle inline file comments:**
   - Read the file and surrounding context
   - Understand the concern about that specific line
   - Make the fix while preserving functionality
   - Add test coverage if missing

4. **Push all fixes**
   ```bash
   git add .
   git commit -m "fix: address PR review comments

   - Fix issue at file.ts:42 (inline comment)
   - Address thread about error handling"
   git push
   ```

### Commands
```bash
# View all comments (general + inline)
gh pr view $ARGUMENTS --comments

# View diff with line numbers for context
gh pr diff $ARGUMENTS

# Get inline comments with file locations
gh pr view $ARGUMENTS --json reviewThreads \
  --jq '.reviewThreads[] | {file: .path, line: .line, body: .comments[0].body}'

# Reply to comment
gh pr comment $ARGUMENTS --body "Fixed in [commit]: [explanation]"

# Get PR number
gh pr view --json number --jq .number
```

### Rules
- **For inline comments**: Quote `file:line` in your reply and explain the fix
- **For thread comments**: Reference the conversation context
- Verify ALL fixes with tests before marking resolved
- For blockers: fix immediately and explain what changed
- For suggestions: implement if reasonable, or explain why not
- Group related fixes into logical commits with descriptive messages
- Use `$ARGUMENTS` for `--repo org/repo --pr 123` if needed
