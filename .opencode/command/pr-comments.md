---
description: Handle and resolve every PR review thread
---

## Setup

```bash
export GH_REPO=org/name PR_NUMBER=123 ARGS="--repo $GH_REPO --pr $PR_NUMBER"
```

Keep branch rebased; stash unrelated work.

## Gather Context

```bash
# Timeline + comments
gh pr view $ARGS --comments

# Diff with line numbers
gh pr diff $ARGS

# Structured review threads
gh api graphql \
  -F owner="${GH_REPO%/*}" \
  -F name="${GH_REPO#*/}" \
  -F pr="$PR_NUMBER" \
  -f query='query($owner:String!,$name:String!,$pr:Int!){repository(owner:$owner,name:$name){pullRequest(number:$pr){reviewThreads(first:100){nodes{id isResolved isOutdated comments(first:20){nodes{id databaseId body url path originalLine line startLine originalStartLine author{login}}}}}}}}'
```

## Fix Loop

1. Walk threads newest→oldest, open `path:line`
2. Understand ask, edit code, add/extend tests
3. Run full checks before replying
4. Reply with commit SHA + test outcome

## Reply + Resolve

```bash
# Reply to thread
gh api graphql \
  -F pullRequestReviewThreadId=<threadId> \
  -F body='<fix summary + tests>' \
  -f query='mutation($pullRequestReviewThreadId:ID!,$body:String!){addPullRequestReviewThreadReply(input:{pullRequestReviewThreadId:$pullRequestReviewThreadId,body:$body}){comment{id url}}}'

# Resolve when merge-ready
gh api graphql \
  -F threadId=<threadId> \
  -f query='mutation($threadId:ID!){resolveReviewThread(input:{threadId:$threadId}){thread{id isResolved}}}'
```

## Finish

```bash
# Commit fixes
git add <files> && git commit -m "fix(pr-review): ..."

# Push and verify
git push
gh pr view $ARGS --comments  # Confirm no open threads
```
