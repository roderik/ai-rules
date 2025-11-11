# Drizzle Schema Definitions & Types

## Table Definition Syntax

### Basic Table Structure

```typescript
import { pgTable, serial, text, varchar, timestamp } from "drizzle-orm/pg-core";

export const users = pgTable("users", {
  id: serial("id").primaryKey(),
  username: varchar("username", { length: 50 }).notNull(),
  email: text("email").notNull(),
  createdAt: timestamp("created_at").defaultNow().notNull(),
});
```

### Table with Indexes and Constraints

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
  check,
} from "drizzle-orm/pg-core";
import { sql } from "drizzle-orm";

export const users = pgTable(
  "users",
  {
    id: serial("id").primaryKey(),
    username: varchar("username", { length: 50 }).notNull().unique(),
    email: varchar("email", { length: 255 }).notNull().unique(),
    passwordHash: text("password_hash").notNull(),
    age: integer("age"),
    isActive: boolean("is_active").default(true).notNull(),
    createdAt: timestamp("created_at").defaultNow().notNull(),
    updatedAt: timestamp("updated_at").defaultNow().notNull(),
  },
  (table) => ({
    // Indexes defined as return value
    emailIdx: uniqueIndex("email_idx").on(table.email),
    usernameIdx: index("username_idx").on(table.username),
    statusIdx: index("status_idx").on(table.isActive),

    // Composite index
    statusCreatedIdx: index("status_created_idx").on(
      table.isActive,
      table.createdAt,
    ),

    // Partial index (conditional)
    activeUsersIdx: index("active_users_idx")
      .on(table.isActive)
      .where(sql`${table.isActive} = true`),

    // Check constraints
    ageCheck: check(
      "age_check",
      sql`${table.age} >= 0 AND ${table.age} <= 150`,
    ),
  }),
);
```

## PostgreSQL Column Types

### Numeric Types

```typescript
import {
  smallint,
  integer,
  bigint,
  serial,
  smallserial,
  bigserial,
  numeric,
  decimal,
  real,
  doublePrecision,
} from "drizzle-orm/pg-core";

export const products = pgTable("products", {
  // Integers
  id: serial("id").primaryKey(), // Auto-increment 1 to 2,147,483,647
  smallQty: smallint("small_qty"), // -32,768 to 32,767
  quantity: integer("quantity"), // -2,147,483,648 to 2,147,483,647
  bigNumber: bigint("big_number", { mode: "number" }), // Large integers
  bigNumberString: bigint("big_number_str", { mode: "bigint" }), // As string

  // Auto-increment variants
  autoSmall: smallserial("auto_small"), // Auto-increment smallint
  autoRegular: serial("auto_regular"), // Auto-increment integer
  autoBig: bigserial("auto_big"), // Auto-increment bigint

  // Decimal types
  price: numeric("price", { precision: 10, scale: 2 }), // NUMERIC(10,2) - exact
  decimalPrice: decimal("decimal_price", { precision: 10, scale: 2 }), // Same as numeric

  // Floating point (approximate)
  floatVal: real("float_val"), // 4 bytes, 6 decimal precision
  doubleVal: doublePrecision("double_val"), // 8 bytes, 15 decimal precision
});
```

### String Types

```typescript
import { char, varchar, text } from "drizzle-orm/pg-core";

export const content = pgTable("content", {
  id: serial("id").primaryKey(),

  // Fixed-length (padded with spaces)
  code: char("code", { length: 10 }), // CHAR(10)

  // Variable-length with limit
  username: varchar("username", { length: 50 }), // VARCHAR(50)
  email: varchar("email", { length: 255 }), // VARCHAR(255)

  // Unlimited length
  description: text("description"), // TEXT
  body: text("body"), // TEXT

  // Enum-like with varchar
  status: varchar("status", { length: 20 }).$type<"active" | "inactive">(),
});
```

### Date & Time Types

```typescript
import { date, time, timestamp, interval } from "drizzle-orm/pg-core";

export const events = pgTable("events", {
  id: serial("id").primaryKey(),

  // Date only (no time)
  birthDate: date("birth_date"), // DATE

  // Time only (no date)
  startTime: time("start_time"), // TIME

  // Timestamp without timezone
  createdAt: timestamp("created_at").defaultNow(), // TIMESTAMP

  // Timestamp with timezone (recommended)
  updatedAt: timestamp("updated_at", { withTimezone: true }).defaultNow(), // TIMESTAMPTZ

  // Timestamp with precision
  preciseTime: timestamp("precise_time", { precision: 6 }), // 6 decimal places

  // Interval (duration)
  duration: interval("duration"), // INTERVAL

  // Unix timestamp (stored as integer)
  unixTime: integer("unix_time"), // Use with mode: 'timestamp'
});
```

### Boolean Type

```typescript
import { boolean } from "drizzle-orm/pg-core";

