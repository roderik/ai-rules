# Workflow Audit for rr-tanstack

## ✓ Passed

- Library Selection Guide provides clear decision tree (lines 25-158)
- Implementation Workflow section exists (line 121)
- Clear 5-step workflow defined
- Good conditional patterns in Library Selection Guide
- Common Integration Patterns documented
- Reference files support detailed workflows

## ✗ Missing/Needs Improvement

- Implementation Workflow lacks explicit checkbox format
- No Plan-Validate-Execute structure
- No testing workflow
- No deployment workflow
- Steps are high-level guidance, not actionable checklists
- No troubleshooting workflow
- No error handling workflow
- No validation checkpoints
- Missing feedback loops
- No rollback/recovery procedures

## Recommendations

1. **Convert Implementation Workflow to checkbox format**:

   ```markdown
   ## Implementation Workflow

   ### 1. Identify the requirement

   - [ ] Determine which TanStack library addresses the need
   - [ ] Review library selection guide above
   - [ ] Consider if multiple libraries needed (e.g., Query + Table)
   - [ ] Check framework compatibility

   ### 2. Load reference documentation

   - [ ] Identify appropriate `references/<library>.md` file
   - [ ] Read setup and configuration section
   - [ ] Review usage patterns and examples
   - [ ] Note any framework-specific considerations

   ### 3. Install dependencies

   - [ ] Use framework-specific package (e.g., `@tanstack/react-query`)
   - [ ] Install: `bun add @tanstack/<framework>-<library>`
   - [ ] Install type definitions if needed
   - [ ] Verify installation successful

   ### 4. Follow framework patterns

   - [ ] Each library provides framework-specific hooks/composables
   - [ ] Import from framework-specific package
   - [ ] Configure according to framework conventions
   - [ ] Test basic integration

   ### 5. Leverage TypeScript

   - [ ] All libraries provide full type inference
   - [ ] Verify types are working correctly
   - [ ] No type assertions needed
   - [ ] Autocomplete working in IDE
   ```

2. **Add detailed library-specific workflows**:

   ```markdown
   ## TanStack Query Workflow

   **When to use:** Data fetching, caching, server state management

   ### Setup:

   - [ ] Install: `bun add @tanstack/react-query`
   - [ ] Create QueryClient
   - [ ] Wrap app with QueryClientProvider
   - [ ] Configure default options

   ### Usage:

   - [ ] Define query with `useQuery` hook
   - [ ] Set unique query key
   - [ ] Implement fetch function
   - [ ] Handle loading and error states
   - [ ] Use mutation with `useMutation` for writes
   - [ ] Invalidate queries after mutations

   ### Validation:

   - [ ] Queries refetch on window focus
   - [ ] Stale data refreshes appropriately
   - [ ] Mutations trigger cache updates
   - [ ] Error handling works correctly
   - [ ] Loading states display properly

   ## TanStack Table Workflow

   **When to use:** Data grids with sorting, filtering, pagination

   ### Setup:

   - [ ] Install: `bun add @tanstack/react-table`
   - [ ] Load `references/table.md` for patterns
   - [ ] Define column definitions
   - [ ] Set up table instance

   ### Implementation:

   - [ ] Configure sorting
   - [ ] Add filtering
   - [ ] Implement pagination
   - [ ] Add row selection if needed
   - [ ] Style table components

   ### Validation:

   - [ ] Sorting works correctly
   - [ ] Filters apply properly
   - [ ] Pagination navigates correctly
   - [ ] Row selection persists
   - [ ] Performance is acceptable

   ## TanStack Router Workflow

   **When to use:** Type-safe routing in React applications

   ### Setup:

   - [ ] Install: `bun add @tanstack/react-router`
   - [ ] Load `references/router.md` for setup
   - [ ] Choose file-based or code-based routing
   - [ ] Generate route types

   ### Implementation:

   - [ ] Create route definitions
   - [ ] Add route loaders for data fetching
   - [ ] Implement search param validation
   - [ ] Add route guards if needed
   - [ ] Configure navigation

   ### Validation:

   - [ ] Routes navigate correctly
   - [ ] Type safety maintained
   - [ ] Search params validated
   - [ ] Loaders prefetch data
   - [ ] Guards protect routes
   ```

