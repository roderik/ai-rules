# Drizzle CLI Commands & Migration Management

## Installation

```bash
# Install Drizzle ORM and PostgreSQL driver
bun add drizzle-orm postgres

# Install Drizzle Kit (development dependency)
bun add -D drizzle-kit
```

## Configuration

### drizzle.config.ts

Basic configuration file for Drizzle Kit:

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

### Advanced Configuration

```typescript
import { defineConfig } from "drizzle-kit";

export default defineConfig({
  dialect: "postgresql",
  schema: "./src/db/schema/*.ts", // Multiple schema files
  out: "./drizzle/migrations",
  dbCredentials: {
    url: process.env.DATABASE_URL!,
    ssl: process.env.NODE_ENV === "production",
  },
  verbose: true, // Log all generated SQL
  strict: true, // Strict mode for migrations
  migrations: {
    prefix: "timestamp", // or "unix"
    table: "__drizzle_migrations", // Custom migration table name
    schema: "public", // Schema to store migration table
  },
});
```

### Multiple Database Configuration

```typescript
import { defineConfig } from "drizzle-kit";

export default defineConfig({
  dialect: "postgresql",
  schema: "./src/db/schema.ts",
  out: "./drizzle",
  dbCredentials: {
    host: process.env.DB_HOST!,
    port: Number(process.env.DB_PORT),
    user: process.env.DB_USER!,
    password: process.env.DB_PASSWORD!,
    database: process.env.DB_NAME!,
  },
});
```

## Core Commands

### Generate Migrations

Generate SQL migration files from schema changes:

```bash
# Generate migration with auto-detected changes
bun drizzle-kit generate

# Generate with custom name
bun drizzle-kit generate --name add_user_roles

# Generate with verbose output
bun drizzle-kit generate --verbose

# Generate from specific config
bun drizzle-kit generate --config drizzle.production.config.ts
```

**What it does:**

- Compares current schema with existing migrations
- Generates SQL files in `out` directory
- Creates timestamped migration files
- Detects schema changes automatically

### Apply Migrations

Apply pending migrations to database:

```bash
# Apply all pending migrations
bun drizzle-kit migrate

# Apply migrations with verbose output
bun drizzle-kit migrate --verbose

# Apply from specific config
bun drizzle-kit migrate --config drizzle.production.config.ts
```

**What it does:**

- Executes pending SQL migration files in order
- Tracks applied migrations in `__drizzle_migrations` table
- Skips already applied migrations
- Fails fast on errors

### Push Schema (Development Only)

Push schema directly to database without generating migrations:

```bash
# Push schema changes directly
bun drizzle-kit push

# Push with warnings
bun drizzle-kit push --verbose

# Force push (dangerous - can lose data)
bun drizzle-kit push --force
```

**When to use:**

- Local development only
- Rapid prototyping
- Testing schema changes

**Never use in production** - migrations provide version control and rollback capability.

### Pull Schema

Generate schema from existing database:

```bash
# Pull schema from database
bun drizzle-kit pull

# Pull with introspection details
bun drizzle-kit pull --verbose

# Pull specific schemas
bun drizzle-kit pull --schema public,auth
```

**What it does:**

- Introspects database structure
- Generates TypeScript schema files
- Creates migration history
- Useful for existing databases

### Studio (Visual Database Management)

Launch Drizzle Studio web interface:

```bash
# Start Drizzle Studio
bun drizzle-kit studio

# Custom port
bun drizzle-kit studio --port 3333

# Custom host
bun drizzle-kit studio --host 0.0.0.0
```

**Features:**

- Browse tables and data
- Run queries
- View relationships
- Edit records
- Default URL: http://localhost:4983

### Check Schema

Validate schema without generating migrations:

```bash
# Check schema for issues
bun drizzle-kit check

# Check with verbose output
bun drizzle-kit check --verbose
```

**What it checks:**

- Schema syntax errors
- Invalid type definitions
- Missing relations
- Circular dependencies

### Drop Migration

Remove a migration file and its entry:

```bash
# Drop last migration
bun drizzle-kit drop

# Drop specific migration
bun drizzle-kit drop --migration 0001_add_users_table

# Drop with confirmation
bun drizzle-kit drop --verbose
```

