# GitHub Actions Monitoring and Interaction

## Monitoring CI/CD Workflows

### Recommended Workflow After PR Creation

**ALWAYS monitor CI runs after creating or pushing to a PR:**

```bash
# 1. Create PR
gh pr create --title "feat: new feature" --body "Description"

# 2. Get PR number
PR_NUM=$(gh pr view --json number --jq .number)

# 3. Watch checks (recommended)
gh pr checks $PR_NUM --watch

# Alternative: Get run ID and watch directly
RUN_ID=$(gh run list --limit=1 --json databaseId --jq '.[0].databaseId')
gh run watch $RUN_ID
```

### Watch Workflow Runs

```bash
# Watch latest run
gh run watch

# Watch specific run
gh run watch 123456

# Watch will show:
# - Job status updates in real-time
# - Failed steps highlighted
# - Success/failure summary
# - Total duration
```

### Check Workflow Status

```bash
# View recent runs
gh run list

# Filter by workflow
gh run list --workflow=ci.yml

# Filter by status
gh run list --status=failure
gh run list --status=in_progress
gh run list --status=success

# Filter by branch
gh run list --branch=main

# Get JSON output for scripting
gh run list --json status,conclusion,databaseId
```

### View Run Details

```bash
# View run summary
gh run view 123456

# View logs
gh run view 123456 --log

# View specific job
gh run view 123456 --job=test --log

# View failed jobs only
gh run view 123456 --log-failed

# Open in browser
gh run view 123456 --web
```

## Interpreting CI Results

### Status States

- **queued**: Run is waiting to start
- **in_progress**: Run is currently executing
- **completed**: Run has finished

### Conclusion States (when completed)

- **success**: All jobs passed
- **failure**: At least one job failed
- **cancelled**: Run was cancelled
- **skipped**: Run was skipped
- **timed_out**: Run exceeded time limit

### Reading Check Results

```bash
# Check PR checks status
gh pr checks

# Sample output:
# ✓ build       3m0s  https://github.com/owner/repo/actions/runs/123
# ✓ test        2m30s https://github.com/owner/repo/actions/runs/123
# ✓ lint        1m15s https://github.com/owner/repo/actions/runs/123
# All checks have passed

# With failures:
# ✓ build       3m0s  https://github.com/owner/repo/actions/runs/123
# X test        2m30s https://github.com/owner/repo/actions/runs/123
# ✓ lint        1m15s https://github.com/owner/repo/actions/runs/123
# Some checks were not successful
```

## Responding to CI Failures

### Investigate Failures

```bash
# View failed run
gh run view 123456 --log-failed

# Download logs for analysis
gh run view 123456 --log > ci-logs.txt

# View specific job
gh run view 123456 --job=test --log
```

### Common Failure Patterns

1. **Test Failures**

   ```bash
   # View test job logs
   gh run view --job=test --log

   # Look for:
   # - Failed test names
   # - Assertion errors
   # - Stack traces
   ```

2. **Lint Failures**

   ```bash
   # View lint job logs
   gh run view --job=lint --log

   # Common issues:
   # - Formatting errors
   # - Import order
   # - Unused variables
   ```

3. **Build Failures**

   ```bash
   # View build job logs
   gh run view --job=build --log

   # Common issues:
   # - Compilation errors
   # - Missing dependencies
   # - Type errors
   ```

### Fix and Retry

```bash
# Fix issues locally
git add .
git commit -m "fix(ci): resolve test failures"
git push

# Watch new run
gh run watch
```

### Rerun Failed Jobs

```bash
# Rerun only failed jobs
gh run rerun 123456

# Rerun all jobs
gh run rerun 123456 --all
```

## Advanced Monitoring

### Real-time Notifications

```bash
# Watch and exit on failure
gh run watch 123456 || echo "CI failed!"

# Watch and capture status
gh run watch 123456
STATUS=$?
if [ $STATUS -ne 0 ]; then
  echo "CI failed with status $STATUS"
fi
```

### Batch Monitoring

```bash
# Check all PRs for failed checks
for pr in $(gh pr list --json number --jq '.[].number'); do
  echo "PR #$pr:"
  gh pr checks $pr
  echo "---"
done
```

### Integration with PR Workflow

```bash
# Complete workflow with monitoring
create_and_monitor_pr() {
  # Create PR
  gh pr create --title "$1" --body "$2"

  # Get PR number
  PR_NUM=$(gh pr view --json number --jq .number)
  echo "Created PR #$PR_NUM"

  # Wait for initial checks to start
  sleep 5

  # Watch checks
  gh pr checks $PR_NUM --watch

  # Get final status
  if gh pr checks $PR_NUM | grep -q "All checks have passed"; then
    echo "✓ All checks passed!"
    return 0
  else
    echo "✗ Some checks failed"
    return 1
  fi
}

# Usage
create_and_monitor_pr "feat: new feature" "Description of changes"
```

## Workflow File Location

GitHub Actions workflows are stored in:

```
.github/workflows/*.yml
```

### View Workflow Configuration

```bash
# View workflow file
cat .github/workflows/ci.yml

# List all workflows
gh workflow list

# View workflow details
gh workflow view ci.yml
```

## Debugging Workflow Issues

### Enable Debug Logging

```bash
# Rerun with debug logging
gh run rerun 123456 --debug
```

### Access Artifacts

```bash
# List artifacts
gh run view 123456 --json artifacts --jq '.artifacts[].name'

# Download specific artifact
gh run download 123456 --name test-results

# Download all artifacts
gh run download 123456
```

### View Job Metadata

```bash
# Get detailed job info
gh api /repos/owner/repo/actions/runs/123456/jobs | jq '.jobs[] | {name, status, conclusion}'
```

## Best Practices

### 1. Always Monitor After Push

```bash
# Bad: Push and forget
git push

# Good: Push and monitor
git push && gh run watch
```

### 2. Use --watch Flag

```bash
# Provides real-time feedback
gh run watch

# vs polling manually
gh run list --limit=1
```

### 3. Check Before Merge

```bash
# Verify all checks pass
gh pr checks

# Verify reviews approved
gh pr view --json reviews

# Then merge
gh pr merge --squash
```

### 4. Set Up Notifications

Configure GitHub to send notifications for:
- Failed workflows
- Required reviews
- Deployment status

### 5. Use Status Checks as Gates

In GitHub settings, configure:
- Required status checks before merge
- Required review approvals
- Branch protection rules

## Troubleshooting Common Issues

### Run Not Starting

```bash
# Check workflow syntax
gh workflow view ci.yml

# Check if workflow is disabled
gh api /repos/owner/repo/actions/workflows | jq '.workflows[] | {name, state}'
```

### Stuck in Queue

```bash
# Check runner availability
gh api /repos/owner/repo/actions/runs/123456 | jq '.status'

# View queue position
gh run list --status=queued
```

### Permission Errors

```bash
# Check workflow permissions
cat .github/workflows/ci.yml | grep -A 5 "permissions:"

# Verify token has required scopes
gh auth status
```

### Timeout Issues

```bash
# Check timeout settings
cat .github/workflows/ci.yml | grep "timeout-minutes"

# Default is 360 minutes (6 hours)
# Increase if needed:
# timeout-minutes: 60
```
