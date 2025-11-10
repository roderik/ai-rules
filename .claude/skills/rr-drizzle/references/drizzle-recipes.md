# Drizzle Recipes

Advanced Drizzle ORM patterns, custom types, helper functions, and real-world solutions.

## Type-Safe Query Builders

### Reusable Query Filters

```typescript
import { SQL, and, eq, gt, isNull } from "drizzle-orm";
import { users } from "./schema";

// Create reusable filter builders
const filters = {
  isActive: () => eq(users.isActive, true),
  notDeleted: () => isNull(users.deletedAt),
  createdAfter: (date: Date) => gt(users.createdAt, date),
  byStatus: (status: string) => eq(users.status, status),
};

// Combine filters dynamically
function buildUserQuery(conditions: SQL[]) {
  return db
    .select()
    .from(users)
    .where(and(...conditions));
}

// Usage
const activeUsers = await buildUserQuery([
  filters.isActive(),
  filters.notDeleted(),
]);

const recentActiveUsers = await buildUserQuery([
  filters.isActive(),
  filters.createdAfter(new Date("2024-01-01")),
]);
```

### Dynamic Query Builder

```typescript
interface UserFilters {
  status?: string;
  search?: string;
  createdAfter?: Date;
  limit?: number;
  offset?: number;
}

async function queryUsers(filters: UserFilters) {
  let query = db.select().from(users);

  const conditions: SQL[] = [];

  if (filters.status) {
    conditions.push(eq(users.status, filters.status));
  }

  if (filters.search) {
    conditions.push(like(users.username, `%${filters.search}%`));
  }

  if (filters.createdAfter) {
    conditions.push(gt(users.createdAt, filters.createdAfter));
  }

  if (conditions.length > 0) {
    query = query.where(and(...conditions));
  }

  if (filters.limit) {
    query = query.limit(filters.limit);
  }

  if (filters.offset) {
    query = query.offset(filters.offset);
  }

  return query;
}

// Usage
const results = await queryUsers({
  status: "active",
  search: "john",
  limit: 20,
});
```

## Custom Column Types

### Email Type with Validation

```typescript
import { customType } from "drizzle-orm/pg-core";

const email = customType<{ data: string }>({
  dataType() {
    return "varchar(255)";
  },
  toDriver(value: string): string {
    // Validate email format
    const emailRegex = /^[^\s@]+@[^\s@]+\.[^\s@]+$/;
    if (!emailRegex.test(value)) {
      throw new Error(`Invalid email format: ${value}`);
    }
    return value.toLowerCase(); // Normalize to lowercase
  },
  fromDriver(value: string): string {
    return value;
  },
});

// Usage in schema
export const users = pgTable("users", {
  id: serial("id").primaryKey(),
  email: email("email").notNull().unique(),
});
```

### Money Type (with cents precision)

```typescript
const money = customType<{ data: number; driverData: string }>({
  dataType() {
    return "numeric(10, 2)";
  },
  toDriver(value: number): string {
    // Store as cents (e.g., 19.99 -> "1999")
    return (value / 100).toFixed(2);
  },
  fromDriver(value: string): number {
    // Return as cents (e.g., "19.99" -> 1999)
    return Math.round(parseFloat(value) * 100);
  },
});

export const products = pgTable("products", {
  id: serial("id").primaryKey(),
  price: money("price").notNull(),
});

// Usage
await db.insert(products).values({
  price: 1999, // $19.99 in cents
});

const product = await db.select().from(products).where(eq(products.id, 1));
console.log(product[0].price); // 1999 (cents)
console.log(product[0].price / 100); // 19.99 (dollars)
```

### Encrypted String Type

