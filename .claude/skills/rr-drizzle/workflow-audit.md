# Workflow Audit for rr-drizzle

## ✓ Passed

- Development workflow section exists (Migration Workflow, line 336)
- Clear sequential steps in Migration Workflow (5 steps)
- Good conditional guidance throughout:
  - "When to Use Bun.sql Directly" (line 485)
  - Performance optimization strategies with clear conditions
  - Security best practices with do/don't examples
- Strong feedback loops in optimization section:
  - Query analysis with EXPLAIN
  - Index usage monitoring
  - N+1 query detection and resolution
- Excellent error handling examples (unique constraint violations, etc.)
- Good use of comparison examples (❌ Bad vs ✅ Good)

## ✗ Missing/Needs Improvement

- No comprehensive "Development Workflow" section at the top level
- Quick Start section lacks workflow structure
- Migration Workflow exists but is isolated (not part of broader workflow)
- No testing workflow included
- No deployment/production readiness checklist
- No schema design workflow with validation steps
- Missing pre-migration backup procedures
- No rollback instructions for failed migrations
- Performance optimization presented as reference, not workflow
- No database connection troubleshooting workflow

## Recommendations

1. **Add comprehensive Development Workflow section after Quick Start**:

   ```markdown
   ## Development Workflow

   ### 1. Plan Database Schema

   **Before writing schema code:**

   - [ ] Identify entities and their relationships
   - [ ] Define primary keys and foreign keys
   - [ ] Plan indexes for frequently queried columns
   - [ ] Determine which fields need constraints
   - [ ] Choose appropriate data types (JSONB vs JSON, TIMESTAMP vs TIMESTAMPTZ)
   - [ ] Document business rules and validations

   ### 2. Define Schema

   **Schema definition checklist:**

   - [ ] Create schema file in `src/db/schema.ts`
   - [ ] Use `pgTable` for PostgreSQL-specific features
   - [ ] Define columns with appropriate types
   - [ ] Add `.notNull()` constraints where required
   - [ ] Add `.unique()` constraints for unique fields
   - [ ] Define indexes in table callback function
   - [ ] Add relationships using `relations()` helper
   - [ ] Export all tables and relations

   ### 3. Generate and Apply Migrations

   **Migration workflow:**

   - [ ] Review schema changes before generating migration
   - [ ] Run `bun drizzle-kit generate` to create migration
   - [ ] Review generated SQL in `drizzle/` directory
   - [ ] Verify migration creates correct tables/columns
   - [ ] Check for dangerous operations (drops, breaking changes)
   - [ ] Test migration on local database first
   - [ ] Backup production database before applying
   - [ ] Apply migration: `bun drizzle-kit migrate`
   - [ ] Verify migration applied successfully
   - [ ] Commit both schema and migration files

   ### 4. Implement Queries

   **Query implementation checklist:**

   - [ ] Use TypeScript for full type safety
   - [ ] Select only required columns (avoid `SELECT *`)
   - [ ] Use parameterized queries (never string concatenation)
   - [ ] Implement error handling for constraint violations
   - [ ] Use transactions for related operations
   - [ ] Add appropriate indexes for query patterns
   - [ ] Test queries with realistic data volumes

   ### 5. Optimize Performance

   **Performance optimization workflow:**

   - [ ] Run EXPLAIN ANALYZE on slow queries
   - [ ] Check query execution time targets (<50ms simple queries)
   - [ ] Identify sequential scans that need indexes
   - [ ] Eliminate N+1 queries with joins or relational queries
   - [ ] Use cursor-based pagination for large datasets
   - [ ] Batch insert/update operations
   - [ ] Monitor `pg_stat_user_indexes` for unused indexes

   ### 6. Test Database Operations

   **Testing checklist:**

   - [ ] Write unit tests for query functions
   - [ ] Test constraint violations and error handling
   - [ ] Test transaction rollback scenarios
   - [ ] Test with realistic data volumes
   - [ ] Verify type safety catches errors
   - [ ] Test concurrent operations
   - [ ] Run tests in CI pipeline
   ```