3. **Add Integration Workflows**:

   ```markdown
   ## Common Integration Workflows

   ### Query + Router Integration

   **Use case:** Type-safe SSR with caching

   - [ ] Set up TanStack Router with route loaders
   - [ ] Configure TanStack Query client
   - [ ] Use `queryClient.ensureQueryData` in loaders
   - [ ] Prefetch data during navigation
   - [ ] Handle loading and error states
   - [ ] Test SSR behavior

   ### Table + Virtual Integration

   **Use case:** Large datasets with efficient rendering

   - [ ] Set up TanStack Table for data processing
   - [ ] Configure TanStack Virtual for rendering
   - [ ] Pass table rows to virtualizer
   - [ ] Render only visible rows
   - [ ] Test with large datasets (1000+ rows)
   - [ ] Verify performance acceptable

   ### Form + Query Integration

   **Use case:** Form submissions with mutations

   - [ ] Set up TanStack Form
   - [ ] Create mutation with TanStack Query
   - [ ] Handle form submission
   - [ ] Invalidate queries on success
   - [ ] Display success/error feedback
   - [ ] Reset form after submission
   ```

4. **Add Troubleshooting Workflow**:

   ```markdown
   ## Troubleshooting Workflow

   ### TanStack Query Issues

   **Queries not refetching:**

   - [ ] Check query key dependencies
   - [ ] Verify stale time configuration
   - [ ] Check refetch settings
   - [ ] Review window focus behavior
   - [ ] Test manual refetch

   **Cache not updating:**

   - [ ] Verify mutation invalidates queries
   - [ ] Check query keys match
   - [ ] Review optimistic update logic
   - [ ] Test cache manipulation manually

   ### TanStack Table Issues

   **Sorting not working:**

   - [ ] Verify column sortingFn defined
   - [ ] Check data types match
   - [ ] Review table state
   - [ ] Test manual sorting

   **Filtering slow:**

   - [ ] Check filter function efficiency
   - [ ] Consider server-side filtering
   - [ ] Review data size
   - [ ] Profile performance

   ### TanStack Router Issues

   **Type errors:**

   - [ ] Regenerate route types
   - [ ] Check route definitions
   - [ ] Verify search param schemas
   - [ ] Review loader return types

   **Navigation failing:**

   - [ ] Check route paths correct
   - [ ] Verify guards not blocking
   - [ ] Review loader errors
   - [ ] Test navigation manually
   ```

5. **Add Testing Workflows**:

   ```markdown
   ## Testing Workflows

   ### Testing TanStack Query

   - [ ] Create wrapper with QueryClientProvider
   - [ ] Use testing utilities from library
   - [ ] Mock fetch responses
   - [ ] Test loading states
   - [ ] Test error states
   - [ ] Test success states
   - [ ] Verify cache behavior

   ### Testing TanStack Table

   - [ ] Render table with test data
   - [ ] Test sorting interaction
   - [ ] Test filtering interaction
   - [ ] Test pagination interaction
   - [ ] Verify row selection
   - [ ] Check accessibility

   ### Testing TanStack Router

   - [ ] Create router with memory history
   - [ ] Test route navigation
   - [ ] Test route loaders
   - [ ] Test search params
   - [ ] Test route guards
   - [ ] Verify type safety
   ```

6. **Add Performance Optimization Workflow**:

   ```markdown
   ## Performance Optimization

   ### TanStack Query Optimization

   - [ ] Configure stale time appropriately
   - [ ] Use query placeholders
   - [ ] Implement prefetching
   - [ ] Enable query deduplication
   - [ ] Use suspense mode
   - [ ] Monitor cache size

   ### TanStack Table Optimization

   - [ ] Virtualize large tables
   - [ ] Use server-side processing
   - [ ] Memoize column definitions
   - [ ] Debounce filters
   - [ ] Optimize render cycles
   - [ ] Profile performance

   ### TanStack Virtual Optimization

   - [ ] Configure overscan appropriately
   - [ ] Use dynamic size calculation
   - [ ] Optimize scroll performance
   - [ ] Test with large datasets
   - [ ] Profile render times
   ```
