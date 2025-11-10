# PostgreSQL Optimization Patterns

This reference provides detailed PostgreSQL query optimization strategies, EXPLAIN analysis, and performance tuning techniques.

## Understanding EXPLAIN Output

### Running EXPLAIN

```typescript
import { sql } from "drizzle-orm";

// Basic EXPLAIN
const explainResult = await db.execute(sql`
  EXPLAIN
  SELECT * FROM users WHERE email = 'john@example.com'
`);

// EXPLAIN ANALYZE (actually runs the query)
const analyzeResult = await db.execute(sql`
  EXPLAIN ANALYZE
  SELECT u.*, p.title
  FROM users u
  LEFT JOIN posts p ON u.id = p.user_id
  WHERE u.is_active = true
`);
```

### Key Metrics to Monitor

| Metric                   | Good                  | Bad                       | Action                                     |
| ------------------------ | --------------------- | ------------------------- | ------------------------------------------ |
| **Seq Scan**             | Rare, on small tables | Frequent, on large tables | Add index                                  |
| **Index Scan**           | Common                | -                         | Good performance                           |
| **Index Only Scan**      | Ideal                 | -                         | Best performance (includes covering index) |
| **Execution Time**       | <50ms simple queries  | >200ms                    | Optimize query/add indexes                 |
| **Rows**                 | Matches result count  | Much higher than result   | Add WHERE filters                          |
| **Buffers (shared hit)** | High percentage       | Low percentage            | Data in cache                              |

### Common EXPLAIN Patterns

**Sequential Scan (needs optimization):**

```
Seq Scan on users  (cost=0.00..458.00 rows=1 width=64)
  Filter: (email = 'john@example.com')
```

**Solution:** Add index on `email` column.

**Index Scan (good):**

```
Index Scan using email_idx on users  (cost=0.29..8.30 rows=1 width=64)
  Index Cond: (email = 'john@example.com')
```

**Index Only Scan (best):**

```
Index Only Scan using email_status_idx on users  (cost=0.29..4.31 rows=1 width=16)
  Index Cond: (email = 'john@example.com')
```

## Index Strategies

### Types of Indexes

#### 1. B-Tree Index (Default)

Best for equality and range queries. Use for most scenarios.

```typescript
export const users = pgTable(
  "users",
  {
    id: serial("id").primaryKey(),
    email: varchar("email", { length: 255 }).notNull(),
    createdAt: timestamp("created_at").defaultNow().notNull(),
  },
  (table) => ({
    // Single column index
    emailIdx: uniqueIndex("email_idx").on(table.email),

    // Composite index (order matters!)
    createdEmailIdx: index("created_email_idx").on(
      table.createdAt,
      table.email,
    ),
  }),
);
```

**When to use:**

- Equality checks: `WHERE email = 'x'`
- Range queries: `WHERE created_at > '2024-01-01'`
- Sorting: `ORDER BY created_at`
- Pattern matching with prefix: `WHERE username LIKE 'john%'`

#### 2. Hash Index

Best for exact equality comparisons only (no range queries).

```typescript
import { index } from "drizzle-orm/pg-core";

export const sessions = pgTable(
  "sessions",
  {
    id: serial("id").primaryKey(),
    token: varchar("token", { length: 255 }).notNull(),
  },
  (table) => ({
    tokenIdx: index("token_hash_idx").on(table.token).using("hash"),
  }),
);
```

**When to use:**

- Only equality checks: `WHERE token = 'abc123'`
- Hash is faster than B-tree for equality, but doesn't support ranges

#### 3. GIN Index (Generalized Inverted Index)

Best for JSONB, arrays, full-text search.

```typescript
import { index, jsonb } from "drizzle-orm/pg-core";

export const products = pgTable(
  "products",
  {
    id: serial("id").primaryKey(),
    metadata: jsonb("metadata"),
    tags: text("tags").array(),
  },
  (table) => ({
    metadataIdx: index("metadata_gin_idx").on(table.metadata).using("gin"),
    tagsIdx: index("tags_gin_idx").on(table.tags).using("gin"),
  }),
);
```

**When to use:**

- JSONB containment: `WHERE metadata @> '{"category": "electronics"}'`
- Array operations: `WHERE 'urgent' = ANY(tags)`
- Full-text search: `WHERE to_tsvector(content) @@ to_tsquery('postgresql')`

#### 4. GiST Index (Generalized Search Tree)

Best for geometric data, ranges, full-text search.

```typescript
import { index } from "drizzle-orm/pg-core";

export const locations = pgTable(
  "locations",
  {
    id: serial("id").primaryKey(),
    coordinates: text("coordinates"), // PostGIS point type
  },
  (table) => ({
    coordsIdx: index("coords_gist_idx").on(table.coordinates).using("gist"),
  }),
);
```

**When to use:**

