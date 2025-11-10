---
name: rr-drizzle
description: Comprehensive guidance for implementing type-safe database operations with Drizzle ORM and PostgreSQL. Use when working with database schemas, queries, migrations, or performance optimization in TypeScript applications. Automatically triggered when working with Drizzle schema files, database queries, or PostgreSQL operations.
---

# Drizzle ORM + PostgreSQL

## Overview

Drizzle is a lightweight (~7.4kb minified), type-safe TypeScript ORM with zero dependencies designed for modern serverless environments. This skill provides comprehensive guidance for:

- Defining type-safe database schemas
- Performing efficient CRUD operations and complex queries
- Managing migrations with Drizzle Kit
- Optimizing PostgreSQL performance (indexing, query plans, N+1 elimination)
- Integrating with Bun's native SQL API when needed

This skill combines Drizzle's developer experience with PostgreSQL's power and reliability.

## Quick Start

### Installation

```bash
bun add drizzle-orm postgres
bun add -D drizzle-kit
```

### Basic Configuration

Create `drizzle.config.ts`:

```typescript
import { defineConfig } from "drizzle-kit";

export default defineConfig({
  dialect: "postgresql",
  schema: "./src/db/schema.ts",
  out: "./drizzle",
  dbCredentials: {
    url: process.env.DATABASE_URL!,
  },
});
```

### Connection Setup

```typescript
import { drizzle } from "drizzle-orm/postgres-js";
import postgres from "postgres";

const client = postgres(process.env.DATABASE_URL!);
const db = drizzle(client);
```

**Using Bun's Native SQL** (when Drizzle integration is available):

```typescript
import { SQL } from "bun";
import { drizzle } from "drizzle-orm/bun-sqlite"; // Check for postgres support

const sql = new SQL(process.env.DATABASE_URL!);
const db = drizzle(sql);
```

## Schema Definition

### Table Definition Syntax

Use `pgTable` for PostgreSQL-specific features:

```typescript
import {
  pgTable,
  serial,
  text,
  varchar,
  timestamp,
  integer,
  boolean,
  index,
  uniqueIndex,
} from "drizzle-orm/pg-core";

export const users = pgTable(
  "users",
  {
    id: serial("id").primaryKey(),
    username: varchar("username", { length: 50 }).notNull().unique(),
    email: varchar("email", { length: 255 }).notNull().unique(),
    passwordHash: text("password_hash").notNull(),
    isActive: boolean("is_active").default(true).notNull(),
    createdAt: timestamp("created_at").defaultNow().notNull(),
    updatedAt: timestamp("updated_at").defaultNow().notNull(),
  },
  (table) => ({
    // Indexes defined as return value
    emailIdx: uniqueIndex("email_idx").on(table.email),
    usernameIdx: index("username_idx").on(table.username),
  }),
);
```

### Common Column Types

| Type               | Drizzle Syntax                                    | PostgreSQL Type |
| ------------------ | ------------------------------------------------- | --------------- |
| Auto-increment ID  | `serial('id')`                                    | `SERIAL`        |
| UUID               | `uuid('id').defaultRandom()`                      | `UUID`          |
| String (fixed)     | `varchar('name', { length: 255 })`                | `VARCHAR(255)`  |
| String (unlimited) | `text('description')`                             | `TEXT`          |
| Integer            | `integer('count')`                                | `INTEGER`       |
| BigInt             | `bigint('amount', { mode: 'number' })`            | `BIGINT`        |
| Decimal            | `numeric('price', { precision: 10, scale: 2 })`   | `NUMERIC(10,2)` |
| Boolean            | `boolean('is_active')`                            | `BOOLEAN`       |
| Date               | `date('birth_date')`                              | `DATE`          |
| Timestamp          | `timestamp('created_at')`                         | `TIMESTAMP`     |
| Timestamp with TZ  | `timestamp('created_at', { withTimezone: true })` | `TIMESTAMPTZ`   |
| JSON               | `json('metadata')`                                | `JSON`          |
| JSONB              | `jsonb('settings')`                               | `JSONB`         |

