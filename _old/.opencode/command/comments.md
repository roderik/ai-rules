---
description: Add why-first documentation comments to code
agent: code-commenter
---

## Execution

1. Target: recent changes or `$ARGUMENTS` pattern
2. IDE analysis for code structure
3. Comment:
   - Complex business logic/edge cases
   - Performance/security trade-offs
   - Rejected alternatives
   - Non-obvious algorithms
   - Workarounds/tech debt

## Style

**TSDoc:**
```typescript
/**
 * Exponential backoff prevents gateway overload per SLA.
 *
 * @param payment - Payment details
 * @param maxRetries - Max attempts (default 3)
 * @throws PaymentError if exhausted
 */
```

**Inline:**
```typescript
// 5min cache balances DB load vs stale auth risk
const PERMISSION_CACHE_TTL = 5 * 60 * 1000;
```

## Rules

- Explain WHY, not what
- Link to requirements/SLAs/incidents
- Document security/performance implications
- Match existing style
- Remove outdated comments
