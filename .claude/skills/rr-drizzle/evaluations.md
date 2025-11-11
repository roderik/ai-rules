# Evaluation Scenarios for rr-drizzle

## Scenario 1: Basic Usage - Create User Schema with Drizzle

**Input:** "Create a Drizzle schema for a users table with id, email, username, password hash, and timestamps"

**Expected Behavior:**

- Automatically activate when "Drizzle schema" is mentioned
- Generate schema using pgTable from drizzle-orm/pg-core
- Include proper column types (serial, varchar, text, timestamp)
- Add constraints (primaryKey, notNull, unique)
- Include indexes for email and username
- Add defaultNow() for timestamps
- Follow naming conventions (snake_case for DB, camelCase for TS)

**Success Criteria:**

- [ ] Uses pgTable from drizzle-orm/pg-core
- [ ] id: serial('id').primaryKey()
- [ ] email: varchar with length, notNull, unique
- [ ] username: varchar with length, notNull, unique
- [ ] passwordHash: text, notNull
- [ ] createdAt and updatedAt: timestamp with defaultNow()
- [ ] Indexes defined in return value (email and username)
- [ ] Follows schema pattern from SKILL.md
- [ ] Proper TypeScript types inferred

## Scenario 2: Complex Scenario - Posts with Relations and N+1 Prevention

**Input:** "Create a blog system with users and posts. Each post has an author (user) and can have multiple comments. Write a query to get all posts with their authors and comment counts, avoiding N+1 queries. Include proper indexes for performance."

**Expected Behavior:**

- Load skill and understand relational schema requirement
- Create three schemas: users, posts, comments
- Define relations using Drizzle relations API
- Set up foreign keys properly
- Add indexes on foreign key columns
- Write efficient query using:
  - Relational query API OR
  - Manual join with groupBy for comment counts
- Explain N+1 problem and how solution avoids it
- Reference `references/optimization-patterns.md`
- Include indexes for userId in posts and comments

**Success Criteria:**

- [ ] Three tables created: users, posts, comments
- [ ] Foreign keys: posts.userId → users.id, comments.postId → posts.id
- [ ] Relations defined with relations() for all three tables
- [ ] Indexes on posts.userId and comments.postId
- [ ] Query uses efficient approach (single query, not N+1)
- [ ] Uses relational query API with "with" OR manual join with groupBy
- [ ] Returns posts with author data and comment count
- [ ] Explains why this avoids N+1 problem
- [ ] References optimization-patterns.md for query optimization
- [ ] Proper TypeScript types throughout

## Scenario 3: Error Handling - Unique Constraint Violation

**Input:** "My insert query is failing with error code 23505. The user is trying to register with an email that already exists."

**Expected Behavior:**

- Recognize 23505 as PostgreSQL unique constraint violation
- Identify this is from unique email constraint
- Show proper error handling with try/catch
- Check for error.code === '23505'
- Provide user-friendly error message
- Suggest checking if email exists before insert (alternative approach)
- Reference common pitfalls section from SKILL.md
- Show both reactive (catch) and proactive (check first) approaches

**Success Criteria:**

- [ ] Identifies 23505 as unique constraint violation
- [ ] Recognizes email uniqueness is the issue
- [ ] Provides try/catch wrapper around insert
- [ ] Checks error.code === '23505' specifically
- [ ] Returns user-friendly error message
- [ ] Shows alternative: query for existing email first
- [ ] Explains trade-offs between approaches
- [ ] References common pitfalls section from SKILL.md
- [ ] Maintains security (doesn't leak internal errors)