```typescript
import crypto from "crypto";

const ENCRYPTION_KEY = process.env.ENCRYPTION_KEY!; // 32 bytes
const ALGORITHM = "aes-256-gcm";

const encryptedString = customType<{ data: string }>({
  dataType() {
    return "text";
  },
  toDriver(value: string): string {
    const iv = crypto.randomBytes(16);
    const cipher = crypto.createCipheriv(
      ALGORITHM,
      Buffer.from(ENCRYPTION_KEY, "hex"),
      iv,
    );

    let encrypted = cipher.update(value, "utf8", "hex");
    encrypted += cipher.final("hex");

    const authTag = cipher.getAuthTag();

    // Store: iv:authTag:encrypted
    return `${iv.toString("hex")}:${authTag.toString("hex")}:${encrypted}`;
  },
  fromDriver(value: string): string {
    const [ivHex, authTagHex, encrypted] = value.split(":");

    const iv = Buffer.from(ivHex, "hex");
    const authTag = Buffer.from(authTagHex, "hex");

    const decipher = crypto.createDecipheriv(
      ALGORITHM,
      Buffer.from(ENCRYPTION_KEY, "hex"),
      iv,
    );
    decipher.setAuthTag(authTag);

    let decrypted = decipher.update(encrypted, "hex", "utf8");
    decrypted += decipher.final("utf8");

    return decrypted;
  },
});

export const users = pgTable("users", {
  id: serial("id").primaryKey(),
  ssn: encryptedString("ssn"), // Sensitive data
});
```

## Helper Functions

### Base Repository Pattern

```typescript
import { PgTable, SQL } from "drizzle-orm/pg-core";
import { PostgresJsDatabase } from "drizzle-orm/postgres-js";

class BaseRepository<T extends PgTable> {
  constructor(
    protected db: PostgresJsDatabase,
    protected table: T,
  ) {}

  async findAll() {
    return this.db.select().from(this.table);
  }

  async findById(id: number) {
    const results = await this.db
      .select()
      .from(this.table)
      .where(eq(this.table.id, id))
      .limit(1);

    return results[0] ?? null;
  }

  async create(data: InferInsertModel<T>) {
    const results = await this.db.insert(this.table).values(data).returning();

    return results[0];
  }

  async update(id: number, data: Partial<InferInsertModel<T>>) {
    const results = await this.db
      .update(this.table)
      .set(data)
      .where(eq(this.table.id, id))
      .returning();

    return results[0] ?? null;
  }

  async delete(id: number) {
    await this.db.delete(this.table).where(eq(this.table.id, id));
  }
}

// Usage
const userRepo = new BaseRepository(db, users);

const user = await userRepo.findById(1);
const newUser = await userRepo.create({
  username: "john",
  email: "john@example.com",
});
```

### Paginated Query Helper

```typescript
interface PaginationOptions {
  page: number;
  perPage: number;
}

interface PaginatedResult<T> {
  data: T[];
  pagination: {
    page: number;
    perPage: number;
    total: number;
    totalPages: number;
    hasNext: boolean;
    hasPrev: boolean;
  };
}

async function paginate<T>(
  query: ReturnType<typeof db.select>,
  options: PaginationOptions,
): Promise<PaginatedResult<T>> {
  const { page, perPage } = options;
  const offset = (page - 1) * perPage;

  // Get total count
  const [countResult] = await db
    .select({ count: count() })
    .from(query.as("subquery"));

  const total = Number(countResult.count);
  const totalPages = Math.ceil(total / perPage);

  // Get paginated data
  const data = await query.limit(perPage).offset(offset);

  return {
    data: data as T[],
    pagination: {
      page,
      perPage,
      total,
      totalPages,
      hasNext: page < totalPages,
      hasPrev: page > 1,
    },
  };
}

// Usage
const result = await paginate(
  db.select().from(users).where(eq(users.status, "active")),
  { page: 1, perPage: 20 },
);

console.log(result.data); // User[]
console.log(result.pagination); // { page: 1, perPage: 20, total: 150, ... }
```

### Upsert Helper

