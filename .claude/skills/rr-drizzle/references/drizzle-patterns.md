# Drizzle Query Patterns & Best Practices

## Basic CRUD Operations

### Select Queries

```typescript
import {
  eq,
  and,
  or,
  gt,
  lt,
  gte,
  lte,
  like,
  ilike,
  inArray,
  notInArray,
} from "drizzle-orm";

// Select all
const allUsers = await db.select().from(users);

// Select specific columns
const usernames = await db.select({ name: users.username }).from(users);

// With where clause
const activeUsers = await db
  .select()
  .from(users)
  .where(eq(users.isActive, true));

// Multiple conditions with AND
const result = await db
  .select()
  .from(users)
  .where(
    and(eq(users.isActive, true), gt(users.createdAt, new Date("2024-01-01"))),
  );

// Multiple conditions with OR
const result = await db
  .select()
  .from(users)
  .where(or(eq(users.role, "admin"), eq(users.role, "moderator")));

// LIKE queries (case-sensitive)
const searchResults = await db
  .select()
  .from(users)
  .where(like(users.username, "%john%"));

// ILIKE queries (case-insensitive)
const searchResults = await db
  .select()
  .from(users)
  .where(ilike(users.email, "%@gmail.com"));

// IN queries
const specificUsers = await db
  .select()
  .from(users)
  .where(inArray(users.id, [1, 2, 3, 4]));

// Range queries
const recentUsers = await db
  .select()
  .from(users)
  .where(
    and(
      gte(users.createdAt, new Date("2024-01-01")),
      lt(users.createdAt, new Date("2024-02-01")),
    ),
  );
```

### Insert Operations

```typescript
// Single insert
const newUser = await db
  .insert(users)
  .values({
    username: "johndoe",
    email: "john@example.com",
    passwordHash: "hashed_password",
  })
  .returning();

// Access the inserted record
console.log(newUser[0].id);

// Bulk insert
const newUsers = await db
  .insert(users)
  .values([
    { username: "alice", email: "alice@example.com", passwordHash: "hash1" },
    { username: "bob", email: "bob@example.com", passwordHash: "hash2" },
    {
      username: "charlie",
      email: "charlie@example.com",
      passwordHash: "hash3",
    },
  ])
  .returning();

// Insert with onConflict (upsert)
const upsertedUser = await db
  .insert(users)
  .values({ username: "john", email: "john@example.com" })
  .onConflictDoUpdate({
    target: users.email,
    set: { username: "john_updated" },
  })
  .returning();

// Insert and ignore conflicts
await db
  .insert(users)
  .values({ username: "john", email: "john@example.com" })
  .onConflictDoNothing();
```

### Update Operations

```typescript
// Update with where clause
const updated = await db
  .update(users)
  .set({ isActive: false })
  .where(eq(users.id, 1))
  .returning();

// Update multiple fields
const updated = await db
  .update(users)
  .set({
    isActive: false,
    updatedAt: new Date(),
    status: "suspended",
  })
  .where(eq(users.id, 1))
  .returning();

// Conditional update
const updated = await db
  .update(users)
  .set({ lastLogin: new Date() })
  .where(and(eq(users.id, 1), eq(users.isActive, true)))
  .returning();

// Increment counter
import { sql } from "drizzle-orm";

await db
  .update(posts)
  .set({ viewCount: sql`${posts.viewCount} + 1` })
  .where(eq(posts.id, postId));
```

### Delete Operations

```typescript
// Delete with where clause
await db.delete(users).where(eq(users.id, 1));

// Delete multiple records
await db.delete(users).where(lt(users.lastLogin, new Date("2023-01-01")));

// Delete with returning
const deleted = await db.delete(users).where(eq(users.id, 1)).returning();
```

## Joins & Relations

### Manual Joins

```typescript
// Inner join
const usersWithPosts = await db
  .select({
    userId: users.id,
    username: users.username,
    postId: posts.id,
    postTitle: posts.title,
  })
  .from(users)
  .innerJoin(posts, eq(users.id, posts.userId));

// Left join
const allUsersWithOptionalPosts = await db
  .select({
    userId: users.id,
    username: users.username,
    postId: posts.id,
    postTitle: posts.title,
  })
  .from(users)
  .leftJoin(posts, eq(users.id, posts.userId));

// Multiple joins
const complexQuery = await db
  .select({
    user: users.username,
    post: posts.title,
    comment: comments.content,
  })
  .from(users)
  .innerJoin(posts, eq(users.id, posts.userId))
  .leftJoin(comments, eq(posts.id, comments.postId));

// Join with additional conditions
const filtered = await db
  .select()
  .from(users)
  .innerJoin(posts, and(eq(users.id, posts.userId), eq(posts.published, true)));
```

