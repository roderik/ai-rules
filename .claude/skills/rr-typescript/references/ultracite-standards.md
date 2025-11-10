# Ultracite Code Quality Standards

This project uses **Ultracite**, a zero-config Biome preset that enforces strict code quality standards through automated formatting and linting.

## Quick Commands

- **Format code**: `bunx ultracite fix`
- **Check for issues**: `bunx ultracite check`
- **Diagnose setup**: `bunx ultracite doctor`

Biome (the underlying engine) provides extremely fast Rust-based linting and formatting. Most issues are automatically fixable.

## Code Style Configuration

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

## Core Principles

Write code that is **accessible, performant, type-safe, and maintainable**. Focus on clarity and explicit intent over brevity.

### Type Safety & Explicitness

- Use explicit types for function parameters and return values when they enhance clarity
- Prefer `unknown` over `any` when the type is genuinely unknown
- Use const assertions (`as const`) for immutable values and literal types
- Leverage TypeScript's type narrowing instead of type assertions
- Use meaningful variable names instead of magic numbers - extract constants with descriptive names

### Modern JavaScript/TypeScript

- Use arrow functions for callbacks and short functions
- Prefer `for...of` loops over `.forEach()` and indexed `for` loops
- Use optional chaining (`?.`) and nullish coalescing (`??`) for safer property access
- Prefer template literals over string concatenation
- Use destructuring for object and array assignments
- Use `const` by default, `let` only when reassignment is needed, never `var`

### Async & Promises

- Always `await` promises in async functions - don't forget to use the return value
- Use `async/await` syntax instead of promise chains for better readability
- Handle errors appropriately in async code with try-catch blocks
- Don't use async functions as Promise executors

### React & JSX

- Use function components over class components
- Call hooks at the top level only, never conditionally
- Specify all dependencies in hook dependency arrays correctly
- Use the `key` prop for elements in iterables (prefer unique IDs over array indices)
- Nest children between opening and closing tags instead of passing as props
- Don't define components inside other components
- Use semantic HTML and ARIA attributes for accessibility:
  - Provide meaningful alt text for images
  - Use proper heading hierarchy
  - Add labels for form inputs
  - Include keyboard event handlers alongside mouse events
  - Use semantic elements (`<button>`, `<nav>`, etc.) instead of divs with roles

### Error Handling & Debugging

- Remove `console.log`, `debugger`, and `alert` statements from production code
- Throw `Error` objects with descriptive messages, not strings or other values
- Use `try-catch` blocks meaningfully - don't catch errors just to rethrow them
- Prefer early returns over nested conditionals for error cases

### Code Organization

- Keep functions focused and under reasonable cognitive complexity limits
- Extract complex conditions into well-named boolean variables
- Use early returns to reduce nesting
- Prefer simple conditionals over nested ternary operators
- Group related code together and separate concerns

### Security

- Add `rel="noopener"` when using `target="_blank"` on links
- Avoid `dangerouslySetInnerHTML` unless absolutely necessary
- Don't use `eval()` or assign directly to `document.cookie`
- Validate and sanitize user input

### Performance

- Avoid spread syntax in accumulators within loops
- Use top-level regex literals instead of creating them in loops
- Prefer specific imports over namespace imports
- Avoid barrel files (index files that re-export everything)
- Use proper image components (e.g., Next.js `<Image>`) over `<img>` tags

### Framework-Specific Guidance

**React 19+:**

- Use ref as a prop instead of `React.forwardRef`

## Detailed Standards

### A) Accessibility (a11y)

**Semantics first**

- Prefer native semantic elements (`<button>`, `<a>`, `<nav>`, `<main>`, `<table>`, `<th>`, etc.) over adding ARIA
- Only add ARIA when native semantics can't express the widget, and then use **valid, non-abstract roles**, with **all required ARIA attributes** and **valid values**
- Rely on implicit roles by default; specify `role` only when changing semantics
- Use `scope` **only** on `<th>` cells that label rows/columns

