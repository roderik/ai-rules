# TanStack Router Reference

## Overview

TanStack Router is a comprehensive routing library for React applications with 100% inferred TypeScript support and complete type safety across navigation, route parameters, and search params.

## Key Strengths

- **Type Safety**: Full TypeScript inference across the entire routing system
- **Search Params Management**: Treats URL parameters as a powerful first-class state manager with JSON serialization and validation support
- **Performance**: Built-in stale-while-revalidate caching with dependency-based invalidation
- **Developer Experience**: Both file-based and code-based routing options

## Installation

Main package plus Vite plugin configuration for file-based routing with automatic type generation.

## Route Creation Methods

### File-Based Routes (`createFileRoute`)

Define routes through the filesystem with automatic path inference. Routes support:
- Loaders for server-side data fetching with caching
- Search parameter validation and typing
- Error boundaries
- Cache time configuration (stale and garbage collection times)

### Root Routes

`createRootRoute` establishes the top-level application layout, while `createRootRouteWithContext` enables typed dependency injection across all child routes through a context object.

## Navigation Components & Hooks

**Link Component**: Type-safe navigation with preloading, active state management, and parameter inference.

**useNavigate Hook**: Programmatic navigation with full parameter type checking and relative path support.

**useParams Hook**: Access route parameters with strict typing based on route definition.

**useSearch Hook**: Retrieve validated search parameters using schema validators (Zod, Valibot, ArkType supported).

**useLoaderData Hook**: Access route loader data with automatic type inference and optional selection for performance optimization.

## Advanced Features

### beforeLoad Option

Middleware function executing before route loading, enabling:
- Authentication checks with redirects
- Role-based authorization
- Data preloading

### validateSearch Option

Schema-based search parameter validation supporting multiple validation libraries with automatic type generation.

### loaderDeps Option

Specifies which search parameters or other values trigger loader re-execution, enabling cache key generation for dependency-based updates.

### redirect Function

Throws redirects from `beforeLoad` or loaders to navigate conditionally based on authentication, authorization, or data state.

## Layout & Organization

**Outlet Component**: Renders child routes within parent layout components.

**Pathless Routes**: Using underscore prefixes (`_authenticated`) creates layout wrappers without affecting URL structure.

**File Structure Conventions**:
- `$param` for dynamic segments
- `{-$param}` for optional parameters
- `_layout` for pathless routes
- `(group)` for route grouping

## State & Context

**Router Instance**: `useRouter` hook provides access to the router for manual navigation, invalidation, preloading, and state inspection.

**Location Information**: `useLocation` hook returns current pathname, search, hash, state, and full URL.

**Route Matching**: `useMatchRoute` checks if routes are currently matched for conditional rendering.

## Data Fetching Integration

Full integration with TanStack Query through:
- Query option definitions within loaders
- Suspense-based data loading
- Automatic invalidation on mutations
- Prefetching on hover

## Routing Approaches

**File-Based**: Filesystem-driven routing with automatic type generation through build plugins.

**Code-Based**: Programmatic route creation using `createRoute` and `createRouter` for maximum control.

Both approaches maintain identical type safety and feature parity.

## Router Configuration

The router instance accepts:
- Route tree definition
- Default preload behavior ("intent" recommended)
- Scroll restoration settings
- Global stale and cache time defaults
- Root context object
- 404 component

Module augmentation with TypeScript registers the router for proper type inference throughout the application.

## Summary

TanStack Router treats the URL as a first-class data source with comprehensive type system, caching strategies, and developer-friendly APIs for applications requiring sophisticated navigation patterns, authentication flows, and state management without separate store solutions.