### Relational Queries (Recommended)

```typescript
import { drizzle } from "drizzle-orm/postgres-js";
import * as schema from "./schema";

const db = drizzle(client, { schema });

// Query with nested relations
const usersWithPosts = await db.query.users.findMany({
  with: {
    posts: true, // Automatically joins and returns posts
  },
});

// Filtered nested relations
const activeUsersWithRecentPosts = await db.query.users.findMany({
  where: eq(schema.users.isActive, true),
  with: {
    posts: {
      where: gt(schema.posts.createdAt, new Date("2024-01-01")),
      limit: 10,
      orderBy: [desc(schema.posts.createdAt)],
    },
  },
});

// Deep nesting
const usersWithPostsAndComments = await db.query.users.findMany({
  with: {
    posts: {
      with: {
        comments: {
          with: {
            author: true,
          },
        },
      },
    },
  },
});

// Select specific fields
const usersWithPostTitles = await db.query.users.findMany({
  columns: {
    id: true,
    username: true,
  },
  with: {
    posts: {
      columns: {
        id: true,
        title: true,
      },
    },
  },
});
```

## Transactions

### Basic Transactions

```typescript
await db.transaction(async (tx) => {
  const user = await tx
    .insert(users)
    .values({
      username: "john",
      email: "john@example.com",
      passwordHash: "hash",
    })
    .returning();

  await tx.insert(posts).values({
    title: "First Post",
    userId: user[0].id,
  });

  // Automatically commits on success, rolls back on error
});
```

### Transaction with Error Handling

```typescript
try {
  await db.transaction(async (tx) => {
    const user = await tx
      .insert(users)
      .values({ username: "john", email: "john@example.com" })
      .returning();

    const account = await tx
      .insert(accounts)
      .values({ userId: user[0].id, balance: 0 })
      .returning();

    // If any operation fails, all changes are rolled back
    await tx
      .update(accounts)
      .set({ balance: 1000 })
      .where(eq(accounts.id, account[0].id));
  });
} catch (error) {
  console.error("Transaction failed:", error);
  // All changes have been rolled back
}
```

### Nested Transactions

```typescript
await db.transaction(async (tx) => {
  await tx.insert(users).values({ username: "alice" });

  await tx.transaction(async (nested) => {
    await nested.insert(posts).values({ title: "Post 1" });
    await nested.insert(posts).values({ title: "Post 2" });
  });

  await tx.insert(users).values({ username: "bob" });
});
```

## Aggregations & Grouping

```typescript
import { sql, count, sum, avg, min, max } from "drizzle-orm";

// Count records
const userCount = await db.select({ count: count() }).from(users);

// Count with conditions
const activeUserCount = await db
  .select({ count: count() })
  .from(users)
  .where(eq(users.isActive, true));

// Group by with aggregations
const postsByUser = await db
  .select({
    userId: posts.userId,
    postCount: count(),
    avgLikes: avg(posts.likes),
    totalViews: sum(posts.views),
  })
  .from(posts)
  .groupBy(posts.userId);

// Having clause
const activeAuthors = await db
  .select({
    userId: posts.userId,
    postCount: count(),
  })
  .from(posts)
  .groupBy(posts.userId)
  .having(sql`count(*) > 5`);

// Complex aggregation
const stats = await db
  .select({
    status: users.status,
    total: count(),
    minAge: min(users.age),
    maxAge: max(users.age),
    avgAge: avg(users.age),
  })
  .from(users)
  .groupBy(users.status);
```

## Pagination Patterns

### Offset-Based Pagination (Simple but Slower)

```typescript
const pageSize = 20;
const pageNumber = 1;

const users = await db
  .select()
  .from(users)
  .limit(pageSize)
  .offset(pageNumber * pageSize)
  .orderBy(users.createdAt);

// Get total count for pagination metadata
const totalCount = await db.select({ count: count() }).from(users);
```

### Cursor-Based Pagination (Recommended for Performance)

```typescript
import { gt } from "drizzle-orm";

// First page
const firstPage = await db.select().from(users).limit(20).orderBy(users.id);

// Next pages using cursor
const lastUserId = firstPage[firstPage.length - 1].id;
const nextPage = await db
  .select()
  .from(users)
  .where(gt(users.id, lastUserId))
  .limit(20)
  .orderBy(users.id);
```

