---
description: Handle and resolve every PR review thread
---

## Gather Context

Check for PR:
!`gh pr view --json number,url,title,state -q 'if .number then "\(.number): \(.title) (\(.url)) [\(.state)]" else "ERROR: No PR found for current branch"' 2>&1`

Recent commits:
!`git log origin/main..HEAD --oneline --no-decorate | head -10`

Files changed:
!`git diff --stat origin/main..HEAD`

PR timeline + comments:
!`gh pr view --comments 2>&1`

Diff with line numbers:
!`gh pr diff 2>&1`

Unresolved review threads count:
!`GH_REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null) && PR_NUMBER=$(gh pr view --json number -q .number 2>/dev/null) && if [ -z "$GH_REPO" ] || [ -z "$PR_NUMBER" ]; then echo "ERROR: Could not fetch PR info"; else gh api graphql -F owner="${GH_REPO%/*}" -F name="${GH_REPO#*/}" -F pr="$PR_NUMBER" -f query='query($owner:String!,$name:String!,$pr:Int!){repository(owner:$owner,name:$name){pullRequest(number:$pr){reviewThreads(first:100){nodes{isResolved}}}}}' | jq '[.data.repository.pullRequest.reviewThreads.nodes[] | select(.isResolved == false)] | length | "Total unresolved: \(.)"'; fi`

Unresolved review threads (newest first):
!`GH_REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null) && PR_NUMBER=$(gh pr view --json number -q .number 2>/dev/null) && if [ -z "$GH_REPO" ] || [ -z "$PR_NUMBER" ]; then echo "ERROR: Could not fetch PR info"; else gh api graphql -F owner="${GH_REPO%/*}" -F name="${GH_REPO#*/}" -F pr="$PR_NUMBER" -f query='query($owner:String!,$name:String!,$pr:Int!){repository(owner:$owner,name:$name){pullRequest(number:$pr){reviewThreads(first:100){nodes{id isResolved isOutdated path line startLine comments(first:20){nodes{id databaseId body author{login} createdAt}}}}}}}' | jq -r '.data.repository.pullRequest.reviewThreads.nodes[] | select(.isResolved == false) | "\(.comments.nodes[0].createdAt)|\(.id)|\(.path):\(.line // .startLine)|\(.comments.nodes[0].author.login)|\(.comments.nodes[0].body[0:200])"' | sort -t'|' -k1 -r | awk -F'|' '{printf "Thread: %s\nFile: %s\nAuthor: %s\nPreview: %s\n---\n", $2, $3, $4, $5}'; fi`

## Fix Loop

For each unresolved thread (process newest→oldest):

1. **Open file**: Navigate to `path:line` from thread info
2. **Understand**: Read comment context, identify required change
3. **Fix**: Edit code at `path:line`, maintain style consistency
4. **Test**: Run test-runner agent on changed files, also lint!
5. **Review**: Run reviewer agent to verify fix quality
6. **Commit**: `git add <files> && git commit -m "fix(pr-review): address <summary>"`
7. **Reply**: Use thread ID with fix summary + commit SHA + test results
8. **Verify**: Re-run checks, confirm fix resolves the concern

## Reply Template

Reply format:
```
Fixed in commit <SHA>.

**Changes:**
- <summary of fix>

**Tests:**
- ✓ All tests passing
- ✓ Lint/typecheck clean

<additional context if needed>
```

Reply command:
```bash
gh api graphql \
  -F pullRequestReviewThreadId=<threadId> \
  -F body="<your-reply>" \
  -f query='mutation($pullRequestReviewThreadId:ID!,$body:String!){addPullRequestReviewThreadReply(input:{pullRequestReviewThreadId:$pullRequestReviewThreadId,body:$body}){comment{id url}}}'
```

## Resolve Thread

Only resolve after:
- Fix committed and pushed
- Tests passing
- Reviewer acknowledges fix

Resolve command:
```bash
gh api graphql \
  -F threadId=<threadId> \
  -f query='mutation($threadId:ID!){resolveReviewThread(input:{threadId:$threadId}){thread{id isResolved}}}'
```

## Finish

```bash
# Push all commits
git push

# Verify no unresolved threads remain
gh pr view --comments | grep -i "outstanding\|pending\|unresolved" || echo "✓ All threads resolved"
```