### Relationships

Define relationships using Drizzle's relational syntax:

```typescript
import { relations } from "drizzle-orm";

export const users = pgTable("users", {
  id: serial("id").primaryKey(),
  name: text("name").notNull(),
});

export const posts = pgTable("posts", {
  id: serial("id").primaryKey(),
  title: text("title").notNull(),
  userId: integer("user_id")
    .notNull()
    .references(() => users.id),
});

// Define relations (soft relations - no DB-level foreign keys unless specified)
export const usersRelations = relations(users, ({ many }) => ({
  posts: many(posts),
}));

export const postsRelations = relations(posts, ({ one }) => ({
  author: one(users, {
    fields: [posts.userId],
    references: [users.id],
  }),
}));
```

## Queries

### Basic CRUD Operations

**Select:**

```typescript
// Select all
const allUsers = await db.select().from(users);

// Select specific columns
const usernames = await db.select({ name: users.username }).from(users);

// With where clause
import { eq, and, or, gt, like } from "drizzle-orm";

const activeUsers = await db
  .select()
  .from(users)
  .where(eq(users.isActive, true));

// Multiple conditions
const result = await db
  .select()
  .from(users)
  .where(
    and(eq(users.isActive, true), gt(users.createdAt, new Date("2024-01-01"))),
  );

// LIKE queries
const searchResults = await db
  .select()
  .from(users)
  .where(like(users.username, "%john%"));
```

**Insert:**

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

// Bulk insert
const newUsers = await db
  .insert(users)
  .values([
    { username: "alice", email: "alice@example.com", passwordHash: "hash1" },
    { username: "bob", email: "bob@example.com", passwordHash: "hash2" },
  ])
  .returning();
```

**Update:**

```typescript
const updated = await db
  .update(users)
  .set({ isActive: false })
  .where(eq(users.id, 1))
  .returning();
```

**Delete:**

```typescript
await db.delete(users).where(eq(users.id, 1));
```

### Joins

```typescript
// Inner join
const usersWithPosts = await db
  .select({
    userId: users.id,
    username: users.username,
    postTitle: posts.title,
  })
  .from(users)
  .innerJoin(posts, eq(users.id, posts.userId));

// Left join
const allUsersWithOptionalPosts = await db
  .select()
  .from(users)
  .leftJoin(posts, eq(users.id, posts.userId));
```

### Using Relational Queries (Preferred for Complex Relationships)

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
    },
  },
});
```

### Transactions

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

  await tx.insert(posts).values({ title: "First Post", userId: user[0].id });

  // Automatically commits on success, rolls back on error
});
```

### Raw SQL with Type Safety

Use the `sql` tagged template for custom queries:

```typescript
import { sql } from "drizzle-orm";

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
```

## Migrations

### Generating Migrations

```bash
# Generate migration from schema changes
bun drizzle-kit generate

# Apply migrations
bun drizzle-kit migrate

# Pull existing schema from database
bun drizzle-kit pull

# Push schema directly (dev only - skips migrations)
bun drizzle-kit push

# Open Drizzle Studio (visual DB management)
bun drizzle-kit studio
```

### Migration Workflow

1. Modify `schema.ts`
2. Run `bun drizzle-kit generate` to create migration SQL
3. Review generated SQL in `drizzle/` directory
4. Apply with `bun drizzle-kit migrate` or run SQL manually
5. Commit both schema and migration files

### Applying Migrations in Code

```typescript
import { drizzle } from "drizzle-orm/postgres-js";
import { migrate } from "drizzle-orm/postgres-js/migrator";
import postgres from "postgres";

const client = postgres(process.env.DATABASE_URL!, { max: 1 });
const db = drizzle(client);

await migrate(db, { migrationsFolder: "./drizzle" });

