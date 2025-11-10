# TanStack Store Reference

## Overview

TanStack Store is a signals-based reactive state management library that works across frameworks. Provides a framework-agnostic reactive state management library with adapters for React, Vue, Angular, Solid, and Svelte.

## Core Primitives

1. **Store** - Reactive containers that hold application state with `setState()` for updates and `subscribe()` for tracking changes

2. **Derived** - Computed values that automatically recalculate when dependencies change, supporting lazy evaluation and previous value tracking

3. **Effect** - Side effect management with dependency tracking and lifecycle hooks

4. **Batch** - Optimization utility that triggers only 1 update when multiple state changes occur within a batch function

## Installation

Install the core package plus framework-specific adapters:
```
@tanstack/store (core)
@tanstack/react-store | @tanstack/vue-store | @tanstack/angular-store | @tanstack/solid-store | @tanstack/svelte-store
```

## Framework Integration

Each framework gets a dedicated hook/composable:
- React: `useStore` hook
- Vue: `useStore` composable
- Angular: `injectStore` function
- Solid: `useStore` returning signals
- Svelte: `useStore` with rune support

## Key Features

- **Selective subscriptions** - Components only re-render when their specific state slice changes
- **Explicit lifecycle management** - Requires mounting/unmounting for cleanup
- **Customizable Store behavior** - Optional `updateFn`, `onUpdate`, and `onSubscribe` hooks
- **Dependency tracking** - Derived and Effect primitives access previous values through context

## Design Philosophy

TanStack Store offers a lightweight and flexible solution emphasizing explicit control over reactivity with minimal boilerplate across all supported frameworks.
