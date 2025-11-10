# Drizzle Schema Patterns

Common schema patterns, relationship examples, and migration strategies for Drizzle ORM.

## Schema Organization

### Directory Structure

```
src/
  db/
    schema/
      users.ts         # User-related tables
      posts.ts         # Post-related tables
      comments.ts      # Comment-related tables
      index.ts         # Re-export all schemas
    index.ts           # Database client and exports
```

**Recommended pattern for medium/large projects:**

```typescript
// src/db/schema/users.ts
import { pgTable, serial, varchar, timestamp } from "drizzle-orm/pg-core";

export const users = pgTable("users", {
  id: serial("id").primaryKey(),
  username: varchar("username", { length: 50 }).notNull().unique(),
  email: varchar("email", { length: 255 }).notNull().unique(),
  createdAt: timestamp("created_at").defaultNow().notNull(),
});

// src/db/schema/index.ts
export * from "./users";
export * from "./posts";
export * from "./comments";

// src/db/index.ts
import { drizzle } from "drizzle-orm/postgres-js";
import postgres from "postgres";
import * as schema from "./schema";

const client = postgres(process.env.DATABASE_URL!);
export const db = drizzle(client, { schema });
```

## Common Patterns

### 1. Timestamps Pattern

Add created/updated timestamps to all tables:

```typescript
import { pgTable, serial, timestamp } from "drizzle-orm/pg-core";

// Helper for timestamp columns
export const timestamps = {
  createdAt: timestamp("created_at").defaultNow().notNull(),
  updatedAt: timestamp("updated_at").defaultNow().notNull(),
};

// Usage
export const users = pgTable("users", {
  id: serial("id").primaryKey(),
  username: varchar("username", { length: 50 }).notNull(),
  ...timestamps,
});

export const posts = pgTable("posts", {
  id: serial("id").primaryKey(),
  title: text("title").notNull(),
  ...timestamps,
});
```

**With automatic update trigger:**

```sql
-- Create function to update updated_at
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
  NEW.updated_at = NOW();
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Apply to tables
CREATE TRIGGER update_users_updated_at
  BEFORE UPDATE ON users
  FOR EACH ROW
  EXECUTE FUNCTION update_updated_at();
```

### 2. Soft Delete Pattern

Keep deleted records with a `deleted_at` column:

```typescript
export const users = pgTable(
  "users",
  {
    id: serial("id").primaryKey(),
    username: varchar("username", { length: 50 }).notNull(),
    email: varchar("email", { length: 255 }).notNull(),
    deletedAt: timestamp("deleted_at"), // NULL = not deleted
    createdAt: timestamp("created_at").defaultNow().notNull(),
    updatedAt: timestamp("updated_at").defaultNow().notNull(),
  },
  (table) => ({
    // Index for soft delete queries
    deletedAtIdx: index("deleted_at_idx").on(table.deletedAt),
  }),
);

// Query only active users
const activeUsers = await db
  .select()
  .from(users)
  .where(isNull(users.deletedAt));

// Soft delete
await db
  .update(users)
  .set({ deletedAt: new Date() })
  .where(eq(users.id, userId));

// Restore
await db.update(users).set({ deletedAt: null }).where(eq(users.id, userId));
```

### 3. UUID Primary Keys

Use UUID instead of auto-increment integers:

```typescript
import { pgTable, uuid, varchar, timestamp } from "drizzle-orm/pg-core";

export const users = pgTable("users", {
  id: uuid("id").defaultRandom().primaryKey(),
  username: varchar("username", { length: 50 }).notNull(),
  createdAt: timestamp("created_at").defaultNow().notNull(),
});

// With custom UUID generation
import { v7 as uuidv7 } from "uuid";

const newUser = await db
  .insert(users)
  .values({
    id: uuidv7(), // Time-ordered UUID
    username: "johndoe",
  })
  .returning();
```

**Benefits of UUID:**

- Globally unique across databases
- No sequence conflicts in distributed systems
- Harder to enumerate/guess IDs

**Drawbacks:**

- Larger storage (16 bytes vs 4 bytes)
- Random UUIDs fragment indexes (use UUIDv7 for time-ordered)

### 4. Enum Pattern

Use PostgreSQL enums for fixed sets of values:

```typescript
import { pgEnum, pgTable, serial, varchar } from "drizzle-orm/pg-core";

// Define enum
export const userStatusEnum = pgEnum("user_status", [
  "active",
  "inactive",
  "pending",
]);
export const userRoleEnum = pgEnum("user_role", ["admin", "user", "moderator"]);

export const users = pgTable("users", {
  id: serial("id").primaryKey(),
  username: varchar("username", { length: 50 }).notNull(),
  status: userStatusEnum("status").default("pending").notNull(),
  role: userRoleEnum("role").default("user").notNull(),
});

// Query by enum
const activeUsers = await db
  .select()
  .from(users)
  .where(eq(users.status, "active"));

// Type-safe enum values
type UserStatus = (typeof users.status.enumValues)[number]; // 'active' | 'inactive' | 'pending'
```

**Alternative: String literal union types (no DB enum):**

```typescript
export const users = pgTable("users", {
  id: serial("id").primaryKey(),
  status: varchar("status", { length: 20 })
    .$type<"active" | "inactive" | "pending">()
    .default("pending")
    .notNull(),
});
```

### 5. JSON/JSONB Columns

Store flexible, queryable JSON data:

```typescript
import { pgTable, serial, jsonb } from "drizzle-orm/pg-core";

export const users = pgTable(
  "users",
  {
    id: serial("id").primaryKey(),
    username: varchar("username", { length: 50 }).notNull(),
    // Type-safe JSONB
    profile: jsonb("profile").$type<{
      bio?: string;
      avatar?: string;
      socialLinks?: { platform: string; url: string }[];
    }>(),
    // Generic JSONB
    metadata: jsonb("metadata"),
  },
  (table) => ({
    // GIN index for JSONB queries
    profileIdx: index("profile_gin_idx").on(table.profile).using("gin"),
  }),
);

// Insert with JSON
await db.insert(users).values({
  username: "johndoe",
  profile: {
    bio: "Software engineer",
    avatar: "https://example.com/avatar.jpg",
    socialLinks: [{ platform: "twitter", url: "https://twitter.com/johndoe" }],
  },
});

// Query JSONB with raw SQL
import { sql } from "drizzle-orm";

const usersWithTwitter = await db
  .select()
  .from(users)
  .where(sql`${users.profile} @> '{"socialLinks": [{"platform": "twitter"}]}'`);
```

### 6. Array Columns

Store arrays of values:

```typescript
import { pgTable, serial, text } from "drizzle-orm/pg-core";

export const posts = pgTable(
  "posts",
  {
    id: serial("id").primaryKey(),
    title: text("title").notNull(),
    tags: text("tags").array(),
  },
  (table) => ({
    // GIN index for array queries
    tagsIdx: index("tags_gin_idx").on(table.tags).using("gin"),
  }),
);

// Insert with array
await db.insert(posts).values({
  title: "My Post",
  tags: ["typescript", "postgresql", "drizzle"],
});

// Query arrays
import { sql } from "drizzle-orm";

// Check if array contains value
const typescriptPosts = await db
  .select()
  .from(posts)
  .where(sql`'typescript' = ANY(${posts.tags})`);

// Check if array overlaps
const techPosts = await db
  .select()
  .from(posts)
  .where(sql`${posts.tags} && ARRAY['typescript', 'javascript']`);
```

## Relationship Patterns

### One-to-Many

User has many posts:

```typescript
import { pgTable, serial, text, integer } from "drizzle-orm/pg-core";
import { relations } from "drizzle-orm";

export const users = pgTable("users", {
  id: serial("id").primaryKey(),
  username: varchar("username", { length: 50 }).notNull(),
});

export const posts = pgTable("posts", {
  id: serial("id").primaryKey(),
  title: text("title").notNull(),
  userId: integer("user_id")
    .notNull()
    .references(() => users.id, { onDelete: "cascade" }),
});

// Define relations
export const usersRelations = relations(users, ({ many }) => ({
  posts: many(posts),
}));

export const postsRelations = relations(posts, ({ one }) => ({
  author: one(users, {
    fields: [posts.userId],
    references: [users.id],
  }),
}));

// Query with relations
const usersWithPosts = await db.query.users.findMany({
  with: {
    posts: true,
  },
});

// Query with filters
const activeUsersWithRecentPosts = await db.query.users.findMany({
  where: eq(users.status, "active"),
  with: {
    posts: {
      where: gt(posts.createdAt, new Date("2024-01-01")),
      limit: 5,
    },
  },
});
```