**Use cases:**

- Undo incorrect migration generation
- Remove unapplied migrations
- Clean up development migrations

## Migration Workflow

### Standard Development Workflow

```bash
# 1. Modify schema.ts
# 2. Generate migration
bun drizzle-kit generate

# 3. Review generated SQL in drizzle/ directory
cat drizzle/0001_migration_name.sql

# 4. Apply migration
bun drizzle-kit migrate

# 5. Commit both schema and migration files
git add src/db/schema.ts drizzle/
git commit -m "Add user roles table"
```

### Production Workflow

```bash
# 1. Pull latest code with migrations
git pull origin main

# 2. Apply migrations in production
NODE_ENV=production bun drizzle-kit migrate --config drizzle.production.config.ts

# 3. Verify migration status
bun drizzle-kit status
```

### Team Workflow

```bash
# Developer A: Create migration
bun drizzle-kit generate
git commit -m "Add posts table"
git push

# Developer B: Pull changes
git pull
bun drizzle-kit migrate # Apply Developer A's migration

# Developer B: Add own changes
bun drizzle-kit generate
git commit -m "Add comments table"
```

## Applying Migrations Programmatically

### Node.js/Bun Runtime

```typescript
import { drizzle } from "drizzle-orm/postgres-js";
import { migrate } from "drizzle-orm/postgres-js/migrator";
import postgres from "postgres";

const runMigrations = async () => {
  // Create dedicated connection for migrations
  const migrationClient = postgres(process.env.DATABASE_URL!, { max: 1 });
  const db = drizzle(migrationClient);

  console.log("Running migrations...");
  await migrate(db, { migrationsFolder: "./drizzle" });
  console.log("Migrations complete");

  await migrationClient.end();
};

runMigrations().catch(console.error);
```

### With Error Handling

```typescript
import { drizzle } from "drizzle-orm/postgres-js";
import { migrate } from "drizzle-orm/postgres-js/migrator";
import postgres from "postgres";

const runMigrations = async () => {
  const migrationClient = postgres(process.env.DATABASE_URL!, {
    max: 1,
    onnotice: () => {}, // Suppress notices during migrations
  });

  try {
    const db = drizzle(migrationClient);
    await migrate(db, {
      migrationsFolder: "./drizzle",
      migrationsTable: "__drizzle_migrations",
    });
    console.log("✓ Migrations completed successfully");
  } catch (error) {
    console.error("✗ Migration failed:", error);
    process.exit(1);
  } finally {
    await migrationClient.end();
  }
};

runMigrations();
```

### Startup Integration

```typescript
import { drizzle } from "drizzle-orm/postgres-js";
import { migrate } from "drizzle-orm/postgres-js/migrator";
import postgres from "postgres";

// Run migrations on app startup
const initDb = async () => {
  // Dedicated migration connection
  const migrationClient = postgres(process.env.DATABASE_URL!, { max: 1 });

  try {
    await migrate(drizzle(migrationClient), {
      migrationsFolder: "./drizzle",
    });
  } finally {
    await migrationClient.end();
  }

  // Return app connection
  const queryClient = postgres(process.env.DATABASE_URL!);
  return drizzle(queryClient);
};

// Use in app
const db = await initDb();
```

## Migration Files

### Understanding Migration File Structure

```sql
-- drizzle/0001_users_table.sql
CREATE TABLE IF NOT EXISTS "users" (
  "id" serial PRIMARY KEY NOT NULL,
  "username" varchar(50) NOT NULL,
  "email" varchar(255) NOT NULL,
  "created_at" timestamp DEFAULT now() NOT NULL,
  CONSTRAINT "users_email_unique" UNIQUE("email")
);

CREATE INDEX IF NOT EXISTS "username_idx" ON "users" ("username");
```

### Migration Metadata

Drizzle tracks migrations in `__drizzle_migrations` table:

| Column     | Description                  |
| ---------- | ---------------------------- |
| id         | Sequential migration ID      |
| hash       | SHA256 hash of migration SQL |
| created_at | Timestamp when applied       |

### Custom Migration SQL

You can manually edit generated migrations or create custom ones:

```sql
-- drizzle/0002_custom_data_migration.sql

-- Generated schema changes
CREATE TABLE "posts" (
  "id" serial PRIMARY KEY,
  "title" text NOT NULL
);

-- Custom data migration
INSERT INTO "posts" ("title")
SELECT DISTINCT "legacy_title"
FROM "legacy_posts"
WHERE "legacy_title" IS NOT NULL;

-- Cleanup
DROP TABLE IF EXISTS "legacy_posts";
```

## Common Migration Patterns

### Adding a Column

```typescript
// schema.ts - Add new column
export const users = pgTable("users", {
  id: serial("id").primaryKey(),
  username: varchar("username", { length: 50 }).notNull(),
  email: varchar("email", { length: 255 }).notNull(),
  bio: text("bio"), // New column
});
```

```bash
bun drizzle-kit generate --name add_user_bio
```

### Renaming a Column

```typescript
// ❌ Don't rename directly (will drop and recreate)
export const users = pgTable("users", {
  id: serial("id").primaryKey(),
  fullName: varchar("full_name", { length: 100 }), // Renamed from 'name'
});
```

**Solution:** Manual migration with RENAME:

```sql
-- After generating, edit the migration file:
ALTER TABLE "users" RENAME COLUMN "name" TO "full_name";
```

### Adding Non-Nullable Column to Existing Table

```typescript
// schema.ts
export const users = pgTable("users", {
  id: serial("id").primaryKey(),
  username: varchar("username", { length: 50 }).notNull(),
  status: varchar("status", { length: 20 }).notNull(), // New required field
});
```

**Generated migration needs a default:**

```sql
-- Edit generated migration to add default for existing rows
ALTER TABLE "users" ADD COLUMN "status" varchar(20) NOT NULL DEFAULT 'active';
```

### Changing Column Type

```typescript
// schema.ts - Change email from varchar to text
export const users = pgTable("users", {
  id: serial("id").primaryKey(),
  email: text("email").notNull(), // Changed from varchar(255)
});
```

```sql
-- Generated migration
ALTER TABLE "users" ALTER COLUMN "email" TYPE text;
```

### Adding Foreign Key to Existing Table

```typescript
// schema.ts
export const posts = pgTable("posts", {
  id: serial("id").primaryKey(),
  title: text("title").notNull(),
  userId: integer("user_id")
    .notNull()
    .references(() => users.id), // Add foreign key
});
```

```bash
bun drizzle-kit generate --name add_posts_user_fk
```

## Troubleshooting

### Migration Conflicts

```bash
# Error: Migration conflict detected
# Solution: Pull latest migrations, resolve conflicts
git pull origin main
bun drizzle-kit generate
```

### Failed Migration

```bash
# Check migration status
bun drizzle-kit status

# Manually rollback (no automatic rollback in Drizzle)
# Connect to database and undo changes
psql $DATABASE_URL -c "DROP TABLE problematic_table;"

# Remove migration entry
psql $DATABASE_URL -c "DELETE FROM __drizzle_migrations WHERE id = <migration_id>;"

# Re-run migrations
bun drizzle-kit migrate
```

### Reset Database (Development)

```bash
# Drop all tables
psql $DATABASE_URL -c "DROP SCHEMA public CASCADE; CREATE SCHEMA public;"

# Recreate from migrations
bun drizzle-kit migrate
```

### Check Migration Status

```bash
# View applied migrations
psql $DATABASE_URL -c "SELECT * FROM __drizzle_migrations ORDER BY id;"

# Compare with migration files
ls drizzle/
```

## Best Practices

### DO:

- Review generated SQL before applying
- Test migrations on staging first
- Keep migrations small and focused
- Commit schema + migration files together
- Use transactions for data migrations
- Add indexes in separate migrations for large tables

### DON'T:

- Edit already-applied migrations
- Use `push` in production
- Skip migration review
- Mix schema and data changes without care
- Delete migration files after applying
- Force push without understanding impact

### Performance Tips:

- Add indexes after data is loaded (faster)
- Use `CONCURRENTLY` for index creation on production
- Batch large data migrations
- Test migration time on production-like data volume
