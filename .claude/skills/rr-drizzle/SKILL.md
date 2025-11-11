---
name: rr-drizzle
description: Comprehensive guidance for implementing type-safe database operations with Drizzle ORM and PostgreSQL. Use when working with database schemas, queries, migrations, or performance optimization in TypeScript applications. Also triggers when working with Drizzle schema files (.ts files with pgTable, drizzle imports), migration files, database query code, or drizzle.config.ts files. Example triggers: "Create database schema", "Write Drizzle query", "Generate migration", "Optimize database query", "Set up Drizzle ORM", "Add database table", "Fix query performance"
---

# Drizzle ORM + PostgreSQL

## Overview

Drizzle is a lightweight (~7.4kb), type-safe TypeScript ORM with zero dependencies for modern serverless environments.

**Key Features:** Type-safe schemas/queries, zero runtime overhead, SQL-like syntax, automatic migrations, excellent serverless performance.

**When to Use:** Database schemas, type-safe queries, migrations, performance optimization, Bun SQL integration.

## Development Workflow

### 1. Plan Phase

**Before making changes:**

- [ ] Review existing schema patterns in codebase
- [ ] Check for similar table definitions or query patterns
- [ ] Identify related tables that may need updates
- [ ] Consider indexing needs for query performance
- [ ] Plan migration strategy (new tables vs modifications)

**For new tables:**

- [ ] Define clear relationships with existing tables
- [ ] Plan indexes for common query patterns
- [ ] Consider constraints (unique, check, foreign keys)

**For queries:**

- [ ] Identify if similar queries exist
- [ ] Consider using relational queries vs manual joins
- [ ] Plan for pagination if returning multiple records

### 2. Implement Phase

**Patterns:**

- Use `pgTable` for all PostgreSQL tables
- Define relations for type-safe joins
- Use relational queries for complex data fetching
- Wrap related operations in transactions
- Always use `.returning()` for insert/update operations
- Use `InferSelectModel` and `InferInsertModel` for types
- Add `.$type<>()` for narrowing JSON/enum columns

### 3. Validate Phase (MANDATORY)

**After changes:**

- [ ] Generate migration: `bun drizzle-kit generate`
- [ ] Review generated SQL in `drizzle/` directory
- [ ] Check migration adds proper indexes
- [ ] Verify no data loss in modifications
- [ ] Test migration on local database
- [ ] Run type checking: `bun tsc --noEmit`
- [ ] Verify queries return expected types
- [ ] Test queries with sample data
- [ ] Check performance with EXPLAIN ANALYZE
- [ ] Verify N+1 queries are eliminated

### 4. Optimize Phase

- [ ] Add indexes for frequently queried columns
- [ ] Use cursor-based pagination for large datasets
- [ ] Batch insert/update operations
- [ ] Select only required columns

## Quick Start

```bash
# Install
bun add drizzle-orm postgres
bun add -D drizzle-kit
```

**drizzle.config.ts:**

```typescript
import { defineConfig } from "drizzle-kit";

export default defineConfig({
  dialect: "postgresql",
  schema: "./src/db/schema.ts",
  out: "./drizzle",
  dbCredentials: { url: process.env.DATABASE_URL! },
});
```

**Connection:**

```typescript
import { drizzle } from "drizzle-orm/postgres-js";
import postgres from "postgres";

const client = postgres(process.env.DATABASE_URL!);
const db = drizzle(client);
```

**Commands:**

```bash
bun drizzle-kit generate  # Generate migration
bun drizzle-kit migrate   # Apply migrations
bun drizzle-kit push      # Push schema (dev only)
bun drizzle-kit studio    # Visual DB management
```

See [references/drizzle-commands.md](references/drizzle-commands.md) for complete CLI reference.

## Core Patterns

### Schema

