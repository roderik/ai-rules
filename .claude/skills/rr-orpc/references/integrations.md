# oRPC Integrations

## Framework Adapters

oRPC integrates with popular web frameworks through adapters.

### Next.js

**App Router:**
```typescript
// app/api/rpc/route.ts
import { RPCHandler } from '@orpc/server'
import { appRouter } from '@/server/router'

const handler = new RPCHandler({ router: appRouter })

export const POST = handler.handle
```

**Pages API:**
```typescript
// pages/api/rpc.ts
import { RPCHandler } from '@orpc/server'
import { appRouter } from '@/server/router'

const handler = new RPCHandler({ router: appRouter })

export default handler.handle
```

### Astro

```typescript
// src/pages/api/rpc.ts
import { RPCHandler } from '@orpc/server'
import { appRouter } from '@/server/router'

const handler = new RPCHandler({ router: appRouter })

export const POST = handler.handle
```

### Remix

```typescript
// app/routes/api.rpc.tsx
import { RPCHandler } from '@orpc/server'
import { appRouter } from '@/server/router'

const handler = new RPCHandler({ router: appRouter })

export const action = handler.handle
```

### SvelteKit

```typescript
// src/routes/api/rpc/+server.ts
import { RPCHandler } from '@orpc/server'
import { appRouter } from '$lib/server/router'

const handler = new RPCHandler({ router: appRouter })

export const POST = handler.handle
```

## State Management Integration

### TanStack Query

Full integration with React Query for data fetching and caching:

```typescript
import { createQueryClient } from '@orpc/react-query'
import { QueryClient, QueryClientProvider } from '@tanstack/react-query'
import { client } from './client'

const queryClient = new QueryClient()
const orpcQuery = createQueryClient(client, queryClient)

function UserProfile({ userId }: { userId: string }) {
  const { data, isLoading } = orpcQuery.user.get.useQuery({
    id: userId
  })

  if (isLoading) return <div>Loading...</div>
  return <div>{data.name}</div>
}

function App() {
  return (
    <QueryClientProvider client={queryClient}>
      <UserProfile userId="123" />
    </QueryClientProvider>
  )
}
```

**Mutations:**
```typescript
function UpdateUser() {
  const mutation = orpcQuery.user.update.useMutation()

  return (
    <button onClick={() => mutation.mutate({ id: '123', name: 'New Name' })}>
      Update
    </button>
  )
}
```

### Vue Pinia Colada

Integration with Vue's Pinia Colada for state management:

```typescript
import { createPiniaColada } from '@orpc/pinia-colada'
import { client } from './client'

const orpcColada = createPiniaColada(client)

// In component
const { data, isLoading } = orpcColada.user.get.useQuery({
  id: userId
})
```

## Authentication Integration

### Better Auth

Seamless integration with Better Auth:

```typescript
import { betterAuth } from 'better-auth'
import { createORPCHandler } from '@orpc/better-auth'

const auth = betterAuth({
  database: db,
  // ... auth config
})

const proc = oc.proc
  .use(async ({ context, next }) => {
    const session = await auth.getSession(context.request)
    return next({ session, user: session?.user })
  })

// Procedures now have access to session and user in context
const protectedProcedure = proc
  .handler(async ({ context }) => {
    if (!context.user) {
      throw { type: 'UNAUTHORIZED', message: 'Not authenticated' }
    }
    return { user: context.user }
  })
```

## AI Integration

### AI SDK

Stream AI responses through oRPC procedures:

```typescript
import { generateText, streamText } from 'ai'
import { openai } from '@ai-sdk/openai'

const chatProcedure = proc
  .input(z.object({ message: z.string() }))
  .output(z.object({ text: z.string() }))
  .handler(async function* ({ input }) {
    const stream = await streamText({
      model: openai('gpt-4'),
      prompt: input.message,
    })

    for await (const chunk of stream) {
      yield { text: chunk }
    }
  })
```

**Client usage:**
```typescript
const stream = await client.chat({ message: 'Hello AI' })

for await (const chunk of stream) {
  console.log(chunk.text) // Stream AI response
}
```

**Tool implementation:**
```typescript
import { tool } from 'ai'

const weatherTool = tool({
  description: 'Get weather information',
  parameters: z.object({ city: z.string() }),
  execute: async ({ city }) => {
    return await client.weather.get({ city })
  }
})
```

## Communication Protocols

### WebSocket

Real-time bidirectional communication:

```typescript
import { WebSocketHandler } from '@orpc/websocket'

const wsHandler = new WebSocketHandler({
  router: appRouter,
  context: initialContext,
})

// Server setup
server.on('upgrade', (request, socket, head) => {
  wsHandler.handleUpgrade(request, socket, head)
})
```

**Cloudflare Hibernation API:**
```typescript
import { HibernationHandler } from '@orpc/cloudflare'

const handler = new HibernationHandler({
  router: appRouter,
})

export default {
  async fetch(request: Request, env: Env) {
    return handler.handle(request, env)
  },
  async webSocket(client: WebSocket, env: Env) {
    return handler.handleWebSocket(client, env)
  }
}
```

### Message Port

For Electron apps and browser extensions:

```typescript
import { MessagePortLink } from '@orpc/message-port'

// In main process/background script
const port = new MessagePort()
const link = new MessagePortLink(port, { router: appRouter })

// In renderer/content script
const client = createClient<AppRouter>({
  links: [new MessagePortLink(port)]
})
```

### Server Actions

Next.js Server Actions integration:

```typescript
'use server'

import { createServerAction } from '@orpc/server-actions'
import { appRouter } from '@/server/router'

export const userActions = createServerAction(appRouter.user)

// Use in client components
import { userActions } from './actions'

function Component() {
  const [user, setUser] = useState(null)

  useEffect(() => {
    userActions.get({ id: '123' }).then(setUser)
  }, [])

  return <div>{user?.name}</div>
}
```

## OpenAPI Integration

Generate and serve OpenAPI specifications:

```typescript
import { OpenAPIHandler } from '@orpc/server'

const handler = new OpenAPIHandler({
  router: appRouter,
  context: initialContext,
  info: {
    title: 'My API',
    version: '1.0.0',
    description: 'API documentation',
  }
})

// Serve OpenAPI spec
app.get('/api/openapi.json', (req, res) => {
  res.json(handler.spec)
})

// Serve API endpoints
app.use('/api', handler.handle)
```

Generate client SDKs from OpenAPI spec:
```bash
npx openapi-generator-cli generate \
  -i http://localhost:3000/api/openapi.json \
  -g typescript-fetch \
  -o ./generated-client
```
