# oRPC Advanced Features

## Streaming Support

oRPC provides native support for streaming data using event iterators (async generators).

### Server-Sent Events (SSE)

Stream data from server to client:

```typescript
const streamProcedure = proc
  .input(z.object({ query: z.string() }))
  .output(z.object({ chunk: z.string(), index: z.number() }))
  .handler(async function* ({ input }) {
    const results = await search(input.query)

    for (let i = 0; i < results.length; i++) {
      yield { chunk: results[i], index: i }
    }
  })
```

**Client consumption:**
```typescript
const stream = await client.search({ query: 'hello' })

for await (const data of stream) {
  console.log(`Chunk ${data.index}: ${data.chunk}`)
}
```

### Durable Iterator Integration

Automatic reconnection and event recovery for streaming:

```typescript
import { DurableIterator } from '@orpc/durable-iterator'

const durableStream = proc
  .handler(async function* () {
    const iterator = new DurableIterator({
      id: 'unique-stream-id',
      ttl: 60000, // Keep stream alive for 60 seconds
    })

    for await (const event of dataSource) {
      yield iterator.push(event)
    }
  })
```

**Benefits:**
- Automatic reconnection on network failures
- Resume from last received event
- Event deduplication
- Configurable TTL for stream persistence

## File Handling

Type-safe file upload and download support.

### File Upload

```typescript
const uploadProcedure = proc
  .input(z.object({
    file: z.instanceof(File),
    metadata: z.object({
      description: z.string(),
      tags: z.array(z.string()),
    })
  }))
  .output(z.object({
    id: z.string(),
    url: z.string(),
  }))
  .handler(async ({ input }) => {
    const { file, metadata } = input

    // Access File properties
    const buffer = await file.arrayBuffer()
    const filename = file.name
    const mimetype = file.type
    const size = file.size

    // Store file
    const id = await storage.save(buffer, filename)
    const url = await storage.getUrl(id)

    return { id, url }
  })
```

**Client usage:**
```typescript
const fileInput = document.querySelector('input[type="file"]')
const file = fileInput.files[0]

const result = await client.upload({
  file,
  metadata: {
    description: 'Profile picture',
    tags: ['avatar', 'user'],
  }
})
```

### File Download

```typescript
const downloadProcedure = proc
  .input(z.object({ id: z.string() }))
  .output(z.object({
    file: z.instanceof(File),
    metadata: z.object({
      originalName: z.string(),
      uploadedAt: z.date(),
    })
  }))
  .handler(async ({ input }) => {
    const data = await storage.get(input.id)
    const metadata = await storage.getMetadata(input.id)

    const file = new File(
      [data],
      metadata.originalName,
      { type: metadata.mimetype }
    )

    return {
      file,
      metadata: {
        originalName: metadata.originalName,
        uploadedAt: new Date(metadata.uploadedAt),
      }
    }
  })
```

### Blob Support

Similar to File, Blob objects are also supported:

```typescript
const blobProcedure = proc
  .input(z.object({ blob: z.instanceof(Blob) }))
  .handler(async ({ input }) => {
    const buffer = await input.blob.arrayBuffer()
    // Process blob
  })
```

## Native Type Support

oRPC automatically handles serialization/deserialization for JavaScript native types.

### Date Objects

```typescript
const dateProcedure = proc
  .input(z.object({
    startDate: z.date(),
    endDate: z.date(),
  }))
  .output(z.object({
    events: z.array(z.object({
      name: z.string(),
      date: z.date(),
    }))
  }))
  .handler(async ({ input }) => {
    // Dates are actual Date objects, not strings
    const diff = input.endDate.getTime() - input.startDate.getTime()

    return {
      events: [
        { name: 'Event 1', date: new Date('2024-01-01') }
      ]
    }
  })
```

### Map Objects

```typescript
const mapProcedure = proc
  .input(z.object({
    data: z.instanceof(Map<string, number>),
  }))
  .handler(async ({ input }) => {
    // Map is a real Map object
    input.data.forEach((value, key) => {
      console.log(`${key}: ${value}`)
    })
  })
```

### Set Objects

```typescript
const setProcedure = proc
  .input(z.object({
    tags: z.instanceof(Set<string>),
  }))
  .handler(async ({ input }) => {
    // Set is a real Set object
    const hasTag = input.tags.has('important')
  })
```

### URL Objects