await client.end();
```

## Performance Optimization

### Indexing Strategies

**Create indexes in schema definition:**

```typescript
export const users = pgTable(
  "users",
  {
    id: serial("id").primaryKey(),
    email: varchar("email", { length: 255 }).notNull(),
    username: varchar("username", { length: 50 }).notNull(),
    status: varchar("status", { length: 20 }).notNull(),
    createdAt: timestamp("created_at").defaultNow().notNull(),
  },
  (table) => ({
    // Unique index for uniqueness constraints + fast lookups
    emailIdx: uniqueIndex("email_idx").on(table.email),

    // Regular index for frequently filtered columns
    statusIdx: index("status_idx").on(table.status),

    // Composite index for multi-column queries
    statusCreatedIdx: index("status_created_idx").on(
      table.status,
      table.createdAt,
    ),

    // Partial index (conditional)
    activeUsersIdx: index("active_users_idx")
      .on(table.status)
      .where(sql`${table.status} = 'active'`),
  }),
);
```

**Index best practices:**

- Index columns used in `WHERE`, `JOIN`, `ORDER BY` clauses
- Create composite indexes when filtering by multiple columns together
- Use partial indexes for frequently queried subsets
- Monitor index usage with `pg_stat_user_indexes`
- Avoid over-indexing (slows writes and increases storage)

### Query Optimization

**1. Select Only Required Columns:**

```typescript
// ❌ Bad: Selecting all columns
const users = await db.select().from(users);

// ✅ Good: Select only needed columns
const usernames = await db
  .select({ id: users.id, name: users.username })
  .from(users);
```

**2. Eliminate N+1 Queries:**

```typescript
// ❌ Bad: N+1 query problem
const users = await db.select().from(users);
for (const user of users) {
  const posts = await db.select().from(posts).where(eq(posts.userId, user.id));
}

// ✅ Good: Use joins or relational queries
const usersWithPosts = await db.query.users.findMany({
  with: { posts: true },
});
```

**3. Use Efficient Pagination:**

```typescript
// ❌ Bad: OFFSET pagination (slow for large offsets)
const page = await db.select().from(users).limit(20).offset(1000);

// ✅ Good: Cursor-based pagination
const cursor = lastUserId;
const nextPage = await db
  .select()
  .from(users)
  .where(gt(users.id, cursor))
  .limit(20)
  .orderBy(users.id);
```

**4. Batch Operations:**

```typescript
// ❌ Bad: Multiple individual inserts
for (const userData of usersData) {
  await db.insert(users).values(userData);
}

// ✅ Good: Single bulk insert
await db.insert(users).values(usersData);
```

### Analyzing Query Performance

Use `EXPLAIN` to analyze query plans:

```typescript
const result = await db.execute(sql`
  EXPLAIN ANALYZE
  SELECT * FROM users
  WHERE email = 'john@example.com'
`);
console.log(result);
```

**Key metrics to check:**

- **Seq Scan** → Add index if filtering on this column frequently
- **Index Scan** → Good! Using an index
- **Execution Time** → Target <50ms for simple queries
- **Rows** → Check if returning more rows than needed

Refer to `references/optimization-patterns.md` for detailed PostgreSQL optimization strategies.

## Bun Integration

### When to Use Bun.sql Directly

Use Bun's native SQL API when:

- Need direct control over connection pooling
- Working with PostgreSQL-specific features not yet in Drizzle
- Require LISTEN/NOTIFY or COPY operations (when supported)
- Debugging raw query performance

```typescript
import { SQL } from "bun";

const sql = new SQL(process.env.DATABASE_URL!);

// Parameterized query
const users = await sql`SELECT * FROM users WHERE id = ${userId}`;

// Bulk insert
await sql`INSERT INTO users ${sql([
  { name: "Alice", email: "alice@example.com" },
  { name: "Bob", email: "bob@example.com" },
])}`;