- Geometric operations
- Range overlaps
- Nearest-neighbor searches

#### 5. BRIN Index (Block Range Index)

Best for very large tables with natural ordering (time-series data).

```typescript
export const logs = pgTable(
  "logs",
  {
    id: serial("id").primaryKey(),
    createdAt: timestamp("created_at").defaultNow().notNull(),
    message: text("message"),
  },
  (table) => ({
    createdBrinIdx: index("created_brin_idx").on(table.createdAt).using("brin"),
  }),
);
```

**When to use:**

- Large tables (>1M rows) with naturally ordered data
- Time-series data where queries filter by time ranges
- Much smaller than B-tree but less precise

### Composite Index Guidelines

**Order matters!** The leftmost columns must be used in queries for the index to apply.

```typescript
export const orders = pgTable(
  "orders",
  {
    id: serial("id").primaryKey(),
    userId: integer("user_id").notNull(),
    status: varchar("status", { length: 20 }).notNull(),
    createdAt: timestamp("created_at").defaultNow().notNull(),
  },
  (table) => ({
    // Composite index: user_id, status, created_at
    userStatusIdx: index("user_status_created_idx").on(
      table.userId,
      table.status,
      table.createdAt,
    ),
  }),
);
```

**This index can optimize:**

- ✅ `WHERE user_id = 1`
- ✅ `WHERE user_id = 1 AND status = 'active'`
- ✅ `WHERE user_id = 1 AND status = 'active' AND created_at > '2024-01-01'`
- ❌ `WHERE status = 'active'` (user_id not used)
- ❌ `WHERE created_at > '2024-01-01'` (user_id not used)

**Order by selectivity:** Most selective column first (fewest duplicates).

### Partial Indexes

Index only a subset of rows for frequently queried conditions.

```typescript
export const users = pgTable(
  "users",
  {
    id: serial("id").primaryKey(),
    status: varchar("status", { length: 20 }).notNull(),
    email: varchar("email", { length: 255 }).notNull(),
  },
  (table) => ({
    // Only index active users (much smaller index)
    activeEmailIdx: index("active_email_idx")
      .on(table.email)
      .where(sql`${table.status} = 'active'`),
  }),
);
```

**Benefits:**

- Smaller index size → faster updates
- Optimized for specific queries
- Use when most queries filter by a specific condition

### Covering Indexes (INCLUDE)

Include additional columns in the index to avoid table lookups (Index Only Scan).

```typescript
import { index } from "drizzle-orm/pg-core";

export const users = pgTable(
  "users",
  {
    id: serial("id").primaryKey(),
    email: varchar("email", { length: 255 }).notNull(),
    username: varchar("username", { length: 50 }).notNull(),
    status: varchar("status", { length: 20 }).notNull(),
  },
  (table) => ({
    // Index on email, but include username in index data
    emailWithUsernameIdx: index("email_username_idx")
      .on(table.email)
      .include(table.username, table.status),
  }),
);
```

**Query optimization:**

```typescript
// This query uses Index Only Scan (no table lookup needed)
const result = await db
  .select({ email: users.email, username: users.username })
  .from(users)
  .where(eq(users.email, "john@example.com"));
```

## Query Optimization Patterns

### 1. N+1 Query Elimination

**Problem:** Loading related data in a loop causes N+1 database queries.

```typescript
// ❌ BAD: N+1 queries (1 for users + N for each user's posts)
const users = await db.select().from(users);
for (const user of users) {
  const userPosts = await db
    .select()
    .from(posts)
    .where(eq(posts.userId, user.id));

  console.log(`${user.username}: ${userPosts.length} posts`);
}
```

**Solution 1: Use Drizzle relational queries**

```typescript
// ✅ GOOD: Single query with join
const usersWithPosts = await db.query.users.findMany({
  with: {
    posts: true,
  },
});

usersWithPosts.forEach((user) => {
  console.log(`${user.username}: ${user.posts.length} posts`);
});
```

**Solution 2: Manual join**

```typescript
// ✅ GOOD: Explicit join
const usersWithPosts = await db
  .select({
    userId: users.id,
    username: users.username,
    postId: posts.id,
    postTitle: posts.title,
  })
  .from(users)
  .leftJoin(posts, eq(users.id, posts.userId));

// Group results manually if needed
const grouped = usersWithPosts.reduce(
  (acc, row) => {
    if (!acc[row.userId]) {
      acc[row.userId] = { username: row.username, posts: [] };
    }
    if (row.postId) {
      acc[row.userId].posts.push({ id: row.postId, title: row.postTitle });
    }
    return acc;
  },
  {} as Record<
    number,
    { username: string; posts: Array<{ id: number; title: string }> }
  >,
);
```

**Solution 3: Batch loading (DataLoader pattern)**

