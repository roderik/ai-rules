---
name: rr-orpc
description: Use when implementing type-safe RPC APIs with oRPC framework. Covers procedures, routers, server setup, client usage, streaming, file handling, and framework integrations (Next.js, React Query, etc.).
---

# oRPC

## Overview

oRPC is a TypeScript RPC framework enabling end-to-end type-safe communication between client and server. Use this skill when implementing RPC endpoints, setting up type-safe API clients, integrating with frameworks like Next.js or React Query, or working with advanced features like streaming and file handling.

## When to Use This Skill

Invoke this skill when:
- Setting up oRPC server handlers (RPCHandler, OpenAPIHandler)
- Creating type-safe procedures and routers
- Implementing oRPC clients with full type inference
- Integrating oRPC with Next.js, React Query, or other frameworks
- Working with streaming responses (SSE), file uploads/downloads
- Implementing middleware, plugins, or contract-first APIs
- Questions about oRPC architecture, best practices, or capabilities

## Quick Start Guide

### Basic Server Setup

Create procedures and routers using the type-safe API:

```typescript
import { z } from 'zod'
import { proc, router } from '@orpc/server'

const getUserProcedure = proc
  .input(z.object({ id: z.string() }))
  .output(z.object({ name: z.string(), email: z.string() }))
  .handler(async ({ input }) => {
    return await db.getUser(input.id)
  })

const appRouter = router({
  user: router({
    get: getUserProcedure,
    list: listUsersProcedure,
  })
})
```

Create handler and integrate with framework:

```typescript
import { RPCHandler } from '@orpc/server'

const handler = new RPCHandler({ router: appRouter })

// Next.js App Router
export const POST = handler.handle
```

### Basic Client Setup

Create type-safe client:

```typescript
import { createClient, RPCLink } from '@orpc/client'
import type { AppRouter } from './server'

const client = createClient<AppRouter>({
  links: [new RPCLink({ url: '/rpc' })]
})

// Call with full type safety
const user = await client.user.get({ id: '123' })
```

## Common Tasks

### Server Implementation

For server setup, middleware, plugins, and error handling:
- Read `references/server-setup.md` for RPCHandler, OpenAPIHandler configuration
- Review middleware patterns for authentication and request processing
- Explore plugin system for CORS, compression, batching, retry logic

### Creating Procedures and Routers

For understanding core concepts:
- Read `references/core-concepts.md` for procedures, routers, context system
- Review contract-first development patterns
- Understand type safety features and validation

### Client Usage

For client implementation and type inference:
- Read `references/client-setup.md` for RPCLink, OpenAPILink setup
- Review type inference utilities (InferInput, InferOutput, InferErrors)
- Explore error handling patterns and streaming consumption

### Framework Integration

For Next.js, React Query, and other integrations:
- Read `references/integrations.md` for framework adapters
- Review state management integration (TanStack Query, Pinia Colada)
- Explore authentication (Better Auth), AI (AI SDK), and WebSocket support

### Advanced Features

For streaming, file handling, and optimization:
- Read `references/advanced-features.md` for SSE streaming, Durable Iterator
- Review file upload/download with type safety
- Explore native type support (Date, Map, Set, URL, File, Blob)
- Understand batch requests, deduplication, and retry logic

## Reference Files

This skill includes comprehensive reference documentation:

- **core-concepts.md** - Procedures, routers, context system, contracts, type safety
- **server-setup.md** - Handlers (RPC/OpenAPI), middleware, plugins, error handling
- **client-setup.md** - Client creation, type inference, error handling, streaming
- **integrations.md** - Framework adapters, state management, auth, AI, WebSocket
- **advanced-features.md** - Streaming (SSE), file handling, native types, batching

Load reference files as needed based on the specific task or question.