```typescript
import {
  pgTable,
  serial,
  varchar,
  timestamp,
  boolean,
  integer,
  index,
  relations,
} from "drizzle-orm/pg-core";

export const users = pgTable(
  "users",
  {
    id: serial("id").primaryKey(),
    username: varchar("username", { length: 50 }).notNull().unique(),
    email: varchar("email", { length: 255 }).notNull().unique(),
    isActive: boolean("is_active").default(true).notNull(),
    createdAt: timestamp("created_at").defaultNow().notNull(),
  },
  (table) => ({ emailIdx: index("email_idx").on(table.email) }),
);

export const posts = pgTable("posts", {
  id: serial("id").primaryKey(),
  userId: integer("user_id")
    .notNull()
    .references(() => users.id, { onDelete: "cascade" }),
});

export const usersRelations = relations(users, ({ many }) => ({
  posts: many(posts),
}));
export const postsRelations = relations(posts, ({ one }) => ({
  author: one(users, { fields: [posts.userId], references: [users.id] }),
}));
```

See [references/drizzle-schema.md](references/drizzle-schema.md) for column types, constraints, relationships.

### Queries

```typescript
import { eq, gt } from "drizzle-orm";

// Basic CRUD
const users = await db.select().from(users).where(eq(users.isActive, true));
const newUser = await db
  .insert(users)
  .values({ username: "john", email: "john@example.com" })
  .returning();
const updated = await db
  .update(users)
  .set({ isActive: false })
  .where(eq(users.id, 1))
  .returning();
await db.delete(users).where(eq(users.id, 1));

// Relational queries (recommended)
import * as schema from "./schema";
const db = drizzle(client, { schema });

const usersWithPosts = await db.query.users.findMany({ with: { posts: true } });
const user = await db.query.users.findFirst({
  where: eq(schema.users.id, 1),
  with: { posts: { where: eq(schema.posts.isPublished, true), limit: 10 } },
});

// Transactions
await db.transaction(async (tx) => {
  const user = await tx
    .insert(users)
    .values({ username: "john", email: "john@example.com" })
    .returning();
  await tx.insert(posts).values({ title: "First Post", userId: user[0].id });
});
```

See [references/drizzle-patterns.md](references/drizzle-patterns.md) for joins, aggregations, pagination.

### Migrations

```bash
# 1. Modify schema.ts
# 2. Generate and review
bun drizzle-kit generate
cat drizzle/0001_migration_name.sql

# 3. Apply
bun drizzle-kit migrate

# 4. Commit
git add src/db/schema.ts drizzle/
git commit -m "Add posts table"
```

**Programmatic:**

```typescript
import { drizzle } from "drizzle-orm/postgres-js";
import { migrate } from "drizzle-orm/postgres-js/migrator";
import postgres from "postgres";

const client = postgres(process.env.DATABASE_URL!, { max: 1 });
await migrate(drizzle(client), { migrationsFolder: "./drizzle" });
await client.end();
```

See [references/drizzle-commands.md](references/drizzle-commands.md) for workflows and troubleshooting.

## Performance

### Indexing

```typescript
export const users = pgTable(
  "users",
  {
    id: serial("id").primaryKey(),
    email: varchar("email", { length: 255 }).notNull(),
    status: varchar("status", { length: 20 }).notNull(),
    createdAt: timestamp("created_at").defaultNow().notNull(),
  },
  (table) => ({
    statusIdx: index("status_idx").on(table.status),
    compositeIdx: index("status_created_idx").on(table.status, table.createdAt),
    partialIdx: index("active_users_idx")
      .on(table.status)
      .where(sql`${table.status} = 'active'`),
  }),
);
```

**Index when:** WHERE clauses, JOIN conditions, ORDER BY, foreign keys.

### Query Optimization

```typescript
// ❌ Bad: Select all, N+1 queries, OFFSET pagination
const users = await db.select().from(users);
for (const user of users) {
  const posts = await db.select().from(posts).where(eq(posts.userId, user.id));
}
const page = await db.select().from(users).limit(20).offset(1000);

// ✅ Good: Select specific, relational queries, cursor pagination
const usernames = await db
  .select({ id: users.id, name: users.username })
  .from(users);
const usersWithPosts = await db.query.users.findMany({ with: { posts: true } });
const nextPage = await db
  .select()
  .from(users)
  .where(gt(users.id, lastId))
  .limit(20)
  .orderBy(users.id);

// ✅ Batch operations
await db.insert(users).values(usersData); // Not: for loop with individual inserts

// Analyze performance
await db.execute(
  sql`EXPLAIN ANALYZE SELECT * FROM users WHERE email = 'john@example.com'`,
);
```