```typescript
// For GraphQL or complex scenarios
import DataLoader from "dataloader";

const postLoader = new DataLoader(async (userIds: number[]) => {
  const posts = await db
    .select()
    .from(posts)
    .where(inArray(posts.userId, userIds));

  // Group by userId
  const grouped = userIds.map((userId) =>
    posts.filter((post) => post.userId === userId),
  );
  return grouped;
});

// Usage
const users = await db.select().from(users);
await Promise.all(
  users.map(async (user) => {
    const userPosts = await postLoader.load(user.id);
    console.log(`${user.username}: ${userPosts.length} posts`);
  }),
);
```

### 2. Efficient Pagination

**Offset Pagination (simple but slow for large offsets):**

```typescript
// ❌ SLOW: Skipping 10,000 rows is expensive
const page = await db
  .select()
  .from(users)
  .orderBy(users.createdAt)
  .limit(20)
  .offset(10000);
```

**Cursor-Based Pagination (fast for all pages):**

```typescript
// ✅ FAST: Uses index, no skipping
const cursor = lastUser.id; // From previous page

const nextPage = await db
  .select()
  .from(users)
  .where(gt(users.id, cursor))
  .orderBy(users.id)
  .limit(20);

// For descending order
const prevPage = await db
  .select()
  .from(users)
  .where(lt(users.id, cursor))
  .orderBy(desc(users.id))
  .limit(20);
```

**Keyset Pagination (for non-unique ordering):**

```typescript
// For ordering by non-unique column (e.g., createdAt)
interface Cursor {
  createdAt: Date;
  id: number; // Tiebreaker
}

const cursor: Cursor = { createdAt: lastUser.createdAt, id: lastUser.id };

const nextPage = await db
  .select()
  .from(users)
  .where(
    or(
      gt(users.createdAt, cursor.createdAt),
      and(eq(users.createdAt, cursor.createdAt), gt(users.id, cursor.id)),
    ),
  )
  .orderBy(users.createdAt, users.id)
  .limit(20);
```

### 3. Aggregate Query Optimization

**Problem:** Aggregates without indexes are slow.

```typescript
// ❌ SLOW: Sequential scan to count
const userCount = await db
  .select({ count: count() })
  .from(users)
  .where(eq(users.status, "active"));
```

**Solution: Add index on filtered column**

```typescript
// Define index in schema
export const users = pgTable(
  "users",
  {
    id: serial("id").primaryKey(),
    status: varchar("status", { length: 20 }).notNull(),
  },
  (table) => ({
    statusIdx: index("status_idx").on(table.status),
  }),
);

// ✅ FAST: Uses index
const userCount = await db
  .select({ count: count() })
  .from(users)
  .where(eq(users.status, "active"));
```

**For large tables: Use approximate counts**

```typescript
// Exact count (slow for large tables)
const exactCount = await db.select({ count: count() }).from(users);

// Approximate count (fast, uses statistics)
const approxCount = await db.execute(sql`
  SELECT reltuples::bigint AS estimate
  FROM pg_class
  WHERE relname = 'users'
`);
```

### 4. Subquery to JOIN Transformation

**Problem:** Correlated subqueries execute once per row.

```typescript
// ❌ SLOW: Correlated subquery
const usersWithPostCount = await db.execute(sql`
  SELECT
    u.*,
    (SELECT COUNT(*) FROM posts p WHERE p.user_id = u.id) as post_count
  FROM users u
`);
```

**Solution: Use JOIN with GROUP BY**

```typescript
// ✅ FAST: Single scan with grouping
const usersWithPostCount = await db
  .select({
    userId: users.id,
    username: users.username,
    postCount: count(posts.id),
  })
  .from(users)
  .leftJoin(posts, eq(users.id, posts.userId))
  .groupBy(users.id, users.username);
```

### 5. Batch Operations

**Problem:** Individual inserts/updates in loops are slow.

```typescript
// ❌ SLOW: N separate queries
for (const userData of usersData) {
  await db.insert(users).values(userData);
}
```

**Solution: Bulk insert**

```typescript
// ✅ FAST: Single query
await db.insert(users).values(usersData);
```

**For updates with different values:**

```typescript
// Use CASE statement
await db.execute(sql`
  UPDATE users
  SET status = CASE
    WHEN id = 1 THEN 'active'
    WHEN id = 2 THEN 'inactive'
    WHEN id = 3 THEN 'pending'
  END
  WHERE id IN (1, 2, 3)
`);
```

## Monitoring and Diagnostics

### Find Slow Queries

Enable `pg_stat_statements` extension:

```sql
CREATE EXTENSION IF NOT EXISTS pg_stat_statements;
```

Query slow queries:

```typescript
const slowQueries = await db.execute(sql`
  SELECT
    query,
    calls,
    total_exec_time,
    mean_exec_time,
    max_exec_time
  FROM pg_stat_statements
  ORDER BY mean_exec_time DESC
  LIMIT 20
