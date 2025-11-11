# Workflow Audit for rr-orpc

## ✓ Passed

- Quick Start Guide section exists (line 23)
- Common Tasks section provides navigation to references (line 76)
- Good organization using progressive disclosure (references files)
- Clear triggers and use cases documented
- Reference files architecture supports workflow documentation

## ✗ Missing/Needs Improvement

- NO "Development Workflow" section present
- Quick Start Guide is example-only, lacks workflow structure
- No numbered sequential steps
- No checklists anywhere in main SKILL.md
- No Plan-Validate-Execute pattern
- No testing workflow
- No deployment workflow
- No conditional workflows ("if X then Y")
- No feedback loops (validator→fix→repeat)
- Common Tasks section is reference-only, not actionable workflow
- No troubleshooting workflow
- No error handling workflow
- Main SKILL.md heavily relies on references without providing workflow structure

## Recommendations

1. **Add comprehensive Development Workflow section after Quick Start Guide**:

   ```markdown
   ## Development Workflow

   ### 1. Plan RPC API

   **Before writing code:**

   - [ ] Identify procedures needed (queries, mutations)
   - [ ] Define input/output schemas with Zod
   - [ ] Plan router structure and nesting
   - [ ] Determine context requirements (auth, db, etc.)
   - [ ] Design error handling strategy
   - [ ] Plan streaming needs (if any)

   ### 2. Setup Project

   **Initial setup:**

   - [ ] Install dependencies: `bun add @orpc/server @orpc/client zod`
   - [ ] Install framework adapter (e.g., `@orpc/next`)
   - [ ] Create project structure:
   ```

   src/
   ├── server/
   │ ├── router.ts # Main router
   │ ├── context.ts # Context definition
   │ └── procedures/ # Individual procedures
   └── client/
   └── index.ts # Type-safe client

   ```
   - [ ] Configure TypeScript for strict mode
   - [ ] Set up dev environment

   ### 3. Define Procedures and Routers

   **Procedure implementation:**

   - [ ] Create procedure with `proc` builder
   - [ ] Define input schema with Zod: `.input(z.object({...}))`
   - [ ] Define output schema with Zod: `.output(z.object({...}))`
   - [ ] Implement handler function: `.handler(async ({ input, context }) => {...})`
   - [ ] Add error handling with custom error types
   - [ ] Test procedure locally

   **Router creation:**

   - [ ] Organize procedures into routers: `router({ ... })`
   - [ ] Nest routers for logical grouping
   - [ ] Export main router with type for client
   - [ ] Verify type safety with TypeScript

   **Validation checklist:**

   - [ ] All inputs validated with Zod schemas
   - [ ] All outputs match declared schemas
   - [ ] Error cases handled explicitly
   - [ ] TypeScript shows no type errors
   - [ ] Procedures follow naming conventions

   ### 4. Setup Server Handler

   **Handler configuration:**

   - [ ] Create RPCHandler: `new RPCHandler({ router })`
   - [ ] Or OpenAPIHandler for REST: `new OpenAPIHandler({ router })`
   - [ ] Configure middleware (auth, logging, CORS)
   - [ ] Set up error handlers
   - [ ] Integrate with framework (Next.js, Express, etc.)

   **Framework integration (Next.js example):**

   - [ ] Create API route: `app/api/rpc/[...all]/route.ts`
   - [ ] Export handler: `export const POST = handler.handle`
   - [ ] Configure Next.js middleware if needed
   - [ ] Test handler responds to requests

   ### 5. Create Type-Safe Client

   **Client setup:**

   - [ ] Import router type from server
   - [ ] Create client with `createClient<AppRouter>`
   - [ ] Configure links (RPCLink or OpenAPILink)
   - [ ] Set base URL
   - [ ] Test client connection

   **Client usage:**

   - [ ] Call procedures with full type inference
   - [ ] Handle errors appropriately
   - [ ] Use streaming features if needed
   - [ ] Verify type safety at call sites

   ### 6. Test RPC API

   **Testing checklist:**

   - [ ] Unit test individual procedures
   - [ ] Test input validation (valid and invalid inputs)
   - [ ] Test error handling
   - [ ] Test authentication/authorization
   - [ ] Integration test full client-server flow
   - [ ] Test streaming if implemented
   - [ ] Verify type safety maintained

   ### 7. Deploy and Monitor

   **Deployment:**

   - [ ] Build project: `bun run build`
   - [ ] Run tests: `bun test`
   - [ ] Deploy to target environment
   - [ ] Verify endpoints accessible
   - [ ] Test with production client

   **Monitoring:**

   - [ ] Set up error tracking
   - [ ] Monitor response times
   - [ ] Log failed requests
   - [ ] Track usage patterns
   ```

2. **Add Quick Start implementation workflow**:

   ````markdown
   ## Quick Start Workflow

   **1. Install dependencies:**

   - [ ] Run: `bun add @orpc/server @orpc/client zod`

   **2. Create server procedures:**

   ```typescript
   // src/server/router.ts
   import { z } from "zod";
   import { proc, router } from "@orpc/server";

   const getUserProcedure = proc
     .input(z.object({ id: z.string() }))
     .output(z.object({ name: z.string(), email: z.string() }))
     .handler(async ({ input }) => {
       return await db.getUser(input.id);
     });

   export const appRouter = router({
     user: router({
       get: getUserProcedure,
     }),
   });

   export type AppRouter = typeof appRouter;
   ```
   ````

   - [ ] Define schemas with explicit types
   - [ ] Implement handler with business logic
   - [ ] Export router type for client

   **3. Create API handler:**

   ```typescript
   // app/api/rpc/[...all]/route.ts
   import { RPCHandler } from "@orpc/server";
   import { appRouter } from "@/server/router";

   const handler = new RPCHandler({ router: appRouter });
   export const POST = handler.handle;
   ```

   - [ ] Create handler with router
   - [ ] Export for framework (Next.js shown)

   **4. Create type-safe client:**

   ```typescript
   // src/client/index.ts
   import { createClient, RPCLink } from "@orpc/client";
   import type { AppRouter } from "@/server/router";

   export const client = createClient<AppRouter>({
     links: [new RPCLink({ url: "/api/rpc" })],
   });
   ```

   - [ ] Import router type from server
   - [ ] Configure client with correct URL

   **5. Use client with type safety:**

   ```typescript
   // In your app
   const user = await client.user.get({ id: "123" });
   // user is fully typed!
   ```

   - [ ] Call procedures with auto-complete
   - [ ] Verify TypeScript catches type errors

   ```

   ```