2. **Add Migration Safety Checklist**:

   ```markdown
   ### Migration Safety Checklist

   **Before generating migration:**

   - [ ] Backup local database: `pg_dump > backup.sql`
   - [ ] Review schema changes carefully
   - [ ] Check for breaking changes (column renames, drops)
   - [ ] Plan data migrations if schema changes affect existing data

   **After generating migration:**

   - [ ] Review generated SQL thoroughly
   - [ ] Check for DROP statements (destructive)
   - [ ] Verify column types are correct
   - [ ] Ensure indexes are created efficiently
   - [ ] Test migration on copy of production data

   **Before production deployment:**

   - [ ] Backup production database
   - [ ] Test migration on staging environment
   - [ ] Plan rollback strategy
   - [ ] Schedule deployment during low-traffic window
   - [ ] Monitor database performance after migration
   ```

3. **Add Rollback Procedures**:

   ```markdown
   ### Migration Rollback Procedures

   **If migration fails:**

   - Stop the migration immediately
   - Check error logs: `bun drizzle-kit migrate --verbose`
   - Restore from backup: `psql < backup.sql`
   - Fix schema issues
   - Regenerate migration
   - Test again before reapplying

   **If migration succeeds but causes issues:**

   - Create reverse migration manually
   - Test reverse migration on staging
   - Apply reverse migration: `bun drizzle-kit migrate`
   - Or restore from backup if data corruption occurred
   ```

4. **Add Schema Design Workflow**:

   ```markdown
   ### Schema Design Best Practices

   **Type selection checklist:**

   - [ ] Use `JSONB` for queryable JSON (not `JSON`)
   - [ ] Use `TIMESTAMPTZ` for timezone-aware timestamps
   - [ ] Use `VARCHAR` with length limits for bounded strings
   - [ ] Use `TEXT` for unbounded strings
   - [ ] Use `SERIAL` or `UUID` for primary keys
   - [ ] Use `BOOLEAN` for true/false flags
   - [ ] Use `NUMERIC` for precise decimal values (money)

   **Constraint checklist:**

   - [ ] Add `NOT NULL` constraints for required fields
   - [ ] Add `UNIQUE` constraints for unique fields
   - [ ] Add foreign key constraints for relationships
   - [ ] Add `CHECK` constraints for business rules
   - [ ] Define default values where appropriate
   ```

5. **Add Connection Setup Workflow**:

   ```markdown
   ### Database Connection Setup

   **Setup checklist:**

   - [ ] Install dependencies: `bun add drizzle-orm postgres`
   - [ ] Install dev dependencies: `bun add -D drizzle-kit`
   - [ ] Create `drizzle.config.ts` with correct dialect
   - [ ] Set DATABASE_URL environment variable
   - [ ] Create database connection client
   - [ ] Initialize Drizzle instance
   - [ ] Test connection: `await db.execute(sql\`SELECT 1\`)`
   - [ ] Handle connection errors gracefully
   ```

6. **Add Production Readiness Checklist**:

   ```markdown
   ### Production Deployment Checklist

   - [ ] All migrations tested in staging
   - [ ] Database connection pooling configured
   - [ ] Environment variables properly set
   - [ ] Secrets not committed to git
   - [ ] Indexes created for all frequently queried columns
   - [ ] Query performance verified with production-like data
   - [ ] Error handling implemented for all operations
   - [ ] Monitoring and alerting configured
   - [ ] Backup strategy implemented
   - [ ] Rollback procedures documented
   ```

7. **Add Troubleshooting Workflow**:

   ```markdown
   ### Troubleshooting Workflow

   **Connection fails:**

   - [ ] Verify DATABASE_URL format is correct
   - [ ] Check database is running: `pg_isready`
   - [ ] Test connection with psql: `psql $DATABASE_URL`
   - [ ] Verify network connectivity and firewall rules
   - [ ] Check database credentials are correct

   **Migration fails:**

   - [ ] Review error message carefully
   - [ ] Check for syntax errors in generated SQL
   - [ ] Verify database permissions
   - [ ] Check for conflicts with existing schema
   - [ ] Review migration order and dependencies

   **Query slow:**

   - [ ] Run EXPLAIN ANALYZE on query
   - [ ] Check for sequential scans
   - [ ] Add missing indexes
   - [ ] Optimize WHERE clause
   - [ ] Consider query rewrite or denormalization
   ```

8. **Add conditional error handling throughout**:
   - "If constraint violation occurs, check for duplicate data"
   - "If migration fails, restore from backup before retrying"
   - "If query is slow, run EXPLAIN ANALYZE to identify bottleneck"
   - "If connection fails, verify DATABASE_URL and network access"
