# TanStack Virtual Reference

## Overview
TanStack Virtual is a headless virtualization library that optimizes rendering performance for large datasets across multiple JavaScript frameworks (React, Vue, Svelte, Angular, Lit, Solid).

## Core Concept
Implements virtual scrolling by rendering only visible items in the viewport. Each element's exact dimensions are unknown when rendered. An estimated dimension is used as the initial measurement, then this measurement is readjusted on the fly as each element is rendered.

## Installation Options

**Framework-Agnostic Core:**
```bash
npm install @tanstack/virtual-core
```

**Framework-Specific Adapters:**
- React: `@tanstack/react-virtual`
- Vue: `@tanstack/vue-virtual`
- Svelte: `@tanstack/svelte-virtual`
- Angular: `@tanstack/angular-virtual`
- Lit: `@tanstack/lit-virtual`
- Solid: `@tanstack/solid-virtual`

## Key Features

### Sizing Options
1. **Fixed** - All elements have identical, unchanging dimensions
2. **Variable** - Elements have unique but predetermined sizes
3. **Dynamic** - Element dimensions are unknown until rendered

### Virtualization Types
- Row virtualization (vertical scrolling)
- Column virtualization (horizontal scrolling)
- Grid virtualization (both axes)
- Sticky headers support

### Advanced Capabilities
- Window-level scrolling
- Padding at scroll boundaries
- Custom overscan settings
- Sorting and filtering integration

## Framework Integration Examples

**React** pairs with `useVirtualizer` hook and integrates with TanStack Table for virtualized data grids.

**Vue** uses `useVirtualizer` composition API with sticky positioning support.

**Angular** employs `injectVirtualizer` with signal-based state management.

**Svelte** leverages reactive stores and component composition.

**Lit** utilizes `VirtualizerController` for web component integration.

## Common Configuration

Standard virtualizer setup requires:
- Item count
- Estimated item size
- Scroll container reference
- Overscan buffer (default: 20 items)

The library provides `getTotalSize()`, `getVirtualItems()`, and `getScrollElement()` methods for DOM manipulation and performance optimization.
