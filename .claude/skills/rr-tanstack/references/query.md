# TanStack Query Reference

## Overview
TanStack Query (formerly React Query) is a data-fetching and state management library designed specifically for server state challenges. Eliminates the need for hundreds of lines of boilerplate code while handling asynchronous operations, caching, and synchronization across React, Vue, Angular, Solid, and Svelte.

## Core Hooks and Features

### useQuery
Manages data fetching with automatic caching and refetching capabilities. Configure with query key, fetch function, and options like `staleTime` and `retry` settings.

### useMutation
Handles data modifications with lifecycle callbacks: `onMutate`, `onError`, `onSuccess`, and `onSettled`. Supports optimistic updates where the UI updates before server confirmation.

### useInfiniteQuery
Enables pagination and infinite scroll patterns by managing paginated data with `fetchNextPage` and cursor-based navigation.

### useQueries
Executes multiple queries in parallel, useful for dashboards or components requiring simultaneous data requests.

### useSuspenseQuery
Integrates with React Suspense for declarative loading state management without manual loading checks.

## Advanced Patterns

### QueryClient Methods
Programmatic cache management:
- `prefetchQuery()` - Load data before navigation
- `setQueryData()` - Manually update cache
- `invalidateQueries()` - Mark data as stale
- `getQueryData()` - Synchronously access cached values

### Optimistic Updates
Update UI immediately while mutations process, with automatic rollback on failures.

### Dependent Queries
Execute queries sequentially using the `enabled` option to wait for prerequisite data.

### Server-Side Rendering
Hydration support for Next.js and similar frameworks, prefetching data server-side and transferring state to the client.

## Configuration

Global defaults can be set via `QueryClient` initialization with options for `staleTime`, `gcTime`, `retry` logic, and refetch behaviors. Query-key-specific defaults override globals using `setQueryDefaults()`.

## Key Benefits

Addresses unique server-state challenges through automatic synchronization, intelligent caching, deduplication, and memory management—all with minimal configuration overhead for most use cases.
