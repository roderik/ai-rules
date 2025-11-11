# Evaluation Scenarios for rr-tanstack

## Scenario 1: Basic Usage - Set Up TanStack Query for Data Fetching

**Input:** "Set up TanStack Query in my React app to fetch and cache user data from an API"

**Expected Behavior:**

- Automatically activate when "TanStack Query" is mentioned
- Install @tanstack/react-query
- Create QueryClient and QueryClientProvider setup
- Create custom hook for fetching users
- Use useQuery with proper key and fetcher
- Include error and loading states
- Add TypeScript types for response
- Show usage in component
- Include cache configuration

**Success Criteria:**

- [ ] Imports from @tanstack/react-query
- [ ] QueryClient created with proper config
- [ ] QueryClientProvider wraps app
- [ ] Custom hook created (useUsers)
- [ ] useQuery used with query key array
- [ ] Query function properly typed
- [ ] Error and loading states handled
- [ ] TypeScript interface for User type
- [ ] Stale time and cache time configured
- [ ] Example component using the hook

## Scenario 2: Complex Scenario - Full CRUD with Optimistic Updates

**Input:** "Build a todo app with TanStack Query that supports creating, updating, and deleting todos. Include optimistic updates so the UI updates immediately before the server responds. Also add infinite scrolling for the todo list."

**Expected Behavior:**

- Load skill and understand full CRUD pattern
- Create queries for fetching todos (with pagination)
- Create mutations for create/update/delete
- Implement optimistic updates in mutations:
  - onMutate to update cache immediately
  - onError to rollback
  - onSettled to invalidate and refetch
- Add infinite query for scrolling
- Use useInfiniteQuery with getNextPageParam
- Include proper TypeScript types
- Reference TanStack Query patterns
- Show error handling for each operation

**Success Criteria:**

- [ ] useQuery for initial todo fetch
- [ ] useInfiniteQuery for paginated list
- [ ] getNextPageParam configured correctly
- [ ] useMutation for create/update/delete operations
- [ ] Optimistic updates in onMutate callback
- [ ] Cache manually updated before server response
- [ ] onError rollback to previous cache state
- [ ] onSettled invalidates queries
- [ ] queryClient.setQueryData used for optimistic updates
- [ ] queryClient.invalidateQueries used for refetch
- [ ] Proper TypeScript types throughout
- [ ] Error states handled for mutations
- [ ] Loading states for queries

## Scenario 3: Error Handling - Stale Data After Mutation

**Input:** "After I update a todo, the list still shows the old data even though the mutation succeeded. I'm using TanStack Query."

**Expected Behavior:**

- Recognize cache invalidation issue
- Explain TanStack Query caching behavior
- Check if mutation includes invalidation
- Show proper invalidation pattern:
  - Use onSuccess or onSettled in mutation
  - Call queryClient.invalidateQueries
  - Match correct query keys
- Explain query key matching
- Show alternative: manually update cache in onSuccess
- Reference TanStack Query cache patterns

**Success Criteria:**

- [ ] Identifies missing cache invalidation
- [ ] Checks mutation for onSuccess/onSettled callback
- [ ] Shows correct invalidation: queryClient.invalidateQueries({ queryKey: ['todos'] })
- [ ] Explains query key matching (exact vs prefix)
- [ ] Provides alternative manual cache update approach
- [ ] Shows onSuccess with setQueryData
- [ ] Explains when to use invalidation vs manual update
- [ ] Verifies query keys match between query and invalidation
- [ ] References TanStack Query documentation
