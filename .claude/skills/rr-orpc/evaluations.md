# Evaluation Scenarios for rr-orpc

## Scenario 1: Basic Usage - Create Simple RPC Procedure

**Input:** "Create an oRPC procedure for getting a user by ID with proper input validation"

**Expected Behavior:**

- Automatically activate when "oRPC procedure" is mentioned
- Import necessary oRPC functions
- Define input schema with Zod validation
- Create procedure with proper type inference
- Include error handling
- Use proper TypeScript types
- Follow oRPC patterns for procedure definition

**Success Criteria:**

- [ ] Imports from '@orpc/server' or '@orpc/zod'
- [ ] Input schema defined with z.object()
- [ ] Schema includes z.string().uuid() or similar for ID validation
- [ ] Procedure created with .input() and .handler()
- [ ] Handler receives typed input
- [ ] Returns properly typed output
- [ ] Includes error handling (user not found)
- [ ] Throws ORPCError or uses proper error handling
- [ ] TypeScript types properly inferred

## Scenario 2: Complex Scenario - Full RPC API with Middleware and File Upload

**Input:** "Build a complete blog API with oRPC including authentication middleware, CRUD operations for posts, and file upload for post images. Include React Query integration on the frontend."

**Expected Behavior:**

- Load skill and understand full-stack oRPC architecture
- Create server implementation:
  - Define auth middleware with JWT validation
  - Create router with posts namespace
  - Implement CRUD procedures (create, read, update, delete)
  - Add file upload procedure with multipart/form-data
  - Use middleware for protected routes
  - Proper error handling throughout
- Create client implementation:
  - Generate typed client from router
  - Set up React Query with oRPC
  - Create hooks for each procedure
  - Handle file upload with FormData
  - Include error handling and loading states
- Reference framework integrations
- Include Next.js setup if relevant

**Success Criteria:**

- [ ] Auth middleware created with JWT validation
- [ ] Router created with organized namespaces
- [ ] All CRUD procedures implemented with proper Zod schemas
- [ ] File upload procedure handles multipart/form-data
- [ ] Protected procedures use auth middleware
- [ ] Proper error handling with ORPCError
- [ ] Client generated from router type
- [ ] React Query setup with oRPC client
- [ ] Custom hooks created for procedures
- [ ] File upload uses FormData on client
- [ ] Loading and error states handled
- [ ] Type safety maintained throughout
- [ ] References framework integration docs

## Scenario 3: Error Handling - Type Mismatch in Procedure

**Input:** "My oRPC client is giving TypeScript errors saying the input type doesn't match. The procedure expects { userId: string } but I'm passing { id: string }."

**Expected Behavior:**

- Recognize input schema mismatch
- Identify the field name difference (userId vs id)
- Explain oRPC's strict type checking
- Show the procedure's input schema definition
- Provide two solutions:
  1. Update client code to use correct field name
  2. Update procedure schema to accept 'id' instead
- Explain type inference from Zod schema
- Show how to inspect procedure types
- Emphasize type safety benefits

**Success Criteria:**

- [ ] Identifies field name mismatch (userId vs id)
- [ ] Explains oRPC type safety from Zod schema
- [ ] Shows the procedure's input schema
- [ ] Provides solution 1: Update client to use userId
- [ ] Provides solution 2: Change schema to z.object({ id: z.string() })
- [ ] Explains trade-offs of each approach
- [ ] Shows how to inspect procedure types in IDE
- [ ] Emphasizes this is working as intended (type safety)
- [ ] References oRPC type inference documentation