### Many-to-Many

Users can like many posts, posts can be liked by many users:

```typescript
// Junction table
export const postsToUsers = pgTable(
  "posts_to_users",
  {
    userId: integer("user_id")
      .notNull()
      .references(() => users.id, { onDelete: "cascade" }),
    postId: integer("post_id")
      .notNull()
      .references(() => posts.id, { onDelete: "cascade" }),
    likedAt: timestamp("liked_at").defaultNow().notNull(),
  },
  (table) => ({
    // Composite primary key
    pk: primaryKey({ columns: [table.userId, table.postId] }),
    // Indexes for reverse queries
    userIdIdx: index("user_id_idx").on(table.userId),
    postIdIdx: index("post_id_idx").on(table.postId),
  }),
);

// Define relations
export const usersRelations = relations(users, ({ many }) => ({
  likedPosts: many(postsToUsers),
}));

export const postsRelations = relations(posts, ({ many }) => ({
  likedBy: many(postsToUsers),
}));

export const postsToUsersRelations = relations(postsToUsers, ({ one }) => ({
  user: one(users, {
    fields: [postsToUsers.userId],
    references: [users.id],
  }),
  post: one(posts, {
    fields: [postsToUsers.postId],
    references: [posts.id],
  }),
}));

// Query with many-to-many
const usersWithLikedPosts = await db.query.users.findMany({
  with: {
    likedPosts: {
      with: {
        post: true,
      },
    },
  },
});
```

### Self-Referencing (Tree Structure)

Comments with nested replies:

```typescript
export const comments = pgTable(
  "comments",
  {
    id: serial("id").primaryKey(),
    content: text("content").notNull(),
    postId: integer("post_id")
      .notNull()
      .references(() => posts.id, { onDelete: "cascade" }),
    parentId: integer("parent_id").references(() => comments.id, {
      onDelete: "cascade",
    }),
    createdAt: timestamp("created_at").defaultNow().notNull(),
  },
  (table) => ({
    parentIdIdx: index("parent_id_idx").on(table.parentId),
  }),
);

// Define relations
export const commentsRelations = relations(comments, ({ one, many }) => ({
  parent: one(comments, {
    fields: [comments.parentId],
    references: [comments.id],
  }),
  replies: many(comments),
  post: one(posts, {
    fields: [comments.postId],
    references: [posts.id],
  }),
}));

// Query with nested comments
const commentsWithReplies = await db.query.comments.findMany({
  where: isNull(comments.parentId), // Only top-level comments
  with: {
    replies: {
      with: {
        replies: true, // Nested replies (2 levels deep)
      },
    },
  },
});
```

### Polymorphic Relations

Attachments can belong to posts or comments:

```typescript
export const attachmentTypeEnum = pgEnum("attachment_type", [
  "post",
  "comment",
]);

export const attachments = pgTable(
  "attachments",
  {
    id: serial("id").primaryKey(),
    filename: varchar("filename", { length: 255 }).notNull(),
    url: text("url").notNull(),
    attachableType: attachmentTypeEnum("attachable_type").notNull(),
    attachableId: integer("attachable_id").notNull(),
  },
  (table) => ({
    // Composite index for polymorphic queries
    attachableIdx: index("attachable_idx").on(
      table.attachableType,
      table.attachableId,
    ),
  }),
);

// Query polymorphic relation
const postAttachments = await db
  .select()
  .from(attachments)
  .where(
    and(
      eq(attachments.attachableType, "post"),
      eq(attachments.attachableId, postId),
    ),
  );
```

## Migration Strategies

### 1. Additive Migrations (Safe)

Add new columns/tables without breaking existing code:

```typescript
// Step 1: Add new column as nullable
export const users = pgTable("users", {
  id: serial("id").primaryKey(),
  username: varchar("username", { length: 50 }).notNull(),
  email: varchar("email", { length: 255 }), // New column, nullable
});

// Generate migration
// $ bun drizzle-kit generate

// Step 2: Backfill data (optional)
await db.update(users).set({ email: sql`username || '@example.com'` });

// Step 3: Make column NOT NULL (in next migration)
export const users = pgTable("users", {
  id: serial("id").primaryKey(),
  username: varchar("username", { length: 50 }).notNull(),
  email: varchar("email", { length: 255 }).notNull(), // Now required
});
```