**Focus & keyboard**

- Keep DOM order = tab order
- Use `tabIndex={0}` only to make a custom widget focusable, and use `tabIndex={0}` on the composite container when using `aria-activedescendant`
- Avoid positive `tabIndex` values; manage order structurally
- Pair pointer handlers with keyboard: `onClick` → add `onKeyUp`/`onKeyDown` (Space/Enter); `onMouseOver`/`onMouseOut` → add `onFocus`/`onBlur`
- Make any element with interactive behavior focusable and give it an appropriate role, or better, use a native interactive element instead of a div

**Discernible, accurate names**

- Give every control a programmatic name: `<label for>` or `aria-label/aria-labelledby` bound to an `<input>`
- Ensure links have accessible content (text or ARIA label) and a **real** `href`
- Provide meaningful `alt` text for images; describe the content and omit filler words like "image/photo/picture"
- Headings (`<h1>…<h6>`) contain text that is not hidden from assistive tech

**Media & graphics**

- Add caption tracks to `<audio>`/`<video>`
- For inline SVG, include a `<title>` child for a text alternative

**Document & i18n**

- Set `<html lang="…">` using correct BCP-47 codes (e.g., `en`, `en-GB`, `nl-BE`)
- Use valid `autocomplete` values on form controls
- Give `<iframe>` a descriptive `title`

**Roles/props hygiene**

- Only apply ARIA roles/properties/states that the element and role support; validate all `aria-*` attributes
- Ensure explicit `role` is never a redundant repeat of the implicit one

**Buttons & activation**

- Always set `<button type="button|submit|reset">` explicitly
- If you must use a static element with a click handler, add `role="button"`, `tabIndex={0}`, and proper keyboard handlers; otherwise, use `<button>`

**Motion & shortcuts**

- Use CSS animations/transitions that respect `prefers-reduced-motion`
- Keep markup free of obsolete movement tags
- Provide keyboard shortcuts via event handlers rather than `accessKey`

### B) Code Complexity & Quality

**Control flow & structure**

- Keep functions small and below Cognitive Complexity threshold; split long ones
- Prefer `for…of` (or `for (const [i,v] of arr.entries())` when you need the index) and `while` when you only need a condition
- Favor early returns over `else` ladders
- Use arrow functions instead of function expressions
- Keep parameters immutable; create new locals instead of reassigning parameters

**APIs & idioms**

- Use rest parameters `(...args)` instead of the old `arguments` object
- Use `Date.now()` for epoch milliseconds
- Favor `arr.flatMap(fn)` over `arr.map(fn).flat()`
- Access known properties with dot syntax (`obj.key`) rather than computed (`obj['key']`) unless the key is dynamic
- Use optional chaining / nullish coalescing for concise guards (`a?.b ?? fallback`)

**Numbers, strings, and regex**

