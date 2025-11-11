---
name: rr-typescript
description: Guidance for writing TypeScript code following Ultracite code quality standards. Use when writing or reviewing TypeScript/JavaScript code, implementing type-safe patterns, working with advanced types (generics, conditional types, mapped types), or ensuring code quality and accessibility. Also triggers when working with TypeScript files (.ts, .tsx), JavaScript files (.js, .jsx), tsconfig.json, or when reviewing code quality. Example triggers: "Write TypeScript code", "Fix type errors", "Review code quality", "Implement type-safe patterns", "Add type definitions", "Refactor to TypeScript", "Check accessibility", "Run Ultracite"
---

# TypeScript with Ultracite Standards

## Overview

This skill provides comprehensive guidance for writing high-quality TypeScript code following Ultracite standards—a zero-config Biome preset that enforces strict code quality through automated formatting and linting. Apply this skill when writing, reviewing, or refactoring TypeScript/JavaScript code to ensure accessibility, type safety, performance, and maintainability.

## When to Use This Skill

Use this skill when:

- Writing new TypeScript/JavaScript code
- Reviewing or refactoring existing code
- Implementing type-safe patterns (generics, conditional types, mapped types, etc.)
- Building React components with proper accessibility
- Debugging type errors or improving type inference
- Ensuring code follows best practices for security and performance
- Setting up TypeScript projects with proper configuration
- Working with complex type logic or building type utilities

## Quick Reference

### Ultracite Commands

Run these commands to maintain code quality:

```bash
bunx ultracite fix      # Format code and fix auto-fixable issues
bunx ultracite check    # Check for issues without fixing
bunx ultracite doctor   # Diagnose setup problems
```

Biome (the underlying engine) provides extremely fast Rust-based linting and formatting. Most issues are automatically fixable.

### Code Style Configuration

```json
{
  "formatter": {
    "indentStyle": "space",
    "indentWidth": 2,
    "lineWidth": 120,
    "enabled": true
  }
}
```

## Runtime Detection

Before making runtime-specific recommendations (Bun vs Node.js), detect which runtime the project uses:

### Check for Bun Project

Look for these indicators (in order of strength):