```typescript
async function upsert<T extends PgTable>(
  table: T,
  uniqueColumn: keyof T["_"]["columns"],
  data: InferInsertModel<T>,
) {
  return db
    .insert(table)
    .values(data)
    .onConflictDoUpdate({
      target: table[uniqueColumn],
      set: data,
    })
    .returning();
}

// Usage
const user = await upsert(users, "email", {
  email: "john@example.com",
  username: "johndoe",
  status: "active",
});
```

### Batch Upsert with Conflict Handling

```typescript
async function batchUpsert<T extends PgTable>(
  table: T,
  uniqueColumns: (keyof T["_"]["columns"])[],
  data: InferInsertModel<T>[],
) {
  if (data.length === 0) return [];

  return db
    .insert(table)
    .values(data)
    .onConflictDoUpdate({
      target: uniqueColumns.map((col) => table[col]),
      set: Object.fromEntries(
        Object.keys(data[0]).map((key) => [
          key,
          sql`excluded.${sql.identifier(key)}`,
        ]),
      ),
    })
    .returning();
}

// Usage
const users = await batchUpsert(
  usersTable,
  ["email"],
  [
    { email: "john@example.com", username: "john" },
    { email: "jane@example.com", username: "jane" },
  ],
);
```

## Advanced Patterns

### Soft Delete with Scopes

```typescript
// Create a scoped query builder
function createSoftDeleteScope<T extends PgTable>(
  table: T,
  deletedAtColumn: string,
) {
  return {
    all: () => db.select().from(table),
    active: () => db.select().from(table).where(isNull(table[deletedAtColumn])),
    deleted: () =>
      db.select().from(table).where(isNotNull(table[deletedAtColumn])),
    withDeleted: () => db.select().from(table),
  };
}

// Usage
const userScope = createSoftDeleteScope(users, "deletedAt");

const activeUsers = await userScope.active();
const deletedUsers = await userScope.deleted();
const allUsers = await userScope.all();
```

### Optimistic Locking

Prevent lost updates with version column:

```typescript
export const posts = pgTable("posts", {
  id: serial("id").primaryKey(),
  title: text("title").notNull(),
  content: text("content").notNull(),
  version: integer("version").default(1).notNull(),
  updatedAt: timestamp("updated_at").defaultNow().notNull(),
});

async function updateWithOptimisticLock(
  id: number,
  currentVersion: number,
  updates: Partial<typeof posts.$inferInsert>,
) {
  const result = await db
    .update(posts)
    .set({
      ...updates,
      version: sql`${posts.version} + 1`,
      updatedAt: new Date(),
    })
    .where(and(eq(posts.id, id), eq(posts.version, currentVersion)))
    .returning();

  if (result.length === 0) {
    throw new Error(
      "Optimistic lock failed: record was modified by another process",
    );
  }

  return result[0];
}

// Usage
const post = await db.query.posts.findFirst({ where: eq(posts.id, 1) });

try {
  await updateWithOptimisticLock(post.id, post.version, {
    title: "Updated Title",
  });
} catch (error) {
  console.error("Concurrent modification detected");
}
```

### Audit Trail Pattern

Track all changes to a table:

```typescript
export const users = pgTable("users", {
  id: serial("id").primaryKey(),
  username: varchar("username", { length: 50 }).notNull(),
  email: varchar("email", { length: 255 }).notNull(),
});

export const userAudit = pgTable("user_audit", {
  id: serial("id").primaryKey(),
  userId: integer("user_id").references(() => users.id),
  action: varchar("action", { length: 10 }).notNull(), // INSERT, UPDATE, DELETE
  oldData: jsonb("old_data"),
  newData: jsonb("new_data"),
  changedBy: integer("changed_by"), // User ID who made the change
  changedAt: timestamp("changed_at").defaultNow().notNull(),
});

// Helper function to create audit log
async function auditChange(
  tx: any,
  userId: number,
  action: "INSERT" | "UPDATE" | "DELETE",
  oldData: any,
  newData: any,
  changedBy: number,
) {
  await tx.insert(userAudit).values({
    userId,
    action,
    oldData,
    newData,
    changedBy,
  });
}

// Usage in transaction
await db.transaction(async (tx) => {
  const oldUser = await tx.query.users.findFirst({
    where: eq(users.id, userId),
  });

  const [updatedUser] = await tx
    .update(users)
    .set({ username: "newname" })
    .where(eq(users.id, userId))
    .returning();

  await auditChange(tx, userId, "UPDATE", oldUser, updatedUser, currentUserId);
});
```

