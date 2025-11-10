# TanStack Start Reference

## Overview
TanStack Start is a comprehensive full-stack React framework integrating TanStack Router and Vite. Enables modern web applications with server-side rendering, streaming capabilities, type-safe server functions, and universal deployment options.

## Core Architecture
Operates on an isomorphic-by-default model where code executes in both environments unless explicitly restricted. Provides explicit control over where code runs while maintaining a unified codebase. Two primary dependencies—TanStack Router for routing and Vite for bundling—form the foundation.

## Installation

Quickest approach uses the CLI:
```bash
npm create @tanstack/start@latest
```

Core packages: `@tanstack/react-start`, `@tanstack/react-router`, `vite`

## Configuration Requirements

**Vite Setup**: Must include TanStack Start plugin, with viteReact positioned after tanstackStart() in the plugin array.

**TypeScript**: Configure with ES2022 target, bundler module resolution, and strict null checks enabled.

**Package.json**: Declare `"type": "module"` and define scripts for development, building, and server startup.

## Routing Architecture

**File-Based System**: Routes follow naming conventions:
- `/index.tsx` matches "/"
- `/$postId.tsx` matches dynamic segments
- `$` creates wildcard routes capturing remaining path segments

**Root Route**: Implemented via `__root.tsx`, establishing the application shell, document structure, and global layout components.

**Router Creation**: Initialize using `createRouter()` with routeTree, configurable preload defaults, and staleness intervals.

## Server Functions

Server functions provide type-safe RPC capabilities callable from client code:

- **Validation**: Zod schemas validate input before processing
- **HTTP Methods**: Support GET and POST operations
- **Error Handling**: Validation failures propagate as catchable exceptions
- **Type Safety**: Function signatures maintain types across network boundaries

Example:
```typescript
export const createUser = createServerFn({ method: 'POST' })
  .inputValidator(CreateUserSchema)
  .handler(async ({ data }) => { ... })
```

## Environment Control Functions

- **createIsomorphicFn()**: Implements different logic for server and client environments
- **createServerOnlyFn()**: Prevents exposure of sensitive operations to client code
- **createClientOnlyFn()**: Ensures browser-specific APIs only execute client-side

## Server Routes

HTTP endpoints coexist alongside frontend routes using the same file-based approach:

- Support multiple HTTP methods (GET, POST, DELETE) within single route definitions
- Accept FormData, JSON payloads, and query parameters
- Return typed JSON responses or custom Response objects
- Enable status code specification (201, 204, 404)

## Middleware System

Middleware provides reusable logic for authentication, logging, and context management:

- **Request Middleware**: Applies to all server requests
- **Function Middleware**: Targets specific server functions
- **Global Middleware**: Configured in start.ts instance

Context flows between middleware layers with type safety preserved. Middleware can pass data between layers and send context bidirectionally between client and server.

## Context Management

Data passes through middleware chains with full type inference:

- Client middleware sends context to server via `sendContext`
- Server validates and enriches context before passing to handlers
- Typed context available in server function handlers
- Bidirectional data flow enables complex authentication scenarios

## Form Processing

Forms leverage progressive enhancement with server-side validation:

- **FormData Handling**: Server functions accept and parse FormData natively
- **Validation**: Custom validators extract and validate form fields
- **Redirects**: Successful submissions trigger navigation via `redirect()`
- **Error States**: Validation failures provide user-friendly error messages

## Deployment Options

### Cloudflare Workers
Install `@cloudflare/vite-plugin` and `wrangler`. Configure vite.config.ts with cloudflare plugin and wrangler.jsonc with compatibility settings. Deploy using `wrangler deploy`.

### Netlify
Install `@netlify/vite-plugin-tanstack-start`. Add plugin to Vite configuration and configure netlify.toml with build command and publish directory. Deploy via Netlify CLI or Git integration.

## Primary Use Cases

- SEO-optimized applications requiring server-side rendering
- Type-safe APIs colocated with frontend route code
- Authentication systems leveraging composable middleware
- Forms with progressive enhancement strategies
- Multi-platform deployment to edge networks and serverless platforms

## Development Advantages

Eliminates boilerplate for server-client communication through automatic type inference. File-based routing convention reduces configuration while maintaining flexibility. End-to-end type safety flows from server functions through middleware to client components, preventing runtime mismatches.
