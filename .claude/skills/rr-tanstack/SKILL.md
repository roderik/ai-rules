---
name: rr-tanstack
description: This skill provides comprehensive guidance for implementing TanStack libraries (Query, Table, Router, Form, Start, Virtual, Store, DB) in modern web applications. Use this skill when working with data fetching, state management, routing, forms, tables, virtualization, or full-stack React development. Triggers on mentions of TanStack libraries, TypeScript type-safe routing/forms/queries, headless UI components, server-side rendering with type safety, or when building data-heavy applications requiring caching, pagination, filtering, or real-time synchronization.
---

# TanStack Suite

## Overview

TanStack is a suite of framework-agnostic, headless libraries providing type-safe solutions for common web development challenges. All libraries share core principles: framework agnosticism, TypeScript-first design, headless architecture (logic without UI), and performance optimization.

## When to Use This Skill

Use this skill when implementing or troubleshooting:
- Data fetching and server state management
- Complex forms with validation
- Data tables with sorting, filtering, pagination
- Type-safe routing with search parameter management
- Full-stack React applications with SSR
- Virtual scrolling for large datasets
- Reactive state management
- Real-time data synchronization

## Library Selection Guide

### Query — Server State Management
**Use for:** Data fetching, caching, synchronization, mutations, optimistic updates

Load `references/query.md` when working with:
- API integration and data fetching
- Cache management and invalidation
- Infinite scroll or pagination
- Real-time data synchronization
- Optimistic UI updates

**Key identifiers:** `useQuery`, `useMutation`, `QueryClient`, `invalidateQueries`, `prefetchQuery`

### Table — Data Grids
**Use for:** Sortable, filterable, paginated data displays

Load `references/table.md` when working with:
- Admin panels or dashboards
- E-commerce product catalogs
- Content management systems
- Any tabular data display
- Server-side or client-side data processing

**Key identifiers:** Column definitions, sorting, filtering, pagination, row selection

### Router — Type-Safe Routing
**Use for:** React applications requiring sophisticated routing with full type safety

Load `references/router.md` when working with:
- File-based or code-based routing
- Search parameter state management
- Route loaders and prefetching
- Authentication flows and guards
- Type-safe navigation

**Key identifiers:** `createFileRoute`, `useNavigate`, `useParams`, `useSearch`, `beforeLoad`

### Form — Complex Form State
**Use for:** Multi-step forms, validation-intensive forms, dynamic form builders

Load `references/form.md` when working with:
- Multi-step wizards
- Schema-based validation (Zod, Valibot, Yup)
- Array fields and nested objects
- Async validation
- Cross-field dependencies

**Key identifiers:** `FormApi`, `FieldApi`, `useForm`, array fields, validation rules

### Start — Full-Stack React
**Use for:** SSR applications with type-safe server functions and progressive enhancement

Load `references/start.md` when working with:
- Server-side rendering
- Type-safe RPC (server functions)
- Full-stack authentication
- Form processing with progressive enhancement
- Deployment to Cloudflare Workers or Netlify

**Key identifiers:** `createServerFn`, `createIsomorphicFn`, middleware, server routes

### Virtual — Large Dataset Rendering
**Use for:** Efficiently rendering thousands of rows/items

Load `references/virtual.md` when working with:
- Long lists (chat messages, logs, feeds)
- Large tables (combine with TanStack Table)
- Grids with many items
- Fixed, variable, or dynamic item sizes

**Key identifiers:** `useVirtualizer`, `getVirtualItems`, `getTotalSize`, overscan

### Store — Reactive State Management
**Use for:** Signals-based state management across frameworks

Load `references/store.md` when working with:
- Lightweight state management
- Selective component subscriptions
- Computed values (derived state)
- Side effects with dependency tracking

**Key identifiers:** Store primitives, `useStore`, `Derived`, `Effect`, `Batch`

### DB — Real-Time Data Synchronization
**Use for:** Local-first applications with real-time sync and optimistic updates

Load `references/db.md` when working with:
- Real-time collaborative features
- Offline-first applications
- Local persistence with sync
- Complex client-side queries
- Optimistic mutations

**Key identifiers:** Collections, live queries, ElectricSQL, LocalStorage, derived collections

## Implementation Workflow

1. **Identify the requirement** — Determine which TanStack library addresses the need
2. **Load reference documentation** — Read the specific `references/<library>.md` file
3. **Install dependencies** — Use framework-specific package (e.g., `@tanstack/react-query`)
4. **Follow framework patterns** — Each library provides framework-specific hooks/composables
5. **Leverage TypeScript** — All libraries provide full type inference and safety

## Common Integration Patterns

### Query + Router
Router loaders fetch data using Query for type-safe SSR with caching:
```typescript
// In route loader
const queryOptions = queryClient.ensureQueryData(userQueryOptions)
```

### Table + Virtual
Combine for large dataset tables with efficient rendering:
```typescript
// Virtual handles rendering, Table handles data processing
const virtualizer = useVirtualizer({ count: table.getRowModel().rows.length })
```

### Form + Query
Form submissions trigger mutations with automatic cache invalidation:
```typescript
// In form submit handler
await createUserMutation.mutateAsync(formData)
```

### Start + Router + Query
Full-stack applications with type-safe routing and data fetching:
```typescript
// Server functions called from route loaders
const data = await serverFn({ userId })
```

## Framework Support

All libraries support React, Vue, Svelte, Solid, and Angular (with varying levels of maturity). Some libraries also support Lit, Qwik, and vanilla JavaScript. Always use the framework-specific adapter package for optimal integration.

## Resources

Detailed documentation for each library is available in the `references/` directory:

- `references/query.md` — TanStack Query complete reference
- `references/table.md` — TanStack Table complete reference
- `references/router.md` — TanStack Router complete reference
- `references/form.md` — TanStack Form complete reference
- `references/start.md` — TanStack Start complete reference
- `references/virtual.md` — TanStack Virtual complete reference
- `references/store.md` — TanStack Store complete reference
- `references/db.md` — TanStack DB complete reference

Load specific reference files as needed based on the implementation task.
