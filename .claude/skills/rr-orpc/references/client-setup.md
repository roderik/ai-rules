# oRPC Client Usage

## Client Creation

Create type-safe clients to call remote procedures as local functions.

### RPCLink (RPC Protocol)

Use RPCLink for the native RPC protocol with full type support:

```typescript
import { createClient } from '@orpc/client'
import { RPCLink } from '@orpc/client'
import type { AppRouter } from './server'

const client = createClient<AppRouter>({
  links: [
    new RPCLink({
      url: 'http://localhost:3000/rpc',
    })
  ]
})

// Call procedures with full type safety
const result = await client.user.get({ id: '123' })
//    ^? { name: string, email: string }
```

### OpenAPILink (REST Protocol)

Use OpenAPILink for REST/HTTP endpoints:

```typescript
import { createClient } from '@orpc/client'
import { OpenAPILink } from '@orpc/client'
import type { AppRouter } from './server'

const client = createClient<AppRouter>({
  links: [
    new OpenAPILink({
      url: 'http://localhost:3000/api',
    })
  ]
})

// Same API, different protocol
const result = await client.user.get({ id: '123' })
```

## Type Inference Utilities

Extract types from client definitions for use throughout your application.

### Infer Input Type
```typescript
import type { InferInput } from '@orpc/client'

type GetUserInput = InferInput<typeof client.user.get>
//   ^? { id: string }
```

### Infer Output Type
```typescript
import type { InferOutput } from '@orpc/client'

type GetUserOutput = InferOutput<typeof client.user.get>
//   ^? { name: string, email: string }
```

### Infer Error Types
```typescript
import type { InferErrors } from '@orpc/client'

type GetUserErrors = InferErrors<typeof client.user.get>
//   ^? { NOT_FOUND: { message: string } } | { UNAUTHORIZED: { reason: string } }
```

### Infer Context Type
```typescript
import type { InferContext } from '@orpc/client'

type AppContext = InferContext<typeof client>
//   ^? { db: Database, user?: User }
```

## Advanced Client Configuration

### Custom Headers
```typescript
const client = createClient<AppRouter>({
  links: [
    new RPCLink({
      url: 'http://localhost:3000/rpc',
      headers: {
        'Authorization': 'Bearer token',
      }
    })
  ]
})
```

### Multiple Links (Chain)
```typescript
const client = createClient<AppRouter>({
  links: [
    loggerLink(), // runs first
    authLink(),   // runs second
    new RPCLink({ url: '/rpc' }) // final link
  ]
})
```

### Custom Fetch
```typescript
const client = createClient<AppRouter>({
  links: [
    new RPCLink({
      url: 'http://localhost:3000/rpc',
      fetch: customFetch, // use custom fetch implementation
    })
  ]
})
```

## Error Handling

Handle typed errors from procedures:

```typescript
try {
  const user = await client.user.get({ id: '123' })
} catch (error) {
  if (error.type === 'NOT_FOUND') {
    console.log(error.message)
    //                ^? string
  } else if (error.type === 'UNAUTHORIZED') {
    console.log(error.reason)
    //                ^? string
  }
}
```

## Streaming Responses

Handle streaming procedures on the client:

```typescript
const stream = await client.chat.stream({ message: 'Hello' })

for await (const chunk of stream) {
  console.log(chunk) // Type-safe chunks
}
```

## File Upload/Download

### Upload Files
```typescript
const file = new File(['content'], 'file.txt')

const result = await client.upload.file({
  file,
  metadata: { description: 'My file' }
})
```

### Download Files
```typescript
const result = await client.download.file({ id: '123' })
//    ^? { file: File, metadata: { ... } }

// Access the File object
const blob = result.file
```

## Client-Side Validation

Input validation happens automatically on the client before sending requests:

```typescript
// This will fail validation before sending to server
await client.user.get({ id: 123 }) // Error: Expected string, got number
```
