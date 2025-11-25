---
description: Handle and resolve every PR review thread
allowed-tools: Bash(gh pr view:*), Bash(gh api graphql:*), Bash(gh repo view:*), Bash(git log:*), Bash(git diff:*), Bash(git push:*), Bash(git add:*), Bash(git commit:*), Bash(bash -c:*), Bash(jq:*), Bash(grep:*), Bash(mktemp:*), Bash(head:*), Bash(sort:*)
---

# PR Review Resolution

Complete this workflow. All PR comments are provided in the prompt - use them, don't fetch them yourself.

## Sub-Agent Strategy

Launch sub-agents to process issues while grouping related issues together.

Before processing threads individually:

1. **Analyze & Group**: Review all unresolved threads and group them by:
   - Same file or related files
   - Similar issue type (e.g., type errors, lint issues, style consistency)
   - Related functionality or context
   - Dependencies between fixes

2. **Launch Sub-Agents**: For each group of related issues, launch a sub-agent with:
   - All threads in that group
   - Context about the grouping rationale
   - Instructions to process all threads in the group together

3. **Sub-Agent Processing**: Each sub-agent should:
   - Process all threads in its assigned group
   - Make coordinated fixes when threads are interdependent
   - Commit related fixes together when appropriate
   - Follow the Fix Loop steps below for each thread in its group

4. **Coordination**: The main agent coordinates sub-agents and ensures:
   - All threads are assigned to a group
   - No thread is processed by multiple sub-agents
   - Final verification that all threads are resolved

**Benefits**: Related issues fixed together reduce conflicts, improve code consistency, and enable better test coverage.

## Fix Loop

Execute these steps for each unresolved thread (process newest→oldest):