- Use numeric literals for binary/octal/hex (`0b…`, `0o…`, `0x…`) instead of `parseInt` tricks
- When parsing strings, call `parseInt(str, 10)` or `Number.parseInt(str, 10)` with a radix
- Use numeric separators in long literals (`1_000_000`)
- Prefer template literals over `+` concatenation (and don't use templates when plain strings suffice)
- Prefer **regex literals** over `new RegExp` when static
- Declare reusable regexes at module scope
- Write minimal, valid patterns (no empty classes, no redundant escapes, no backreferences that always match empty)
- Represent whitespace intentionally in regex; don't encode it via mystery sequences

**Types & generics**

- Give generics real constraints (`<T extends Record<string, unknown>>`), not `any/unknown`, and don't create empty type parameters
- Don't build fake "static namespaces" with classes; use modules/objects

**Constructor/error hygiene**

- Keep constructors minimal; don't return values from them
- Throw `new Error('message')` (or a subclass), not plain values
- Always include an error message

**Performance-minded habits**

- Use assignment operator shorthands (`+=`, `||=`, `&&=`, `??=`) when they aid clarity
- Avoid spreading accumulators in tight loops; mutate a local or push to an array and return a new object only when needed

### C) React & JSX

**Hooks & components**

- Call React hooks **only** at the top level of function components and custom hooks
- Provide complete dependency arrays; memoize handlers with `useCallback`/`useMemo` when appropriate
- Define components at module scope, not inside other components
- Treat props as immutable; compute derived state, don't assign to props

**Lists, keys, and children**

- Provide stable, meaningful `key` props (ids, not array indices)
- Pass children between tags, not via a `children` prop value in JSX

**Events & roles**

- Attach event handlers to interactive elements
- If you must use a non-interactive element, give it an appropriate role and keyboard support
- Avoid dangerous props; when `dangerouslySetInnerHTML` is truly necessary, sanitize the input and never combine it with `children`

**JSX hygiene**

- Use fragment shorthand `<> … </>` instead of `<Fragment>`
- Self-close components without children
- Set each JSX prop once
- Keep stray semicolons out of JSX
- Don't insert comments as text nodes

**Cross-framework note**

- In Solid projects, access props via accessors (e.g., `props.title`) rather than destructuring, to retain reactivity

### D) Correctness & Safety

**Sound control flow**

- Remove unreachable code
- Ensure `for`-loop updates move counters the right way
- Keep `finally` for cleanup only, not control flow
- Ensure `switch` statements are exhaustive (use a `never` check or a `default` that throws)

**Promises & async**

- Await or otherwise handle every promise
- Prefer `Promise.all` over `await` inside loops when independent
- Construct promises with synchronous executors; put `async`/`await` logic inside them, not on the executor itself

**Types & runtime checks**

- Compare `typeof` results to valid strings (`"string"`, `"number"`, etc.)
- Use `Number.isNaN` and `Number.isFinite` for checks
- Keep getters and setters adjacent; getters always return a value
- Use `Object.hasOwn(obj, key)` (or its safe equivalent) inside `for…in`

**Imports & modules**

- Use named (or explicit default) imports
- Only use `import` statements, never `require()` (ES modules only)
- Place all imports at the top of the file, not inline within functions
- Avoid namespace/dynamic access to namespace imports
- Break import cycles
- Use `with { type: "json" }` for JSON imports where supported
- Don't mutate built-ins or read-only globals
- Never assign to imported bindings
- Never use dynamic imports (`await import(...)`) unless explicitly required for code splitting

**Security & web hygiene**

- Load Google Fonts with a recommended strategy: `preconnect` to font hosts and a display mode like `display=swap`
- When using `target="_blank"`, include `rel="noopener noreferrer"`
- Keep secrets out of source; inject via environment/secret management
- Use `Response.json()`/`Response.redirect()` where available instead of `new Response(...)`

**Language pitfalls**

- Avoid self-assignment, constant conditions, and value-less expressions
- Separate assignment from comparison
- Treat `document.cookie` via a safe helper (attributes, encoding) rather than writing raw strings
- Prefer `===`/`!==`
- Avoid bitwise operators unless intentionally manipulating bits
- Avoid sparse arrays; use dense arrays or `Map`
- Keep whitespace regular; avoid control characters in regex and strings
- Ensure JSON/regex/string escapes are modern (no octal, no legacy `\8`/`\9` sequences)
- Don't use `void` except as a function return type or generic parameter

**ES modules vs. CommonJS caveats**

- In ESM, emulate `__dirname`/`__filename` with `import.meta.url` + `fileURLToPath`

### E) TypeScript Best Practices

**General**

- Prefer unions of string/number literals (with `as const` objects) over `enum`
- If you must use `enum` in existing code, make all members literal values and set each member explicitly
- Lean on inference: when a variable or property is initialized, omit redundant annotations
- Keep types and values separate: use `export type` / `import type` for types
- Maintain strictness: values must never drift to `any` via reassignment
- Use `unknown` at boundaries and refine with user-defined **type guards** where needed (not non-null assertions)
- Place overload signatures contiguously
- Prefer ES modules; avoid TS "namespaces"
- If forced into legacy code, use the `namespace` keyword (not `module`) and keep it ambient-only

**Classes & fields**

- Declare fields explicitly; assign in the constructor (no parameter properties)
- In subclass constructors, call `super()` exactly once and before using `this`

**Documentation (TSDoc)**

- Use TSDoc-style comments for exported functions, classes, and interfaces
- Document parameters with `@param`, return values with `@returns`, and exceptions with `@throws`
- Include `@example` blocks for complex APIs
- Explain *why* and *when*, not just *what* - describe rationale, trade-offs, and design decisions
- Keep comments synchronized with code changes

**Example TSDoc:**

```typescript
/**
 * Validates user input and sanitizes dangerous characters.
 *
 * Uses allowlist approach for security: only alphanumeric and safe punctuation
 * are permitted. Rejects input containing SQL/XSS patterns.
 *
 * @param input - Raw user input string
 * @param maxLength - Maximum allowed length (default: 255)
 * @returns Sanitized input string
 * @throws {ValidationError} If input contains forbidden patterns or exceeds maxLength
 *
 * @example
 * ```typescript
 * const safe = validateInput("user@example.com", 100);
 * // Returns: "user@example.com"
 *
 * validateInput("<script>alert('xss')</script>");
 * // Throws: ValidationError
 * ```
 */
export function validateInput(input: string, maxLength = 255): string {
  // Implementation
}
```

### F) Style & Consistency

**Core style**

- Use `const` for single-assignment variables; `let` otherwise; never `var`
- Prefer early returns; reduce nesting
- Use `else if` rather than deep `else { if (…) }`
- Follow the project's brace and spacing conventions
- Keep irregular whitespace out
- Use `new` for built-ins that are constructors (e.g., `Date`, `Map`, `Set`) and **not** for `String`, `Number`, or `Boolean`

**Strings & numbers**

- Use `String.slice()` over `substr/substring`
- Use `String.trimStart()` / `String.trimEnd()`
- Prefer template literals over concatenation when interpolating

**Operations & comparisons**

- Use exponent operator `**` over `Math.pow`
- Don't compare against `-0` unless you intentionally use `Object.is(x, -0)`
- Keep logical expressions minimal (drop redundant `&& true`, `|| false`, etc.)

**Objects & arrays**

- Prefer object spread to `Object.assign` when creating new objects
- Use `Array.isArray()` for array checks
- Use `at()` for safe indexing
- Keep object literals consistent and without duplicate keys
- Don't redeclare in the same scope

**Diagnostics**

- Replace `console.*` and `debugger` with the project's logging and debugging facilities

**Switches & errors**

- Put the `default`/exhaustive case last
- Break every case unless intentionally falling through with a comment
- Always construct built-in errors with a message: `new TypeError('…')`

### H) Testing

- Keep tests runnable as a full suite: no focused or skipped tests (`.only`, `.skip`)
- Place assertions (`expect`, etc.) **inside** `it`/`test` blocks
- Use ES module imports in tests
- Keep test files free of exports unless the runner requires them
- Keep `describe` nesting shallow and hooks non-duplicated
- Avoid callback-style async tests—use promises/async-await

## What Biome Can't Help With

Biome's linter will catch most issues automatically. Focus your attention on:

1. **Business logic correctness** - Biome can't validate your algorithms
2. **Meaningful naming** - Use descriptive names for functions, variables, and types
3. **Architecture decisions** - Component structure, data flow, and API design
4. **Edge cases** - Handle boundary conditions and error states
5. **User experience** - Accessibility, performance, and usability considerations
6. **Documentation** - Add comments for complex logic, but prefer self-documenting code

Most formatting and common issues are automatically fixed by Biome. Run `bunx ultracite fix` before committing to ensure compliance.