See [references/optimization-patterns.md](references/optimization-patterns.md) for detailed strategies.

## Bun Integration

```typescript
import { SQL } from "bun";
import { drizzle } from "drizzle-orm/postgres-js";
import * as schema from "./schema";

const bunSql = new SQL(process.env.DATABASE_URL!);
const db = drizzle(bunSql as any, { schema });

// Type-safe operations
const user = await db.query.users.findFirst({
  where: eq(schema.users.email, "john@example.com"),
});

// Raw performance
const users = await bunSql`SELECT * FROM users WHERE id = ${userId}`;
const stats = await bunSql`SELECT COUNT(*) as total FROM users`;

// Transactions
await bunSql.begin(async (tx) => {
  await tx`INSERT INTO users (name) VALUES (${"Charlie"})`;
  await tx`UPDATE accounts SET balance = balance - 100`;
});
```

**Use Bun.sql for:** Connection pooling control, PostgreSQL-specific features, performance-critical queries, LISTEN/NOTIFY.

## Type Safety

```typescript
import { InferSelectModel, InferInsertModel } from "drizzle-orm";

export const users = pgTable("users", {
  id: serial("id").primaryKey(),
  username: varchar("username", { length: 50 }).notNull(),
  email: text("email").notNull(),
});

export type User = InferSelectModel<typeof users>; // { id: number; username: string; email: string }
export type NewUser = InferInsertModel<typeof users>; // { username: string; email: string }

// Custom type annotations
export const posts = pgTable("posts", {
  id: serial("id").primaryKey(),
  status: varchar("status", { length: 20 })
    .$type<"draft" | "published">()
    .default("draft"),
  metadata: jsonb("metadata").$type<{ tags: string[]; featured: boolean }>(),
});
```

## Best Practices

### Security

```typescript
// ✅ Safe: Parameterized queries
const user = await db.select().from(users).where(eq(users.email, userInput));

// ❌ NEVER: String concatenation (SQL injection)
const unsafe = await db.execute(
  sql.raw(`SELECT * FROM users WHERE email = '${userInput}'`),
);
```

### Schema Design

**Data types:** `TIMESTAMPTZ` (timezone-aware), `JSONB` (not `JSON`), `VARCHAR` with limits, `TEXT` for unbounded.

**Constraints:**

```typescript
import { check } from "drizzle-orm/pg-core";

export const users = pgTable(
  "users",
  {
    id: serial("id").primaryKey(),
    age: integer("age").notNull(),
  },
  (table) => ({
    ageCheck: check(
      "age_check",
      sql`${table.age} >= 0 AND ${table.age} <= 150`,
    ),
  }),
);
```

### Common Pitfalls

```typescript
// ❌ Bad: No .returning(), no transactions, no error handling
await db.update(users).set({ isActive: false }).where(eq(users.id, 1));
await db.insert(users).values(userData);
await db.insert(accounts).values(accountData);

// ✅ Good: .returning(), transactions, error handling
const updated = await db
  .update(users)
  .set({ isActive: false })
  .where(eq(users.id, 1))
  .returning();

await db.transaction(async (tx) => {
  const user = await tx.insert(users).values(userData).returning();
  await tx.insert(accounts).values({ ...accountData, userId: user[0].id });
});

try {
  await db.insert(users).values({ email: "duplicate@example.com" });
} catch (error) {
  if (error.code === "23505") console.error("Email already exists");
  throw error;
}
```

## Resources

**Reference Documentation:**

- [drizzle-patterns.md](references/drizzle-patterns.md) - Query patterns, joins, transactions, pagination
- [drizzle-commands.md](references/drizzle-commands.md) - CLI commands, migration workflows
- [drizzle-schema.md](references/drizzle-schema.md) - Schema definitions, column types, relationships
- [optimization-patterns.md](references/optimization-patterns.md) - PostgreSQL optimization, indexing
- [schema-patterns.md](references/schema-patterns.md) - Common schema patterns, migrations
- [drizzle-recipes.md](references/drizzle-recipes.md) - Advanced patterns, custom types

**External:**

- [Drizzle ORM Documentation](https://orm.drizzle.team/)
- [PostgreSQL Documentation](https://www.postgresql.org/docs/)
- [Bun SQL API](https://bun.sh/docs/api/sql)