### Full-Text Search

```typescript
import { sql } from "drizzle-orm";

export const posts = pgTable(
  "posts",
  {
    id: serial("id").primaryKey(),
    title: text("title").notNull(),
    content: text("content").notNull(),
    searchVector: text("search_vector"), // tsvector column
  },
  (table) => ({
    searchVectorIdx: index("search_vector_idx")
      .on(table.searchVector)
      .using("gin"),
  }),
);

// Create trigger to auto-update search_vector
await db.execute(sql`
  CREATE OR REPLACE FUNCTION posts_search_vector_update() RETURNS trigger AS $$
  BEGIN
    NEW.search_vector :=
      setweight(to_tsvector('english', COALESCE(NEW.title, '')), 'A') ||
      setweight(to_tsvector('english', COALESCE(NEW.content, '')), 'B');
    RETURN NEW;
  END
  $$ LANGUAGE plpgsql;

  CREATE TRIGGER posts_search_vector_trigger
    BEFORE INSERT OR UPDATE ON posts
    FOR EACH ROW
    EXECUTE FUNCTION posts_search_vector_update();
`);

// Search function
async function searchPosts(query: string) {
  return db
    .select()
    .from(posts)
    .where(sql`${posts.searchVector} @@ plainto_tsquery('english', ${query})`)
    .orderBy(
      sql`ts_rank(${posts.searchVector}, plainto_tsquery('english', ${query})) DESC`,
    );
}

// Usage
const results = await searchPosts("postgresql database");
```

### Rate Limiting with Database

```typescript
export const rateLimits = pgTable(
  "rate_limits",
  {
    id: serial("id").primaryKey(),
    key: varchar("key", { length: 255 }).notNull().unique(),
    count: integer("count").default(0).notNull(),
    resetAt: timestamp("reset_at").notNull(),
  },
  (table) => ({
    keyIdx: uniqueIndex("key_idx").on(table.key),
    resetAtIdx: index("reset_at_idx").on(table.resetAt),
  }),
);

async function checkRateLimit(
  key: string,
  limit: number,
  windowSeconds: number,
): Promise<{ allowed: boolean; remaining: number }> {
  const now = new Date();
  const resetAt = new Date(now.getTime() + windowSeconds * 1000);

  return db.transaction(async (tx) => {
    // Try to increment counter
    const result = await tx
      .insert(rateLimits)
      .values({ key, count: 1, resetAt })
      .onConflictDoUpdate({
        target: rateLimits.key,
        set: {
          count: sql`CASE
            WHEN ${rateLimits.resetAt} < ${now}
            THEN 1
            ELSE ${rateLimits.count} + 1
            END`,
          resetAt: sql`CASE
            WHEN ${rateLimits.resetAt} < ${now}
            THEN ${resetAt}
            ELSE ${rateLimits.resetAt}
            END`,
        },
      })
      .returning();

    const current = result[0];
    const allowed = current.count <= limit;
    const remaining = Math.max(0, limit - current.count);

    return { allowed, remaining };
  });
}

// Usage
const rateLimit = await checkRateLimit("user:123:api", 100, 60);
if (!rateLimit.allowed) {
  throw new Error("Rate limit exceeded");
}
```

### Database-Based Queue

