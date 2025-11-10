# TanStack DB Reference

## Overview

TanStack DB is a reactive client store for building high-performance applications with real-time data synchronization. Extends TanStack Query capabilities by adding collections, live queries, and transactional mutations to enable instant user interface feedback while preserving server state consistency.

## Core Performance Features

Uses differential dataflow via d2ts for rapid query updates, typically under 1ms even for complex operations. Supports multiple backend integrations including REST APIs through TanStack Query, real-time synchronization via ElectricSQL and TrailBase, local persistence with RxDB, and browser storage collections.

## Framework Support

Framework-agnostic architecture with dedicated packages for React, Vue, Solid, Svelte, and Angular, plus vanilla JavaScript support.

## Collection Types

1. **Query Collections** — Load data using TanStack Query with custom mutation handlers
2. **ElectricSQL Collections** — Real-time PostgreSQL synchronization
3. **LocalStorage Collections** — Persistent browser storage with cross-tab synchronization
4. **LocalOnly Collections** — In-memory state for temporary UI needs
5. **Derived Collections** — Materialized views from live queries

## Query Capabilities

Live queries support:
- Filtering
- Ordering
- Joining multiple collections
- Grouping with aggregations (count, sum, average, min, max)
- Limit operations

## Mutation Patterns

- Optimistic updates that instantly reflect changes while server requests persist
- Custom reusable actions with validation
- Manual transaction control
- Configurable optimistic behavior for critical operations requiring server confirmation first

## Key Architectural Benefit

The framework-agnostic core works with React, Vue, Solid, Svelte, and Angular, providing a unified data layer that decouples data loading from UI components.