### 2. Column Rename

Rename without downtime:

```typescript
// Step 1: Add new column
export const users = pgTable("users", {
  id: serial("id").primaryKey(),
  username: varchar("username", { length: 50 }).notNull(),
  fullName: varchar("full_name", { length: 100 }), // New
});

// Step 2: Backfill from old column
await db.execute(sql`UPDATE users SET full_name = name`);

// Step 3: Update application to use fullName

// Step 4: Drop old column (in next migration)
// Remove 'name' from schema
```

### 3. Data Type Change

Change column type safely:

```typescript
// Example: Change price from INTEGER to DECIMAL

// Step 1: Add new column with desired type
export const products = pgTable("products", {
  id: serial("id").primaryKey(),
  price: integer("price").notNull(), // Old
  priceDecimal: numeric("price_decimal", { precision: 10, scale: 2 }), // New
});

// Step 2: Backfill
await db.execute(sql`UPDATE products SET price_decimal = price / 100.0`);

// Step 3: Update code to use priceDecimal

// Step 4: Drop old column and rename (in next migration)
export const products = pgTable("products", {
  id: serial("id").primaryKey(),
  price: numeric("price", { precision: 10, scale: 2 }).notNull(),
});
```

### 4. Index Addition (No Downtime)

Add indexes without blocking writes:

```sql
-- In migration SQL, use CONCURRENTLY
CREATE INDEX CONCURRENTLY email_idx ON users(email);
```

### 5. Schema Versioning

Track schema version in database:

```typescript
export const schemaVersion = pgTable("schema_version", {
  id: serial("id").primaryKey(),
  version: integer("version").notNull(),
  appliedAt: timestamp("applied_at").defaultNow().notNull(),
});

// After applying migration
await db.insert(schemaVersion).values({ version: 5 });
```

## Advanced Patterns

### 1. Composite Primary Keys

```typescript
export const userSettings = pgTable(
  "user_settings",
  {
    userId: integer("user_id")
      .notNull()
      .references(() => users.id),
    settingKey: varchar("setting_key", { length: 50 }).notNull(),
    settingValue: text("setting_value"),
  },
  (table) => ({
    pk: primaryKey({ columns: [table.userId, table.settingKey] }),
  }),
);
```

### 2. Check Constraints

```typescript
import { check } from "drizzle-orm/pg-core";

export const products = pgTable(
  "products",
  {
    id: serial("id").primaryKey(),
    name: text("name").notNull(),
    price: numeric("price", { precision: 10, scale: 2 }).notNull(),
    stock: integer("stock").notNull(),
  },
  (table) => ({
    priceCheck: check("price_check", sql`${table.price} >= 0`),
    stockCheck: check("stock_check", sql`${table.stock} >= 0`),
  }),
);
```

### 3. Partial Unique Index

Ensure uniqueness only for non-deleted records:

```typescript
export const users = pgTable(
  "users",
  {
    id: serial("id").primaryKey(),
    email: varchar("email", { length: 255 }).notNull(),
    deletedAt: timestamp("deleted_at"),
  },
  (table) => ({
    // Unique email only for active users
    activeEmailIdx: uniqueIndex("active_email_idx")
      .on(table.email)
      .where(sql`${table.deletedAt} IS NULL`),
  }),
);
```

### 4. Generated Columns

Automatically computed columns:

```typescript
export const orders = pgTable("orders", {
  id: serial("id").primaryKey(),
  subtotal: numeric("subtotal", { precision: 10, scale: 2 }).notNull(),
  tax: numeric("tax", { precision: 10, scale: 2 }).notNull(),
  // Computed column
  total: numeric("total", { precision: 10, scale: 2 }).generatedAlwaysAs(
    sql`subtotal + tax`,
  ),
});
```

### 5. Row-Level Security (RLS)

```sql
-- Enable RLS on table
ALTER TABLE posts ENABLE ROW LEVEL SECURITY;

-- Policy: Users can only see their own posts
CREATE POLICY user_posts_policy ON posts
  FOR SELECT
  USING (user_id = current_setting('app.current_user_id')::integer);

-- Set user context
SELECT set_config('app.current_user_id', '123', false);
```

Refer to this document for common schema patterns, relationship structures, and safe migration strategies.