```typescript
const urlProcedure = proc
  .input(z.object({
    url: z.instanceof(URL),
  }))
  .handler(async ({ input }) => {
    // URL is a real URL object
    const hostname = input.url.hostname
    const pathname = input.url.pathname
  })
```

## Contract-First Development

Define API contracts before implementation for better team coordination.

### Define Contract

```typescript
import { contract } from '@orpc/contract'

export const apiContract = contract.router({
  user: contract.router({
    get: {
      method: 'GET',
      path: '/users/:id',
      input: z.object({ id: z.string() }),
      output: z.object({
        id: z.string(),
        name: z.string(),
        email: z.string(),
      }),
      errors: {
        NOT_FOUND: z.object({ message: z.string() }),
      }
    },
    list: {
      method: 'GET',
      path: '/users',
      input: z.object({
        page: z.number().optional(),
        limit: z.number().optional(),
      }),
      output: z.object({
        users: z.array(z.object({
          id: z.string(),
          name: z.string(),
        })),
        total: z.number(),
      })
    }
  })
})
```

### Implement Contract

```typescript
import { server } from '@orpc/server'
import { apiContract } from './contract'

const appRouter = server.router(apiContract, {
  user: {
    get: async ({ input }) => {
      const user = await db.getUser(input.id)
      if (!user) {
        throw { type: 'NOT_FOUND', message: 'User not found' }
      }
      return user
    },
    list: async ({ input }) => {
      const users = await db.listUsers(input)
      return {
        users,
        total: await db.countUsers(),
      }
    }
  }
})
```

### Share Contract

```typescript
// contract package shared between frontend and backend
export type { apiContract }

// Frontend
import type { apiContract } from '@my-company/api-contract'
const client = createClient<typeof apiContract>({ ... })

// Backend
import { apiContract } from '@my-company/api-contract'
const router = server.router(apiContract, { ... })
```

## Lazy Loading

Load router modules on-demand for better code splitting:

```typescript
const appRouter = router({
  user: router.lazy(() => import('./user-router')),
  post: router.lazy(() => import('./post-router')),
  comment: router.lazy(() => import('./comment-router')),
})
```

**Benefits:**
- Reduced initial bundle size
- Faster cold starts
- Better resource utilization
- Automatic code splitting

## Batch Requests

Optimize multiple requests into a single HTTP call:

```typescript
import { batchPlugin } from '@orpc/server'

const handler = new RPCHandler({
  router: appRouter,
  plugins: [batchPlugin({ maxBatchSize: 10 })]
})
```

**Client usage:**
```typescript
// These three calls will be batched into one request
const [user, posts, comments] = await Promise.all([
  client.user.get({ id: '1' }),
  client.post.list({ userId: '1' }),
  client.comment.list({ userId: '1' }),
])
```

## Request Deduplication

Prevent identical concurrent requests from executing multiple times:

```typescript
import { dedupePlugin } from '@orpc/server'

const handler = new RPCHandler({
  router: appRouter,
  plugins: [dedupePlugin()]
})
```

**How it works:**
- Identical concurrent requests share the same execution
- Only the first request executes the handler
- Subsequent identical requests receive the same result
- Deduplication key based on procedure path and input

## Retry Logic

Automatic retry with configurable strategies:

```typescript
import { retryPlugin } from '@orpc/server'

const handler = new RPCHandler({
  router: appRouter,
  plugins: [
    retryPlugin({
      maxRetries: 3,
      backoff: 'exponential', // or 'linear', 'fixed'
      retryableErrors: ['NETWORK_ERROR', 'TIMEOUT'],
      onRetry: ({ attempt, error }) => {
        console.log(`Retry attempt ${attempt} after error:`, error)
      }
    })
  ]
})
```

## Custom Plugin Development

Create plugins for cross-cutting concerns:

```typescript
interface Plugin {
  name: string
  onRequest?: (context: RequestContext) => Promise<Response | void>
  onResponse?: (context: ResponseContext) => Promise<Response | void>
  onError?: (context: ErrorContext) => Promise<Response | void>
}

const loggingPlugin: Plugin = {
  name: 'logging',
  onRequest: async ({ request, next }) => {
    console.log('Request:', request.procedure, request.input)
    const startTime = Date.now()

    const response = await next()

    console.log('Response time:', Date.now() - startTime, 'ms')
    return response
  },
  onError: async ({ error, request }) => {
    console.error('Error in', request.procedure, ':', error)
  }
}

const handler = new RPCHandler({
  router: appRouter,
  plugins: [loggingPlugin]
})
```
