# TanStack Table Reference

## Overview
TanStack Table is a headless UI library for building powerful tables and datagrids in TypeScript/JavaScript applications. Delivers data processing logic without prescribing UI structure, enabling complete control over appearance while leveraging sophisticated functionality for sorting, filtering, pagination, and grouping.

## Framework Support
React, Vue, Solid, Svelte, Qwik, Angular, Lit, and vanilla JavaScript.

## Installation
Framework-specific packages:
- React: `@tanstack/react-table`
- Vue: `@tanstack/vue-table`
- Solid: `@tanstack/solid-table`
- Svelte: `@tanstack/svelte-table`
- Angular: `@tanstack/angular-table`
- Qwik: `@tanstack/qwik-table`
- Lit: `@tanstack/lit-table`
- Vanilla JS: `@tanstack/table-core`

## Core Features

### Column Definitions
Columns use accessor functions to transform or compute values from row data, supporting computed accessors, deep key access, custom rendering, display columns, and grouped columns.

### Sorting
Enable sorting with built-in or custom sort functions. Built-in options include alphanumeric, text, and datetime functions. Multi-column sorting is configurable via `enableMultiSort`.

### Filtering
Built-in filter functions: includesString, equalsString, arrIncludes, inNumberRange.

### Pagination
- Client-side pagination with configurable page sizes
- Server-side pagination with backend API integration using manual pagination mode

### Row Selection
Single or multi-row selection with checkboxes, with granular control over which rows can be selected.

### Performance
Capable of processing tens of thousands of rows client-side with excellent performance.

## State Management
State can be controlled externally or initialized internally. Supports controlled state with `useState` hooks and automatic state reset methods like `resetSorting()` and `resetPagination()`.

## Advanced Capabilities
- Server-side filtering and sorting with controlled state
- Custom table metadata for application-specific data and functions
- Row data access through typed objects and cell value methods
- Nested row support with parent-child relationships
- Column visibility toggling

## Use Cases
Admin panels, data dashboards, content management systems, e-commerce product catalogs, and any application requiring sortable, filterable, paginated data displays.