```typescript
export const jobStatusEnum = pgEnum("job_status", [
  "pending",
  "processing",
  "completed",
  "failed",
]);

export const jobs = pgTable(
  "jobs",
  {
    id: serial("id").primaryKey(),
    type: varchar("type", { length: 50 }).notNull(),
    payload: jsonb("payload").notNull(),
    status: jobStatusEnum("status").default("pending").notNull(),
    attempts: integer("attempts").default(0).notNull(),
    maxAttempts: integer("max_attempts").default(3).notNull(),
    error: text("error"),
    processAt: timestamp("process_at").defaultNow().notNull(),
    processedAt: timestamp("processed_at"),
    createdAt: timestamp("created_at").defaultNow().notNull(),
  },
  (table) => ({
    statusProcessAtIdx: index("status_process_at_idx").on(
      table.status,
      table.processAt,
    ),
  }),
);

async function enqueueJob(type: string, payload: any, delaySeconds = 0) {
  const processAt = new Date(Date.now() + delaySeconds * 1000);

  return db
    .insert(jobs)
    .values({
      type,
      payload,
      processAt,
    })
    .returning();
}

async function processNextJob() {
  return db.transaction(async (tx) => {
    // Lock and fetch next job
    const [job] = await tx
      .select()
      .from(jobs)
      .where(
        and(
          eq(jobs.status, "pending"),
          sql`${jobs.processAt} <= NOW()`,
          sql`${jobs.attempts} < ${jobs.maxAttempts}`,
        ),
      )
      .orderBy(jobs.processAt)
      .limit(1)
      .for("update", { skipLocked: true });

    if (!job) return null;

    // Mark as processing
    await tx
      .update(jobs)
      .set({
        status: "processing",
        attempts: job.attempts + 1,
      })
      .where(eq(jobs.id, job.id));

    return job;
  });
}

async function completeJob(jobId: number, success: boolean, error?: string) {
  await db
    .update(jobs)
    .set({
      status: success ? "completed" : "failed",
      processedAt: new Date(),
      error,
    })
    .where(eq(jobs.id, jobId));
}

// Worker
async function worker() {
  while (true) {
    const job = await processNextJob();

    if (!job) {
      await new Promise((resolve) => setTimeout(resolve, 1000));
      continue;
    }

    try {
      // Process job
      console.log(`Processing job ${job.id}: ${job.type}`);
      await processJob(job);
      await completeJob(job.id, true);
    } catch (error) {
      await completeJob(job.id, false, error.message);
    }
  }
}
```

## Testing Helpers

### Test Database Setup

```typescript
import { drizzle } from "drizzle-orm/postgres-js";
import postgres from "postgres";
import { migrate } from "drizzle-orm/postgres-js/migrator";

export async function setupTestDatabase() {
  const testDbUrl = process.env.TEST_DATABASE_URL!;
  const client = postgres(testDbUrl, { max: 1 });
  const db = drizzle(client);

  // Run migrations
  await migrate(db, { migrationsFolder: "./drizzle" });

  return { db, client };
}

export async function teardownTestDatabase(client: any) {
  await client.end();
}

export async function cleanDatabase(db: any) {
  // Truncate all tables
  await db.execute(sql`
    TRUNCATE TABLE users, posts, comments CASCADE
  `);
}
```

### Factory Pattern for Test Data

```typescript
import { faker } from "@faker-js/faker";

export const userFactory = {
  build: (overrides?: Partial<typeof users.$inferInsert>) => ({
    username: faker.internet.userName(),
    email: faker.internet.email(),
    createdAt: new Date(),
    ...overrides,
  }),

  create: async (overrides?: Partial<typeof users.$inferInsert>) => {
    const [user] = await db
      .insert(users)
      .values(userFactory.build(overrides))
      .returning();
    return user;
  },

  createMany: async (
    count: number,
    overrides?: Partial<typeof users.$inferInsert>,
  ) => {
    const data = Array.from({ length: count }, () =>
      userFactory.build(overrides),
    );
    return db.insert(users).values(data).returning();
  },
};

// Usage in tests
const user = await userFactory.create({ username: "testuser" });
const users = await userFactory.createMany(10);
```

Refer to this document for advanced patterns, custom types, and helper functions to enhance Drizzle ORM development.