`);
```

### Find Missing Indexes

```typescript
const missingIndexes = await db.execute(sql`
  SELECT
    schemaname,
    tablename,
    seq_scan,
    seq_tup_read,
    idx_scan,
    seq_tup_read / seq_scan AS avg_seq_tup_read
  FROM pg_stat_user_tables
  WHERE seq_scan > 0
  ORDER BY seq_tup_read DESC
  LIMIT 20
`);
```

### Find Unused Indexes

```typescript
const unusedIndexes = await db.execute(sql`
  SELECT
    schemaname,
    tablename,
    indexname,
    idx_scan,
    pg_size_pretty(pg_relation_size(indexrelid)) AS index_size
  FROM pg_stat_user_indexes
  WHERE idx_scan = 0
    AND indexrelname NOT LIKE '%_pkey'
  ORDER BY pg_relation_size(indexrelid) DESC
`);
```

### Check Index Usage

```typescript
const indexUsage = await db.execute(sql`
  SELECT
    schemaname,
    tablename,
    indexname,
    idx_scan,
    idx_tup_read,
    idx_tup_fetch
  FROM pg_stat_user_indexes
  ORDER BY idx_scan DESC
`);
```

## Connection Pooling

### Configure Connection Pool

```typescript
import postgres from "postgres";
import { drizzle } from "drizzle-orm/postgres-js";

const client = postgres(process.env.DATABASE_URL!, {
  max: 20, // Maximum pool size
  idle_timeout: 20, // Close idle connections after 20 seconds
  max_lifetime: 60 * 30, // Close connections after 30 minutes
  connection: {
    application_name: "my-app", // For monitoring
  },
});

const db = drizzle(client);
```

### Pool Size Guidelines

- **Web apps:** `pool_size = (2 × CPU_cores) + 1` (e.g., 9 for 4 cores)
- **Background workers:** Smaller pool (5-10 connections)
- **Serverless:** Use connection pooler (PgBouncer, Supabase Pooler, Neon)

### Using PgBouncer for Serverless

```typescript
// Connection pooler URL (transaction mode)
const poolerUrl = process.env.DATABASE_POOLER_URL!;

const client = postgres(poolerUrl, {
  max: 1, // Serverless functions should use 1 connection
  prepare: false, // Transaction mode doesn't support prepared statements
});

const db = drizzle(client);
```

## Caching Strategies

### Application-Level Caching

```typescript
import { Redis } from "ioredis";

const redis = new Redis(process.env.REDIS_URL);

async function getCachedUser(userId: number) {
  const cacheKey = `user:${userId}`;

  // Check cache first
  const cached = await redis.get(cacheKey);
  if (cached) {
    return JSON.parse(cached);
  }

  // Cache miss: query database
  const user = await db.query.users.findFirst({
    where: eq(users.id, userId),
  });

  if (user) {
    // Cache for 5 minutes
    await redis.setex(cacheKey, 300, JSON.stringify(user));
  }

  return user;
}
```

### Materialized Views

For expensive, frequently-run queries:

```sql
CREATE MATERIALIZED VIEW user_stats AS
SELECT
  u.id,
  u.username,
  COUNT(p.id) as post_count,
  MAX(p.created_at) as last_post_at
FROM users u
LEFT JOIN posts p ON u.id = p.user_id
GROUP BY u.id, u.username;

-- Create index on materialized view
CREATE INDEX user_stats_username_idx ON user_stats(username);

-- Refresh periodically (via cron or trigger)
REFRESH MATERIALIZED VIEW CONCURRENTLY user_stats;
```

Query materialized view in Drizzle:

```typescript
import { pgMaterializedView } from "drizzle-orm/pg-core";

export const userStats = pgMaterializedView("user_stats").as((qb) =>
  qb
    .select({
      id: users.id,
      username: users.username,
      postCount: count(posts.id),
      lastPostAt: max(posts.createdAt),
    })
    .from(users)
    .leftJoin(posts, eq(users.id, posts.userId))
    .groupBy(users.id, users.username),
);

// Query the materialized view
const stats = await db.select().from(userStats);
```

## Best Practices Summary

1. **Always use EXPLAIN ANALYZE** to understand query performance
2. **Index strategically:** Index filtered, joined, and ordered columns
3. **Composite indexes:** Order by selectivity (most selective first)
4. **Avoid N+1:** Use joins or relational queries instead of loops
5. **Use cursor pagination** for large result sets
6. **Batch operations:** Bulk insert/update instead of loops
7. **Monitor regularly:** Track slow queries and index usage
8. **Connection pooling:** Configure appropriate pool size
9. **Cache effectively:** Use Redis for frequently accessed data
10. **Materialized views:** For expensive aggregations

Refer to this document when debugging slow queries or optimizing database performance.