export const settings = pgTable("settings", {
  id: serial("id").primaryKey(),
  isActive: boolean("is_active").default(true).notNull(),
  isVerified: boolean("is_verified").default(false),
  acceptsMarketing: boolean("accepts_marketing"),
});
```

### UUID Type

```typescript
import { uuid } from "drizzle-orm/pg-core";

export const sessions = pgTable("sessions", {
  // UUID with auto-generation
  id: uuid("id").defaultRandom().primaryKey(),

  // UUID without default
  userId: uuid("user_id").notNull(),

  // UUID as string
  token:
    uuid("token").$type<`${string}-${string}-${string}-${string}-${string}`>(),
});
```

### JSON Types

```typescript
import { json, jsonb } from "drizzle-orm/pg-core";

type UserSettings = {
  theme: "light" | "dark";
  notifications: boolean;
  language: string;
};

type PostMetadata = {
  tags: string[];
  views: number;
  featured: boolean;
};

export const users = pgTable("users", {
  id: serial("id").primaryKey(),

  // JSON (stored as text, slower queries)
  preferences: json("preferences").$type<UserSettings>(),

  // JSONB (binary format, faster queries, supports indexing)
  settings: jsonb("settings").$type<UserSettings>().notNull(),
  metadata: jsonb("metadata").$type<PostMetadata>().default({
    tags: [],
    views: 0,
    featured: false,
  }),
});
```

### Array Types

```typescript
import { integer, text } from "drizzle-orm/pg-core";

export const posts = pgTable("posts", {
  id: serial("id").primaryKey(),

  // Array of text
  tags: text("tags").array(),

  // Array of integers
  categoryIds: integer("category_ids").array(),

  // Multi-dimensional arrays
  matrix: integer("matrix").array().array(),
});

// Usage
const post = await db.insert(posts).values({
  tags: ["typescript", "drizzle", "postgres"],
  categoryIds: [1, 2, 3],
  matrix: [
    [1, 2, 3],
    [4, 5, 6],
  ],
});
```

### Enum Types

```typescript
import { pgEnum } from "drizzle-orm/pg-core";

// Define enum
export const roleEnum = pgEnum("role", ["user", "admin", "moderator"]);
export const statusEnum = pgEnum("status", [
  "pending",
  "active",
  "suspended",
  "deleted",
]);

// Use in table
export const users = pgTable("users", {
  id: serial("id").primaryKey(),
  role: roleEnum("role").default("user").notNull(),
  status: statusEnum("status").default("pending").notNull(),
});
```

### Binary Types

```typescript
import { bytea } from "drizzle-orm/pg-core";

export const files = pgTable("files", {
  id: serial("id").primaryKey(),
  name: text("name").notNull(),
  data: bytea("data"), // Binary data (BYTEA)
});

// Usage with Buffer
const file = await db.insert(files).values({
  name: "image.png",
  data: Buffer.from("binary data"),
});
```

## Column Modifiers

### NOT NULL Constraint

```typescript
export const users = pgTable("users", {
  id: serial("id").primaryKey(),
  username: text("username").notNull(), // Required field
  bio: text("bio"), // Optional field (nullable)
});
```

### DEFAULT Values

```typescript
export const posts = pgTable("posts", {
  id: serial("id").primaryKey(),

  // Static defaults
  status: varchar("status", { length: 20 }).default("draft"),
  isPublished: boolean("is_published").default(false),
  viewCount: integer("view_count").default(0),

  // Dynamic defaults
  createdAt: timestamp("created_at").defaultNow(),
  updatedAt: timestamp("updated_at").defaultNow(),

  // SQL function defaults
  slug: varchar("slug", { length: 255 }).default(sql`gen_random_uuid()`),
});
```

### UNIQUE Constraint

```typescript
export const users = pgTable("users", {
  id: serial("id").primaryKey(),
  email: text("email").notNull().unique(), // Single column unique
  username: text("username").notNull().unique(),
});

