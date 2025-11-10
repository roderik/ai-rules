# TanStack Form Reference

## Overview

TanStack Form is a headless, framework-agnostic form library for managing complex form state with full control over fields, validation, and workflows. Emphasizes type safety and works across React, Vue, Angular, Solid, Svelte, and Lit.

## Core Architecture

**Framework-agnostic core** (`@tanstack/form-core`): Handles form state management logic
**Framework adapters**: Provide idiomatic integrations for specific UI frameworks

## Primary APIs

### FormApi
Manages overall form state, field registration, validation coordination, and submission workflows. Supports programmatic updates like `setFieldValue()`, `reset()`, and `handleSubmit()`.

### FieldApi
Handles individual field state including values, errors, touched status, and validation rules. Maintains separate tracks for synchronous and asynchronous validation.

### Framework-Specific Hooks
- **React**: `useForm` hook with integrated Field components
- **Vue**: Composable following Composition API patterns
- **Angular**: `injectForm` dependency injection with standalone directives

## Validation Features

- Synchronous and asynchronous validation with debouncing
- Schema-based validation (Zod, Valibot, ArkType, Yup integration)
- Form-level and field-level validation rules
- Custom validator functions
- Dynamic field validation and cross-field dependencies

## Advanced Capabilities

- Array field management with add/remove/reorder operations
- Nested object field support
- Optimistic updates during submission
- Error recovery workflows
- Real-time validation with configurable debouncing

## Key Use Cases

Multi-step wizards, dynamic form builders with runtime field generation, data-heavy admin interfaces, and validation-intensive systems combining client-side schema validation with server-side async verification.
