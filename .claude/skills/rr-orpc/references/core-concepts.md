# oRPC Core Concepts

## Procedures

Procedures are the basic unit of work in oRPC. Each procedure accepts typed inputs and produces typed outputs with optional error definitions.

**Key characteristics:**
- Type-safe input/output validation against defined schemas
- Automatic schema validation at runtime
- Support for error handling with typed errors
- Can include streaming responses

**Basic structure:**
```typescript
import { z } from 'zod'

const procedure = proc
  .input(z.object({ name: z.string() }))
  .output(z.object({ greeting: z.string() }))
  .handler(async ({ input }) => {
    return { greeting: `Hello, ${input.name}!` }
  })
```

## Routers

Routers organize procedures into hierarchical structures, enabling modular API organization.

**Features:**
- Nested routing patterns
- Lazy loading support
- Hierarchical organization
- Type-safe procedure grouping

**Example:**
```typescript
const userRouter = router({
  get: getUserProcedure,
  create: createUserProcedure,
  update: updateUserProcedure,
})

const appRouter = router({
  user: userRouter,
  post: postRouter,
})
```

## Context System

The context system provides dependency injection throughout the RPC lifecycle. There are two types of context:

### Initial Context
Explicitly provided context available to all procedures. Use for:
- Database connections
- Authentication state
- Configuration
- Shared utilities

### Execution Context
Generated during procedure execution via middleware. Use for:
- Request-specific data
- User sessions
- Request metadata
- Dynamic dependencies

**Example:**
```typescript
const proc = oc.proc
  .use(authMiddleware) // adds user to context
  .input(z.object({ id: z.string() }))
  .handler(async ({ input, context }) => {
    // context.user available here from middleware
    return await context.db.getUser(input.id)
  })
```

## Contracts

Contracts enable contract-first development where API specifications are defined before implementation.

**Two approaches:**

### 1. Traditional Approach (Implementation-First)
Define procedures directly, types inferred automatically:
```typescript
const proc = proc
  .input(schema)
  .output(schema)
  .handler(implementation)
```

### 2. Contract-First Approach
Define contract separately, implement later:
```typescript
// Define contract
const userContract = contract.router({
  getUser: {
    method: 'GET',
    path: '/users/:id',
    input: z.object({ id: z.string() }),
    output: z.object({ name: z.string() }),
  }
})

// Implement later
const userRouter = server.router(userContract, {
  getUser: async ({ input }) => {
    return await db.getUser(input.id)
  }
})
```

**Benefits:**
- Shared type definitions across teams
- Frontend and backend can work in parallel
- Clear API specifications before implementation
- Type safety maintained across contract boundaries

## Type Safety Features

oRPC provides comprehensive type safety:

- **Native Type Support:** Date, Map, Set, URL automatically serialized/deserialized
- **File Support:** File and Blob objects with proper typing
- **Error Types:** Typed error definitions with proper inference
- **Streaming Types:** Type-safe event iterators for streaming data
- **Inference Utilities:** Extract input/output/error types from any procedure