### Keyset Pagination (Complex but Most Efficient)

```typescript
import { and, or, gt, eq } from "drizzle-orm";

// For sorting by multiple columns (e.g., createdAt DESC, id DESC)
const lastCreatedAt = lastRecord.createdAt;
const lastId = lastRecord.id;

const nextPage = await db
  .select()
  .from(users)
  .where(
    or(
      lt(users.createdAt, lastCreatedAt),
      and(eq(users.createdAt, lastCreatedAt), lt(users.id, lastId)),
    ),
  )
  .orderBy(desc(users.createdAt), desc(users.id))
  .limit(20);
```

## Raw SQL with Type Safety

### Using sql Tagged Template

```typescript
import { sql } from "drizzle-orm";

// Simple raw query
const result = await db.execute(sql`
  SELECT * FROM ${users}
  WHERE ${users.createdAt} > NOW() - INTERVAL '7 days'
`);

// With parameters (prevents SQL injection)
const userId = 1;
const userPosts = await db.execute(sql`
  SELECT * FROM ${posts}
  WHERE ${posts.userId} = ${userId}
`);

// Complex raw queries
const stats = await db.execute(sql`
  SELECT
    DATE_TRUNC('day', ${posts.createdAt}) as date,
    COUNT(*) as count
  FROM ${posts}
  WHERE ${posts.userId} = ${userId}
  GROUP BY DATE_TRUNC('day', ${posts.createdAt})
  ORDER BY date DESC
`);
```

### Combining SQL Fragments

```typescript
import { sql, eq, and } from "drizzle-orm";

const searchTerm = "john";
const isActive = true;

const conditions = [eq(users.isActive, isActive)];

if (searchTerm) {
  conditions.push(sql`${users.username} ILIKE ${`%${searchTerm}%`}`);
}

const results = await db
  .select()
  .from(users)
  .where(and(...conditions));
```

## Common Pitfalls & Solutions

### 1. Forgetting to Return Updated Rows

```typescript
// ❌ Bad: No return value
await db.update(users).set({ isActive: false }).where(eq(users.id, 1));

// ✅ Good: Get updated row
const updated = await db
  .update(users)
  .set({ isActive: false })
  .where(eq(users.id, 1))
  .returning();
```

### 2. N+1 Query Problem

```typescript
// ❌ Bad: N+1 queries
const users = await db.select().from(users);
for (const user of users) {
  const posts = await db.select().from(posts).where(eq(posts.userId, user.id));
}

// ✅ Good: Use relational queries
const usersWithPosts = await db.query.users.findMany({
  with: { posts: true },
});
```

### 3. Not Handling Unique Constraint Violations

```typescript
try {
  await db.insert(users).values({ email: "duplicate@example.com" });
} catch (error) {
  if (error.code === "23505") {
    // PostgreSQL unique violation error code
    console.error("Email already exists");
  }
  throw error;
}
```

### 4. Missing Transaction Boundaries

```typescript
// ❌ Bad: Multiple related operations without transaction
await db.insert(users).values(userData);
await db.insert(accounts).values(accountData);

// ✅ Good: Wrapped in transaction
await db.transaction(async (tx) => {
  const user = await tx.insert(users).values(userData).returning();
  await tx.insert(accounts).values({ ...accountData, userId: user[0].id });
});
```

### 5. Inefficient Bulk Operations

```typescript
// ❌ Bad: Multiple individual inserts
for (const userData of usersData) {
  await db.insert(users).values(userData);
}

// ✅ Good: Single bulk insert
await db.insert(users).values(usersData);
```

## Performance Optimization

### Select Only Required Columns

```typescript
// ❌ Bad: Selecting all columns
const users = await db.select().from(users);

// ✅ Good: Select only needed columns
const usernames = await db
  .select({ id: users.id, name: users.username })
  .from(users);
```

### Use Efficient Ordering

```typescript
// Ensure columns in ORDER BY are indexed
const sorted = await db.select().from(users).orderBy(users.createdAt); // createdAt should have an index
```

### Batch Related Queries

```typescript
// ❌ Bad: Sequential queries
const user = await db.query.users.findFirst({ where: eq(users.id, 1) });
const posts = await db.query.posts.findMany({ where: eq(posts.userId, 1) });

// ✅ Good: Single query with relations
const userWithPosts = await db.query.users.findFirst({
  where: eq(users.id, 1),
  with: { posts: true },
});
```