// Composite unique constraint
export const userProfiles = pgTable(
  "user_profiles",
  {
    userId: integer("user_id").notNull(),
    platform: varchar("platform", { length: 50 }).notNull(),
    profileUrl: text("profile_url"),
  },
  (table) => ({
    // Unique combination of userId + platform
    uniqueUserPlatform: unique("unique_user_platform").on(
      table.userId,
      table.platform,
    ),
  }),
);
```

### PRIMARY KEY

```typescript
export const products = pgTable("products", {
  // Single column primary key
  id: serial("id").primaryKey(),
  name: text("name").notNull(),
});

// Composite primary key
export const orderItems = pgTable(
  "order_items",
  {
    orderId: integer("order_id").notNull(),
    productId: integer("product_id").notNull(),
    quantity: integer("quantity").notNull(),
  },
  (table) => ({
    pk: primaryKey({ columns: [table.orderId, table.productId] }),
  }),
);
```

## Relationships

### Foreign Keys

```typescript
export const users = pgTable("users", {
  id: serial("id").primaryKey(),
  name: text("name").notNull(),
});

export const posts = pgTable("posts", {
  id: serial("id").primaryKey(),
  title: text("title").notNull(),
  userId: integer("user_id")
    .notNull()
    .references(() => users.id), // Foreign key
});

// Foreign key with cascade options
export const comments = pgTable("comments", {
  id: serial("id").primaryKey(),
  content: text("content").notNull(),
  postId: integer("post_id")
    .notNull()
    .references(() => posts.id, { onDelete: "cascade" }), // Delete comments when post deleted
});

// Foreign key options
export const likes = pgTable("likes", {
  id: serial("id").primaryKey(),
  userId: integer("user_id")
    .notNull()
    .references(() => users.id, {
      onDelete: "cascade", // CASCADE | SET NULL | SET DEFAULT | RESTRICT | NO ACTION
      onUpdate: "cascade",
    }),
});
```

### Defining Relations

```typescript
import { relations } from "drizzle-orm";

// Users table
export const users = pgTable("users", {
  id: serial("id").primaryKey(),
  name: text("name").notNull(),
});

// Posts table
export const posts = pgTable("posts", {
  id: serial("id").primaryKey(),
  title: text("title").notNull(),
  userId: integer("user_id")
    .notNull()
    .references(() => users.id),
});

// Define relations
export const usersRelations = relations(users, ({ many }) => ({
  posts: many(posts), // One user has many posts
}));

export const postsRelations = relations(posts, ({ one }) => ({
  author: one(users, {
    fields: [posts.userId],
    references: [users.id],
  }), // One post has one author
}));
```

### One-to-Many Relationships

```typescript
import { relations } from "drizzle-orm";

export const categories = pgTable("categories", {
  id: serial("id").primaryKey(),
  name: text("name").notNull(),
});

export const products = pgTable("products", {
  id: serial("id").primaryKey(),
  name: text("name").notNull(),
  categoryId: integer("category_id")
    .notNull()
    .references(() => categories.id),
});

// Relations
export const categoriesRelations = relations(categories, ({ many }) => ({
  products: many(products),
}));

export const productsRelations = relations(products, ({ one }) => ({
  category: one(categories, {
    fields: [products.categoryId],
    references: [categories.id],
  }),
}));
```

### Many-to-Many Relationships

```typescript
import { relations } from "drizzle-orm";

// Main tables
export const students = pgTable("students", {
  id: serial("id").primaryKey(),
  name: text("name").notNull(),
});

export const courses = pgTable("courses", {
  id: serial("id").primaryKey(),
  title: text("title").notNull(),
});

// Junction table
export const studentsToClasses = pgTable(
  "students_to_classes",
  {
    studentId: integer("student_id")
      .notNull()
      .references(() => students.id),
    courseId: integer("course_id")
      .notNull()
      .references(() => courses.id),
    enrolledAt: timestamp("enrolled_at").defaultNow().notNull(),
  },
  (table) => ({
    pk: primaryKey({ columns: [table.studentId, table.courseId] }),
  }),
);

// Relations
export const studentsRelations = relations(students, ({ many }) => ({
  enrollments: many(studentsToClasses),
}));

export const coursesRelations = relations(courses, ({ many }) => ({
  enrollments: many(studentsToClasses),
}));

export const studentsToClassesRelations = relations(
  studentsToClasses,
  ({ one }) => ({
    student: one(students, {
      fields: [studentsToClasses.studentId],
      references: [students.id],
    }),
    course: one(courses, {
      fields: [studentsToClasses.courseId],
      references: [courses.id],
    }),
  }),
);
```

### Self-Referencing Relationships

```typescript
export const employees = pgTable("employees", {
  id: serial("id").primaryKey(),
  name: text("name").notNull(),
  managerId: integer("manager_id").references((): any => employees.id), // Self-reference
});

