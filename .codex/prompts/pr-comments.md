Handle and resolve every review thread.

### Setup
- Define targets once: `export GH_REPO=org/name PR_NUMBER=123 ARGS="--repo $GH_REPO --pr $PR_NUMBER"`
- Keep local branch rebased; stash unrelated work before sweeping comments.

### Gather context
- Timeline (general + summaries): `gh pr view $ARGS --comments`
- Diff with numbers: `gh pr diff $ARGS`
- Structured review threads (id, status, file/line, bodies):
  ```bash
  gh api graphql \
    -F owner="${GH_REPO%/*}" \
    -F name="${GH_REPO#*/}" \
    -F pr="$PR_NUMBER" \
    -f query='query($owner:String!,$name:String!,$pr:Int!){repository(owner:$owner,name:$name){pullRequest(number:$pr){reviewThreads(first:100){nodes{id isResolved isOutdated comments(first:20){nodes{id databaseId body url path originalLine line startLine originalStartLine author{login}}}}}}}}'
  ```

### Fix loop
1. Walk each thread newest→oldest; open `path:line` where provided.
2. Understand ask, edit code, add/extend tests covering the change.
3. Run full project checks before replying.
4. Craft reply referencing the commit SHA and test outcome.

### Reply + resolve
- Reply inline to an existing thread:
  ```bash
  gh api graphql \
    -F pullRequestReviewThreadId=<threadId> \
    -F body='<short fix summary + tests>' \
    -f query='mutation($pullRequestReviewThreadId:ID!,$body:String!){addPullRequestReviewThreadReply(input:{pullRequestReviewThreadId:$pullRequestReviewThreadId,body:$body}){comment{id url}}}'
  ```
- Resolve after verifying merge-ready:
  ```bash
  gh api graphql \
    -F threadId=<threadId> \
    -f query='mutation($threadId:ID!){resolveReviewThread(input:{threadId:$threadId}){thread{id isResolved}}}'
  ```

### Finish
- Group fixes logically: `git add <files> && git commit -m "fix(pr-review): ..."`
- Push, rerun `gh pr view $ARGS --comments` to confirm no open threads.
