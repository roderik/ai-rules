# oRPC Server Implementation

## Handlers

Handlers process incoming requests and execute procedures. oRPC provides two primary handler types:

### RPCHandler

Processes RPC protocol requests with full support for native JavaScript types.

**Features:**
- Automatic serialization/deserialization of Date, Map, Set, URL
- File and Blob support
- Type-safe request/response handling
- Efficient binary protocol

**Basic usage:**
```typescript
import { RPCHandler } from '@orpc/server'

const handler = new RPCHandler({
  router: appRouter,
  context: initialContext,
})

// Use with any framework adapter
app.post('/rpc', handler.handle)
```

### OpenAPIHandler

Converts procedures to REST/OpenAPI endpoints with automatic OpenAPI specification generation.

**Features:**
- Automatic OpenAPI 3.0 spec generation
- REST endpoint creation from procedures
- Support for bracket notation in URLs/forms for structured data
- Standard HTTP method mapping (GET, POST, PUT, DELETE)

**Basic usage:**
```typescript
import { OpenAPIHandler } from '@orpc/server'

const handler = new OpenAPIHandler({
  router: appRouter,
  context: initialContext,
})

// Access generated OpenAPI spec
const spec = handler.spec

// Use with framework
app.use('/api', handler.handle)
```

**Bracket notation example:**
For complex objects in URLs/forms:
```typescript
// Input schema: { user: { name: string, age: number } }
// URL: /api/user?user[name]=John&user[age]=30
```

## Middleware

Chain handlers before/after procedure execution for cross-cutting concerns.

**Types:**

### Input Middleware
Executes before input validation, can modify or validate context:
```typescript
const authMiddleware = proc.use(async ({ context, next }) => {
  const user = await validateToken(context.token)
  return next({ user }) // adds user to context
})
```

### Typed Middleware
Executes after input validation, has access to validated input:
```typescript
const logMiddleware = proc.use(async ({ input, context, next }) => {
  console.log('Calling with:', input)
  const result = await next()
  console.log('Result:', result)
  return result
})
```

### Dedupe Pattern
Prevent redundant executions for identical requests:
```typescript
const dedupeMiddleware = proc.use(async ({ input, context, next }) => {
  const key = JSON.stringify(input)
  if (cache.has(key)) return cache.get(key)

  const result = await next()
  cache.set(key, result)
  return result
})
```

## Plugins

Extend functionality through interceptors. Common use cases:

### CORS Plugin
```typescript
import { corsPlugin } from '@orpc/server'

const handler = new RPCHandler({
  router: appRouter,
  plugins: [
    corsPlugin({
      origin: 'https://example.com',
      credentials: true,
    })
  ]
})
```

### Compression Plugin
```typescript
import { compressionPlugin } from '@orpc/server'

const handler = new RPCHandler({
  router: appRouter,
  plugins: [compressionPlugin()]
})
```

### Body Limit Plugin
```typescript
import { bodyLimitPlugin } from '@orpc/server'

const handler = new RPCHandler({
  router: appRouter,
  plugins: [bodyLimitPlugin({ limit: '10mb' })]
})
```

### Batch Request Plugin
Optimize multiple requests:
```typescript
import { batchPlugin } from '@orpc/server'

const handler = new RPCHandler({
  router: appRouter,
  plugins: [batchPlugin()]
})
```

### Retry Plugin
Automatic retry with exponential backoff:
```typescript
import { retryPlugin } from '@orpc/server'

const handler = new RPCHandler({
  router: appRouter,
  plugins: [
    retryPlugin({
      maxRetries: 3,
      backoff: 'exponential',
    })
  ]
})
```

### Request Deduplication Plugin
Prevent duplicate requests from executing:
```typescript
import { dedupePlugin } from '@orpc/server'

const handler = new RPCHandler({
  router: appRouter,
  plugins: [dedupePlugin()]
})
```

## Custom Plugin Development

Create custom plugins by implementing the plugin interface:
```typescript
const customPlugin = {
  name: 'custom-plugin',
  onRequest: async ({ request, next }) => {
    // Pre-processing
    const response = await next()
    // Post-processing
    return response
  }
}
```

## Error Handling

Define typed errors for procedures:
```typescript
const proc = proc
  .input(schema)
  .output(schema)
  .errors({
    NOT_FOUND: z.object({ message: z.string() }),
    UNAUTHORIZED: z.object({ reason: z.string() }),
  })
  .handler(async ({ input }) => {
    if (!input.id) {
      throw { type: 'NOT_FOUND', message: 'ID required' }
    }
    // ...
  })
```
