Add TSDoc and inline comments explaining WHY code exists, not what it does.

### Workflow
1. Target files from recent changes or matching `$ARGUMENTS`
2. Use IDE analysis to understand code structure and usage
3. Add comments for:
   - Complex business logic and edge cases
   - Performance/security trade-offs
   - Rejected alternatives and design decisions
   - Non-obvious algorithms
   - Workarounds and tech debt

### Comment Style

**TSDoc for functions:**
```typescript
/**
 * Processes payment using exponential backoff to handle gateway failures.
 *
 * Exponential retries prevent load spikes per gateway SLA requirements.
 *
 * @param payment - Payment details
 * @param maxRetries - Max attempts (default 3)
 * @returns Payment result
 * @throws PaymentError if all retries fail
 */
```

**Inline for critical constants:**
```typescript
// Cache 5min to balance DB load with stale auth risk
const PERMISSION_CACHE_TTL = 5 * 60 * 1000;
```

### Rules
- Explain WHY, not what: "Tracks user interactions for analytics attribution"
- Link to domain requirements, SLAs, incidents when relevant
- Document security/performance implications
- Match existing comment style and indentation
- Remove outdated comments found during review

### Commands
```bash
git diff --name-only HEAD~1..HEAD
git status --porcelain
```