1. **Open file**: Navigate to `path:line` from thread info
2. **Understand**: Read comment context, identify required change
3. **Fix**: Edit code at `path:line`, maintain style consistency
4. **Test**: Run test-runner agent on changed files, also lint
5. **Review**: Run reviewer agent to verify fix quality
6. **Commit**: Execute `git add <files> && git commit -m "fix(pr-review): address <description>"`
7. **Reply**: Post reply to thread with fix description + commit SHA + test results (see Reply command below)
8. **Resolve in GitHub**: Execute the Resolve command after replying
   - Copy the thread ID from the thread info (it's the `Thread: PRRT_...` value from the unresolved threads list)
   - Run: `gh api graphql --field threadId="<threadId>" --field query='mutation($threadId:ID!){resolveReviewThread(input:{threadId:$threadId}){thread{id isResolved}}}'`
   - Verify the response shows `"isResolved": true` - if not, the thread is not resolved
9. **Verify**: Re-run unresolved threads check to confirm thread is resolved before moving to next thread

## Reply Template

Reply format:

```
Fixed in commit <SHA>.

**Changes:**
- <description of fix>

**Tests:**
- ✓ All tests passing
- ✓ Lint/typecheck clean

<additional context if needed>
```

Reply command:

```bash
# Replace <threadId> with the actual thread ID and <your-reply> with your reply text
gh api graphql --field pullRequestReviewThreadId="<threadId>" --field body="<your-reply>" --field query='mutation($pullRequestReviewThreadId:ID!,$body:String!){addPullRequestReviewThreadReply(input:{pullRequestReviewThreadId:$pullRequestReviewThreadId,body:$body}){comment{id url}}}'
```

## Resolve Thread

Execute this command in GitHub for every thread you fix. The thread will remain open until you run this command.

Only resolve after:

- Fix committed and pushed
- Tests passing
- Reply posted to thread

Resolve command (run after each fix):

```bash
# Replace <threadId> with the actual thread ID (e.g., PRRT_kwDOQG7ygc5gMWuD)
gh api graphql --field threadId="<threadId>" --field query='mutation($threadId:ID!){resolveReviewThread(input:{threadId:$threadId}){thread{id isResolved}}}'
```

**Example:**

```bash
gh api graphql --field threadId="PRRT_kwDOQG7ygc5gMWuD" --field query='mutation($threadId:ID!){resolveReviewThread(input:{threadId:$threadId}){thread{id isResolved}}}'
```

Execute this command for every thread you fix. The thread won't be resolved automatically - you need to explicitly run this command.

## Exit Criteria

Execute before completing:

```bash
# Push all commits
git push

# Verify no unresolved threads remain
gh pr view --comments | grep -i "outstanding\|pending\|unresolved" || echo "✓ All threads resolved"
```

Verify before completion:

- ✓ All threads have been fixed
- ✓ All threads have been replied to
- ✓ All threads have been resolved in GitHub (gh api command executed for each)
- ✓ All commits have been pushed
- ✓ No unresolved threads remain (verified with the gh pr view command above)

If any threads remain unresolved: go back and execute the Resolve command for each one.

## Gather Context

Check for PR:
!`gh pr view --json number,url,title,state -q 'if .number then "\(.number): \(.title) (\(.url)) [\(.state)]" else "ERROR: No PR found for current branch" end' 2>&1`

Recent commits:
!`git log origin/main..HEAD --oneline --no-decorate | head -10`

Files changed:
!`git diff --stat origin/main..HEAD`

PR timeline + comments:
!`gh pr view --comments 2>&1`

Unresolved review threads count:
!`bash -c 'GH_REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null) && PR_NUMBER=$(gh pr view --json number -q .number 2>/dev/null | grep -E "^[0-9]+$") && if [ -z "$GH_REPO" ] || [ -z "$PR_NUMBER" ]; then echo "ERROR: Could not fetch PR info"; else TMP=$(mktemp) && printf '\''query($owner:String!,$name:String!,$pr:Int!){repository(owner:$owner,name:$name){pullRequest(number:$pr){reviewThreads(first:100){nodes{isResolved}}}}}\n'\'' > "$TMP" && gh api graphql --field owner="${GH_REPO%/*}" --field name="${GH_REPO#*/}" --field pr="$PR_NUMBER" --field query=@"$TMP" 2>/dev/null | jq -r '\''if .data.repository.pullRequest then ([.data.repository.pullRequest.reviewThreads.nodes[]? | select(.isResolved == false)] | length | "Total unresolved: \(.)") else "No PR found" end'\''; rm -f "$TMP"; fi'`

Unresolved review threads (newest first):
!`bash -c 'GH_REPO=$(gh repo view --json nameWithOwner -q .nameWithOwner 2>/dev/null) && PR_NUMBER=$(gh pr view --json number -q .number 2>/dev/null | grep -E "^[0-9]+$") && if [ -z "$GH_REPO" ] || [ -z "$PR_NUMBER" ]; then echo "ERROR: Could not fetch PR info"; else TMP=$(mktemp) && printf '\''query($owner:String!,$name:String!,$pr:Int!){repository(owner:$owner,name:$name){pullRequest(number:$pr){reviewThreads(first:100){nodes{id isResolved isOutdated path line startLine comments(first:20){nodes{id databaseId body author{login} createdAt}}}}}}}\n'\'' > "$TMP" && gh api graphql --field owner="${GH_REPO%/*}" --field name="${GH_REPO#*/}" --field pr="$PR_NUMBER" --field query=@"$TMP" 2>/dev/null | jq -r '\''.data.repository.pullRequest.reviewThreads.nodes[]? | select(.isResolved == false) | select(.comments.nodes | length > 0) | "\(.comments.nodes[0].createdAt)|\(.id)|\(.path // "general")|\(.line // .startLine // "?")|\(.comments.nodes[0].author.login)|\(.comments.nodes[0].body | gsub("\\n"; "\u0001"))"'\'' | sort -t"|" -k1 -r | while IFS="|" read -r date id path line author body; do printf "Thread: %s\nFile: %s:%s\nAuthor: %s\nMessage:\n%s\n---\n" "$id" "$path" "$line" "$author" "${body//$'\''\u0001'\''/$'\''\n'\''}"; done; rm -f "$TMP"; fi'`