1. **`bun.lockb`** exists → Strong indicator (Bun's lockfile)
2. **`bunfig.toml`** exists → Bun configuration
3. **`package.json`** has `"bun"` field or scripts use `bun` commands
4. **Test files** import from `"bun:test"`
5. **Dockerfile** uses `FROM oven/bun`

**Decision rules:**
- If `bun.lockb` OR `bunfig.toml` exists → Apply Bun-specific recommendations (see `references/bun-runtime.md`)
- If only `package-lock.json`/`yarn.lock`/`pnpm-lock.yaml` exists → Use standard Node.js/npm tooling
- If both exist → Ask user which runtime to target

**When Bun detected:** Load `references/bun-runtime.md` for Bun-specific APIs, tooling, testing patterns, and migration guidance.

## Test Framework Detection

Before applying testing patterns, detect which test framework the project uses:

### Check for Vitest

Look for these indicators (in order of strength):

1. **`vitest.config.ts` or `vitest.config.js`** exists → Vitest configuration (strongest indicator)
2. **`package.json` has `vitest` in devDependencies** → Check for `"vitest": "..."`
3. **`package.json` scripts use `vitest`** → Check for `"test": "vitest"`, etc.
4. **Test files import from `vitest`** → Search for `from "vitest"` in test files
5. **`vite.config.ts` has `test` configuration** → Vite config with test settings

**Decision rules:**
- If `vitest.config.ts`/`vitest.config.js` exists OR `vitest` in devDependencies → Apply Vitest patterns (see `references/vitest-testing.md`)
- If `jest.config.js`/`jest.config.ts` exists OR `@types/jest` in devDependencies → Use Jest patterns instead
- If both exist → Ask user which to prioritize
- If using Bun → Prefer `bun:test` (see `references/bun-runtime.md` for testing)

**When Vitest detected:** Load `references/vitest-testing.md` for comprehensive testing patterns including unit tests, integration tests, mocking, fixtures, and React/frontend testing.

## Core Principles

Follow these fundamental principles when writing TypeScript code:

### 1. Type Safety & Explicitness

- Use explicit types for function parameters and return values when they enhance clarity
- Prefer `unknown` over `any` when the type is genuinely unknown
- Use const assertions (`as const`) for immutable values and literal types
- Leverage TypeScript's type narrowing instead of type assertions
- Extract magic numbers into descriptive constants

### 2. Modern JavaScript/TypeScript

- Use arrow functions for callbacks and short functions
- Prefer `for...of` loops over `.forEach()` and indexed `for` loops
- Use optional chaining (`?.`) and nullish coalescing (`??`) for safer property access
- Prefer template literals over string concatenation
- Use destructuring for object and array assignments
- Use `const` by default, `let` only when reassignment is needed, never `var`

### 3. Async & Promises

- Always `await` promises in async functions - don't forget to use the return value
- Use `async/await` syntax instead of promise chains for better readability
- Handle errors appropriately in async code with try-catch blocks
- Don't use async functions as Promise executors

### 4. React & JSX

- Use function components over class components
- Call hooks at the top level only, never conditionally
- Specify all dependencies in hook dependency arrays correctly
- Use the `key` prop for elements in iterables (prefer unique IDs over array indices)
- Nest children between opening and closing tags instead of passing as props
- Don't define components inside other components

### 5. Accessibility

- Use semantic HTML elements (`<button>`, `<nav>`, `<main>`, etc.) instead of divs with roles
- Provide meaningful alt text for images
- Use proper heading hierarchy
- Add labels for form inputs
- Include keyboard event handlers alongside mouse events
- Ensure proper focus management and tab order

### 6. Code Organization

- Keep functions focused and under reasonable cognitive complexity limits
- Extract complex conditions into well-named boolean variables
- Use early returns to reduce nesting
- Prefer simple conditionals over nested ternary operators
- Group related code together and separate concerns

## Working with Advanced Types

For complex type patterns and advanced TypeScript features, refer to the **Advanced Types Reference** in `references/advanced-types.md`.

This reference includes:

- **Generics**: Creating reusable, type-flexible components
- **Conditional Types**: Type logic based on conditions
- **Mapped Types**: Transforming existing types
- **Template Literal Types**: String-based type patterns
- **Utility Types**: Built-in and custom type utilities
- **Advanced Patterns**: Type-safe event emitters, API clients, builders, form validation, state machines
- **Type Inference**: Using `infer`, type guards, and assertion functions
- **Type Testing**: Verifying type behavior

Load this reference when implementing complex type logic or building reusable type utilities.

## Code Quality Standards

For detailed code quality standards covering accessibility, complexity, correctness, security, and testing, refer to the **Ultracite Standards Reference** in `references/ultracite-standards.md`.

This reference includes comprehensive guidance on:

- **Accessibility (a11y)**: Semantics, focus management, ARIA, keyboard support
- **Code Complexity**: Control flow, APIs, idioms, performance
- **React & JSX**: Hooks, components, events, best practices
- **Correctness & Safety**: Control flow, promises, types, security
- **TypeScript Best Practices**: Type system usage, classes, strictness
- **Style & Consistency**: Formatting conventions, naming, operations
- **Testing**: Test structure, async testing, assertions

Load this reference when performing code reviews, implementing new features, or enforcing quality standards.

## Workflow

### Writing New Code

1. **Start with types**: Define interfaces and types before implementation
2. **Use inference**: Let TypeScript infer types when obvious
3. **Build incrementally**: Write small, testable functions
4. **Run Ultracite**: Use `bunx ultracite fix` to format and catch issues
5. **Validate types**: Ensure no `any` types leak into your code

### Reviewing Code

1. **Check accessibility**: Verify semantic HTML, ARIA, and keyboard support
2. **Verify type safety**: Look for `any`, missing types, or type assertions
3. **Assess complexity**: Ensure functions are focused and maintainable
4. **Review security**: Check for XSS, injection vulnerabilities, and secrets
5. **Run checks**: Use `bunx ultracite check` to verify compliance

### Refactoring

1. **Preserve behavior**: Use tests to verify unchanged functionality
2. **Improve types**: Replace `any` with proper types, add generics
3. **Simplify logic**: Extract functions, reduce nesting, use early returns
4. **Enhance accessibility**: Add semantic HTML and ARIA where needed
5. **Validate changes**: Run `bunx ultracite fix` and verify tests pass

## Common Pitfalls to Avoid

1. **Over-using `any`**: Defeats TypeScript's purpose
2. **Ignoring accessibility**: Missing semantic HTML, labels, or keyboard support
3. **Complex nested logic**: Hard to read and maintain
4. **Missing error handling**: Unhandled promises or exceptions
5. **Console statements**: Remove `console.log`, `debugger`, and `alert` from production
6. **Type assertions**: Prefer type guards and proper narrowing
7. **Mutating parameters**: Create new values instead of modifying inputs

## Best Practices

1. **Run Ultracite before committing**: Catch issues early with `bunx ultracite fix`
2. **Write self-documenting code**: Use descriptive names over comments
3. **Test edge cases**: Handle null, undefined, empty arrays, and boundary conditions
4. **Use strict mode**: Enable all strict TypeScript compiler options
5. **Prefer composition**: Build complex logic from small, focused functions
6. **Document complex types**: Add JSDoc comments for non-obvious type logic
7. **Keep it simple**: Choose clarity over cleverness

## Resources

This skill includes four comprehensive reference documents:

### references/advanced-types.md

Detailed guide to TypeScript's advanced type system, including generics, conditional types, mapped types, template literal types, utility types, and advanced patterns like type-safe event emitters, API clients, and form validators.

Load this reference when:
- Implementing complex type logic
- Building reusable generic components
- Creating type utilities
- Working with conditional or mapped types
- Debugging type inference issues

### references/ultracite-standards.md

Complete code quality standards covering accessibility, code complexity, React/JSX patterns, correctness, security, TypeScript best practices, style consistency, and testing guidelines.

Load this reference when:
- Performing code reviews
- Writing new features or components
- Refactoring existing code
- Ensuring accessibility compliance
- Implementing security best practices
- Setting up testing standards

### references/bun-runtime.md

Comprehensive guide for Bun-specific development including runtime detection, Bun APIs, testing with `bun:test`, file operations, server setup with `Bun.serve()`, database modules, and frontend development without bundlers.

**Only load this reference when:**
- **`bun.lockb`** file exists in the project
- **`bunfig.toml`** file exists in the project
- Project uses Bun-specific APIs or testing
- Setting up or migrating to Bun runtime
- Working with Bun's built-in server, database, or file APIs

**Do not load if:**
- Only `package-lock.json`, `yarn.lock`, or `pnpm-lock.yaml` exists
- Project uses standard Node.js runtime
- No Bun indicators detected

### references/vitest-testing.md

Comprehensive testing guide covering Vitest setup, unit tests, integration tests, mocking patterns, dependency injection, frontend testing with Testing Library, test fixtures, snapshot testing, and Vitest-specific features like in-source testing, benchmarking, and type testing.

**Only load this reference when:**
- **`vitest.config.ts` or `vitest.config.js`** exists in the project
- **`vitest`** is in `package.json` devDependencies
- Test files import from `"vitest"`
- Setting up or writing tests with Vitest
- Working with React/frontend component testing
- Implementing mocking or integration tests

**Do not load if:**
- Project uses Jest (`jest.config.js`, `@types/jest`)
- Project uses Bun testing (`bun:test` imports) - use `bun-runtime.md` instead
- No test framework detected