3. **Add troubleshooting workflow**:

   ```markdown
   ## Troubleshooting Workflow

   **Type errors in client:**

   - [ ] Verify router type exported correctly from server
   - [ ] Check client import uses `type` keyword
   - [ ] Ensure `AppRouter` type matches actual router
   - [ ] Verify tsconfig `strict: true` enabled

   **Handler not receiving requests:**

   - [ ] Verify API route created correctly
   - [ ] Check handler exported as framework expects
   - [ ] Test endpoint with curl or Postman
   - [ ] Review framework routing configuration

   **Validation failing:**

   - [ ] Review Zod schema matches expected input
   - [ ] Check client sending correct data shape
   - [ ] Test schema with sample data
   - [ ] Review error messages for specifics

   **Streaming not working:**

   - [ ] Verify procedure uses AsyncIterator
   - [ ] Check client configured for streaming
   - [ ] Test network supports streaming (SSE)
   - [ ] Review browser console for errors
   ```

4. **Add conditional workflows**:

   ```markdown
   ## Conditional Workflows

   **If implementing authentication:**

   - [ ] Load `references/server-setup.md` for middleware patterns
   - [ ] Create context with user data
   - [ ] Add auth middleware to procedures
   - [ ] Protect routes with auth checks
   - [ ] Test unauthorized access returns error

   **If using Next.js:**

   - [ ] Load `references/integrations.md` for Next.js adapter
   - [ ] Set up API routes correctly
   - [ ] Configure middleware if needed
   - [ ] Use server components where appropriate

   **If implementing file upload:**

   - [ ] Load `references/advanced-features.md` for file handling
   - [ ] Use FormData in procedure input
   - [ ] Configure multipart parsing
   - [ ] Test with various file types

   **If setting up streaming:**

   - [ ] Load `references/advanced-features.md` for SSE patterns
   - [ ] Use AsyncIterator in procedure
   - [ ] Configure client for streaming
   - [ ] Handle connection interruptions
   ```

5. **Add error handling workflow**:

   ```markdown
   ## Error Handling Workflow

   **Setup custom errors:**

   - [ ] Define error types with meaningful codes
   - [ ] Use `.error()` in procedure definition
   - [ ] Throw custom errors in handler
   - [ ] Document error codes

   **Client error handling:**

   - [ ] Wrap calls in try-catch blocks
   - [ ] Check error types with type guards
   - [ ] Display user-friendly messages
   - [ ] Log errors for debugging
   - [ ] Implement retry logic if appropriate

   **Server error handling:**

   - [ ] Add global error handler to RPCHandler
   - [ ] Log errors with context
   - [ ] Sanitize error messages for client
   - [ ] Monitor error rates
   ```

6. **Add validation workflow**:

   ```markdown
   ## Schema Validation Workflow

   **Before deployment:**

   - [ ] All procedure inputs have Zod schemas
   - [ ] All procedure outputs have Zod schemas
   - [ ] Schemas match actual data shapes
   - [ ] Error cases have custom error definitions
   - [ ] TypeScript compilation succeeds
   - [ ] Client shows correct types at call sites

   **During development:**

   - [ ] Test schemas with sample data
   - [ ] Verify validation errors are helpful
   - [ ] Check type inference works correctly
   - [ ] Use `.parse()` to test schemas manually
   ```

7. **Restructure Common Tasks section**:

   ```markdown
   ## Common Task Workflows

   ### Server Implementation

   **When:** Setting up RPC server or adding procedures

   **Workflow:**

   - [ ] Load `references/server-setup.md` for detailed patterns
   - [ ] Review RPCHandler vs OpenAPIHandler decision
   - [ ] Implement middleware if needed
   - [ ] Configure plugins (CORS, compression, etc.)
   - [ ] Test error handling

   ### Creating Procedures and Routers

   **When:** Defining new RPC endpoints

   **Workflow:**

   - [ ] Load `references/core-concepts.md` for procedure patterns
   - [ ] Define input/output schemas
   - [ ] Implement handler logic
   - [ ] Nest in appropriate router
   - [ ] Test with client

   ### Client Usage

   **When:** Calling RPC procedures from frontend

   **Workflow:**

   - [ ] Load `references/client-setup.md` for setup
   - [ ] Create type-safe client
   - [ ] Handle errors appropriately
   - [ ] Test all procedure calls

   ### Framework Integration

   **When:** Integrating with Next.js, React Query, etc.

   **Workflow:**

   - [ ] Load `references/integrations.md` for adapter
   - [ ] Follow framework-specific setup
   - [ ] Configure state management if needed
   - [ ] Test integration thoroughly

   ### Advanced Features

   **When:** Implementing streaming, file handling, etc.

   **Workflow:**

   - [ ] Load `references/advanced-features.md` for patterns
   - [ ] Implement feature following examples
   - [ ] Test edge cases
   - [ ] Document usage
   ```