export const employeesRelations = relations(employees, ({ one, many }) => ({
  manager: one(employees, {
    fields: [employees.managerId],
    references: [employees.id],
  }),
  subordinates: many(employees),
}));
```

## Type Inference

### Inferring Types from Schema

```typescript
import { InferSelectModel, InferInsertModel } from "drizzle-orm";

export const users = pgTable("users", {
  id: serial("id").primaryKey(),
  username: varchar("username", { length: 50 }).notNull(),
  email: text("email").notNull(),
  age: integer("age"),
  createdAt: timestamp("created_at").defaultNow().notNull(),
});

// Infer select type (what you get from queries)
export type User = InferSelectModel<typeof users>;
// { id: number; username: string; email: string; age: number | null; createdAt: Date }

// Infer insert type (what you provide for inserts)
export type NewUser = InferInsertModel<typeof users>;
// { username: string; email: string; age?: number; createdAt?: Date }
```

### Custom Type Annotations

```typescript
export const posts = pgTable("posts", {
  id: serial("id").primaryKey(),
  title: text("title").notNull(),

  // Narrow type to specific values
  status: varchar("status", { length: 20 })
    .$type<"draft" | "published" | "archived">()
    .default("draft"),

  // JSON with typed structure
  metadata: jsonb("metadata").$type<{
    tags: string[];
    featured: boolean;
  }>(),
});
```

## Schema Organization

### Single File Schema

```typescript
// src/db/schema.ts
import { pgTable, serial, text, timestamp, integer } from "drizzle-orm/pg-core";
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

### Multi-File Schema

```typescript
// src/db/schema/users.ts
export const users = pgTable("users", {
  id: serial("id").primaryKey(),
  name: text("name").notNull(),
});

// src/db/schema/posts.ts
export const posts = pgTable("posts", {
  id: serial("id").primaryKey(),
  userId: integer("user_id").notNull(),
});

// src/db/schema/relations.ts
export const usersRelations = relations(users, ({ many }) => ({
  posts: many(posts),
}));

// src/db/schema/index.ts
export * from "./users";
export * from "./posts";
export * from "./relations";
```

### Module-Based Schema

```typescript
// src/db/schema/users/users.table.ts
export const users = pgTable("users", {
  id: serial("id").primaryKey(),
  name: text("name").notNull(),
});

// src/db/schema/users/users.relations.ts
export const usersRelations = relations(users, ({ many }) => ({
  posts: many(posts),
}));

// src/db/schema/users/index.ts
export * from "./users.table";
export * from "./users.relations";

// src/db/schema/index.ts
export * from "./users";
export * from "./posts";
```

## Best Practices

### Schema Design

**DO:**

- Use `TIMESTAMPTZ` for timestamps (timezone-aware)
- Use `JSONB` over `JSON` (faster, indexable)
- Use `VARCHAR` with reasonable limits for bounded strings
- Use `TEXT` for unbounded strings
- Define relations even without DB-level foreign keys
- Use enums for fixed sets of values
- Add indexes on frequently queried columns

**DON'T:**

- Use `JSON` type (use `JSONB` instead)
- Use `VARCHAR` without length limits
- Store large binary data in database (use object storage)
- Over-index (slows writes, increases storage)
- Use `CHAR` unless you need fixed-length padding

### Type Safety

```typescript
// ✅ Good: Strongly typed
export const posts = pgTable("posts", {
  id: serial("id").primaryKey(),
  status: varchar("status", { length: 20 }).$type<"draft" | "published">(),
  metadata: jsonb("metadata").$type<{ views: number; likes: number }>(),
});

// ❌ Bad: No type safety
export const posts = pgTable("posts", {
  id: serial("id").primaryKey(),
  status: varchar("status", { length: 20 }),
  metadata: jsonb("metadata"),
});
```

### Naming Conventions

**Tables:** Plural, snake_case

```typescript
export const userProfiles = pgTable("user_profiles", { ... });
```

**Columns:** snake_case in database, camelCase in TypeScript

```typescript
export const users = pgTable("users", {
  firstName: text("first_name"),
  createdAt: timestamp("created_at"),
});
```

**Enums:** Singular, lowercase

```typescript
export const roleEnum = pgEnum("role", ["user", "admin"]);
```
