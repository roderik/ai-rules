---
description: Handle and resolve every PR review thread
---

CRITICAL: all the PR comments are provided in the prompt, use them from the prompt, do not fetch them yourself

## Fix Loop

For each unresolved thread (process newest→oldest):

1. **Open file**: Navigate to `path:line` from thread info
2. **Understand**: Read comment context, identify required change
3. **Fix**: Edit code at `path:line`, maintain style consistency
4. **Test**: Run test-runner agent on changed files, also lint!
5. **Review**: Run reviewer agent to verify fix quality
6. **Commit**: `git add <files> && git commit -m "fix(pr-review): address <summary>"`
7. **Reply**: Post reply to thread with fix summary + commit SHA + test results (see Reply command below)
8. **RESOLVE IN GITHUB**: Execute the Resolve command to mark thread as resolved in GitHub (MANDATORY - do not skip!)
9. **Verify**: Re-run checks, confirm fix resolves the concern

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

## Resolve Thread (MANDATORY FOR EVERY FIXED THREAD)

**CRITICAL: You MUST execute this command in GitHub for EVERY thread you fix!**
**This is NOT optional - the thread will remain open until you run this command.**

Only resolve after:
- Fix committed and pushed
- Tests passing
- Reply posted to thread

Resolve command:
```bash
gh api graphql \
  -F threadId=<threadId> \
  -f query='mutation($threadId:ID!){resolveReviewThread(input:{threadId:$threadId}){thread{id isResolved}}}'
```

## Finish

**BEFORE completing, verify you executed the Resolve command for EVERY fixed thread!**

```bash
# Push all commits
git push

# Verify no unresolved threads remain
gh pr view --comments | grep -i "outstanding\|pending\|unresolved" || echo "✓ All threads resolved"
```

**If any threads remain unresolved, go back and execute the Resolve command for each one.**

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
!`bash -c 'GH_REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null) && PR_NUMBER=$(gh pr view --json number -q .number 2>/dev/null | grep -E "^[0-9]+$") && if [ -z "$GH_REPO" ] || [ -z "$PR_NUMBER" ]; then echo "ERROR: Could not fetch PR info"; else TMP=$(mktemp) && cat > "$TMP" << '\''EOF'\''
query($owner:String!,$name:String!,$pr:Int!){
  repository(owner:$owner,name:$name){
    pullRequest(number:$pr){
      reviewThreads(first:100){
        nodes{isResolved}
      }
    }
  }
}
EOF
gh api graphql --field owner="${GH_REPO%/*}" --field name="${GH_REPO#*/}" --field pr="$PR_NUMBER" --field query=@"$TMP" 2>/dev/null | jq -r '\''if .data.repository.pullRequest then ([.data.repository.pullRequest.reviewThreads.nodes[]? | select(.isResolved == false)] | length | "Total unresolved: \(.)") else "No PR found" end'\''; rm -f "$TMP"; fi'`

Unresolved review threads (newest first):
!`bash -c 'GH_REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null) && PR_NUMBER=$(gh pr view --json number -q .number 2>/dev/null | grep -E "^[0-9]+$") && if [ -z "$GH_REPO" ] || [ -z "$PR_NUMBER" ]; then echo "ERROR: Could not fetch PR info"; else TMP=$(mktemp) && cat > "$TMP" << '\''EOF'\''
query($owner:String!,$name:String!,$pr:Int!){
  repository(owner:$owner,name:$name){
    pullRequest(number:$pr){
      reviewThreads(first:100){
        nodes{
          id
          isResolved
          isOutdated
          path
          line
          startLine
          comments(first:20){
            nodes{
              id
              databaseId
              body
              author{login}
              createdAt
            }
          }
        }
      }
    }
  }
}
EOF
gh api graphql --field owner="${GH_REPO%/*}" --field name="${GH_REPO#*/}" --field pr="$PR_NUMBER" --field query=@"$TMP" 2>/dev/null | jq -r '\''.data.repository.pullRequest.reviewThreads.nodes[]? | select(.isResolved == false) | select(.comments.nodes | length > 0) | "\(.comments.nodes[0].createdAt)|\(.id)|\(.path // "general")|\(.line // .startLine // "?")|\(.comments.nodes[0].author.login)|\(.comments.nodes[0].body | gsub("\\n"; "\u0001"))"'\'' | sort -t"|" -k1 -r | while IFS="|" read -r date id path line author body; do printf "Thread: %s\nFile: %s:%s\nAuthor: %s\nMessage:\n%s\n---\n" "$id" "$path" "$line" "$author" "${body//$'\''\u0001'\''/$'\''\n'\''}"; done; rm -f "$TMP"; fi'`