// Transaction
await sql.begin(async (tx) => {
  await tx`INSERT INTO users (name) VALUES (${"Charlie"})`;
  await tx`UPDATE accounts SET balance = balance - 100`;
});
```

### Combining Drizzle with Bun.sql

Use Drizzle for type-safe schema and queries, Bun.sql for performance-critical operations:

```typescript
import { drizzle } from "drizzle-orm/postgres-js";
import { SQL } from "bun";
import * as schema from "./schema";

const bunSql = new SQL(process.env.DATABASE_URL!);
const db = drizzle(bunSql as any, { schema });

// Use Drizzle for type-safe operations
const user = await db.query.users.findFirst({
  where: eq(schema.users.email, "john@example.com"),
});

// Use Bun.sql for raw performance
const stats = await bunSql`
  SELECT COUNT(*) as total,
         AVG(age) as avg_age
  FROM users
`;
```

## Best Practices

### Security

**1. Always Use Parameterized Queries:**

```typescript
// ✅ Safe: Drizzle handles parameterization
const user = await db.select().from(users).where(eq(users.email, userInput));

// ✅ Safe: Bun.sql parameterization
const result = await sql`SELECT * FROM users WHERE email = ${userInput}`;

// ❌ NEVER: String concatenation (SQL injection risk)
const unsafe = await db.execute(
  sql.raw(`SELECT * FROM users WHERE email = '${userInput}'`),
);
```

**2. Set Secure Search Path:**

```typescript
// Execute on connection establishment
await db.execute(sql`SELECT pg_catalog.set_config('search_path', '', false)`);
```

**3. Use Environment Variables for Credentials:**

```typescript
// Never hardcode credentials
const db = drizzle(postgres(process.env.DATABASE_URL!));
```

### Schema Design

**1. Use Appropriate Data Types:**

- `JSONB` for flexible, queryable JSON (not `JSON`)
- `TIMESTAMPTZ` for timestamps with timezone awareness
- `VARCHAR` with length limits for bounded strings
- `TEXT` for unbounded strings

**2. Define Constraints in Schema:**

```typescript
export const users = pgTable(
  "users",
  {
    id: serial("id").primaryKey(),
    email: varchar("email", { length: 255 }).notNull().unique(),
    age: integer("age").$type<number>().notNull(),
  },
  (table) => ({
    // Check constraints
    ageCheck: check(
      "age_check",
      sql`${table.age} >= 0 AND ${table.age} <= 150`,
    ),
  }),
);
```

**3. Use Relations for Type Safety:**

Define relations even if not enforcing foreign keys at DB level:

```typescript
export const postsRelations = relations(posts, ({ one }) => ({
  author: one(users, {
    fields: [posts.userId],
    references: [users.id],
  }),
}));
```

### Common Pitfalls

**1. Forgetting to Return Updated Rows:**

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

**2. Not Handling Unique Constraint Violations:**

```typescript
try {
  await db.insert(users).values({ email: "duplicate@example.com" });
} catch (error) {
  if (error.code === "23505") {
    // Unique violation
    console.error("Email already exists");
  }
  throw error;
}
```

**3. Missing Transaction Boundaries:**

```typescript
// ❌ Bad: Multiple related operations without transaction
await db.insert(users).values(userData);
await db.insert(accounts).values(accountData);

// ✅ Good: Wrapped in transaction
await db.transaction(async (tx) => {
  await tx.insert(users).values(userData);
  await tx.insert(accounts).values(accountData);
});
```

## Resources

### references/

- `optimization-patterns.md` - PostgreSQL query optimization, EXPLAIN analysis, indexing strategies
- `schema-patterns.md` - Common schema patterns, relationship examples, migration strategies
- `drizzle-recipes.md` - Advanced Drizzle patterns, custom types, helper functions

### scripts/

- `generate-schema.ts` - Script to generate TypeScript schema from existing PostgreSQL database
- `analyze-queries.ts` - Helper to analyze query performance and suggest indexes

Refer to these resources when working on complex optimization, schema design, or migration tasks.
