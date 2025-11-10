# Bun Runtime Guide

This guide provides Bun-specific recommendations for TypeScript projects. Only apply these recommendations after detecting that the project uses Bun.

## Detecting Bun Usage

Before applying Bun-specific recommendations, check the project for Bun indicators:

### Primary Indicators (Strong Evidence)

1. **`bun.lockb` file exists** - Bun's binary lockfile (strongest indicator)
2. **`bunfig.toml` exists** - Bun configuration file
3. **`package.json` has `"bun"` field** - Bun-specific metadata
4. **`package.json` scripts use `bun`** - Check for `"test": "bun test"`, `"start": "bun run"`, etc.

### Secondary Indicators (Supporting Evidence)

5. **Dockerfile uses `oven/bun` image** - Check for `FROM oven/bun` or similar
6. **`.tool-versions` specifies bun** - Check for `bun x.y.z`
7. **CI/CD files reference bun** - Look in `.github/workflows/*.yml`, `.gitlab-ci.yml`, etc.
8. **Dependencies use `bun-types`** - Check `package.json` for `"bun-types"`
9. **Test files import from `bun:test`** - Search for `from "bun:test"` in test files

### Detection Strategy

To determine if a project uses Bun:

```bash
# Check for strong indicators (any one is sufficient)
test -f bun.lockb && echo "Bun project detected (lockfile)"
test -f bunfig.toml && echo "Bun project detected (config)"
grep -q '"bun":' package.json && echo "Bun project detected (package.json)"
grep -q 'bun test\|bun run' package.json && echo "Bun project detected (scripts)"

# Check for supporting evidence
grep -q 'FROM oven/bun' Dockerfile && echo "Bun in Docker"
grep -q 'bun:test' **/*.test.ts && echo "Bun test imports found"
```

### Decision Rules

- **Strong Bun project**: If `bun.lockb` exists OR `bunfig.toml` exists → Apply all Bun recommendations
- **Likely Bun project**: If 2+ secondary indicators → Apply Bun recommendations with caution
- **Not a Bun project**: If only `node_modules` and `package-lock.json`/`yarn.lock`/`pnpm-lock.yaml` → Use Node.js/npm tooling
- **Mixed project**: If both `bun.lockb` and `package-lock.json` exist → Ask user which runtime to target

## Bun-Specific Recommendations

Apply these recommendations only after confirming the project uses Bun.

### Package Manager & Runtime

```bash
# Use Bun instead of Node.js
bun <file>                    # instead of: node <file> or ts-node <file>
bun install                   # instead of: npm install, yarn install, pnpm install
bun add <package>             # instead of: npm install <package>
bun remove <package>          # instead of: npm uninstall <package>
bun run <script>              # instead of: npm run <script>, yarn run <script>
```

### Building & Bundling

```bash
# Use Bun's built-in bundler
bun build <file.html|file.ts|file.css>

# Don't use these in Bun projects:
# - webpack
# - esbuild (Bun uses esbuild internally but provides simpler API)
# - vite (Bun has built-in HMR and dev server)
```

### Testing

Use `bun test` instead of Jest, Vitest, or other test runners:

```typescript
// Import from bun:test
import { test, expect, describe, beforeAll, afterAll } from "bun:test";

test("example test", () => {
  expect(1 + 1).toBe(2);
});

describe("test suite", () => {
  beforeAll(() => {
    // Setup
  });

  test("nested test", () => {
    expect(true).toBe(true);
  });

  afterAll(() => {
    // Teardown
  });
});
```

**Run tests:**
```bash
bun test                      # Run all tests
bun test path/to/file.test.ts # Run specific test file
bun test --watch              # Watch mode
```

### Environment Variables

Bun automatically loads `.env` files - don't use `dotenv` package:

```typescript
// ❌ Don't use dotenv in Bun projects
// import 'dotenv/config';

// ✅ Just access process.env directly
const apiKey = process.env.API_KEY;

// Or use Bun.env (same as process.env)
const dbUrl = Bun.env.DATABASE_URL;
```

### File System Operations

Prefer `Bun.file` over Node.js `fs` module for better performance:

```typescript
// ✅ Bun way (faster, simpler)
const file = Bun.file("path/to/file.txt");
const contents = await file.text();
const json = await Bun.file("data.json").json();

// Writing files
await Bun.write("output.txt", "Hello, world!");
await Bun.write("data.json", JSON.stringify({ foo: "bar" }));

// ❌ Node.js way (still works, but slower)
import { readFile, writeFile } from "node:fs/promises";
const contents = await readFile("path/to/file.txt", "utf-8");
```

### Server & HTTP

Use `Bun.serve()` instead of Express, Fastify, etc:

```typescript
// ✅ Bun way - built-in server with routing, WebSockets, HTTPS
Bun.serve({
  port: 3000,
  routes: {
    "/": {
      GET: () => new Response("Hello, world!")
    },
    "/api/users/:id": {
      GET: (req) => {
        return Response.json({ id: req.params.id });
      },
      POST: async (req) => {
        const body = await req.json();
        return Response.json({ created: true, ...body });
      }
    }
  },
  websocket: {
    open(ws) {
      ws.send("Connected!");
    },
    message(ws, message) {
      ws.send(`Echo: ${message}`);
    },
    close(ws) {
      console.log("Connection closed");
    }
  },
  development: {
    hmr: true,      // Hot module reloading
    console: true   // Console output
  }
});

// ❌ Express way (still works, but not idiomatic)
// import express from 'express';
// const app = express();
```

### Database Operations

Use Bun's built-in database modules:

```typescript
// SQLite - use bun:sqlite
import { Database } from "bun:sqlite";

const db = new Database("mydb.sqlite");
const query = db.query("SELECT * FROM users WHERE id = ?");
const user = query.get(1);

// ❌ Don't use: better-sqlite3, sqlite3

// PostgreSQL - use Bun.sql
import { sql } from "bun";

const users = await sql`SELECT * FROM users WHERE id = ${userId}`;

// ❌ Don't use: pg, postgres.js

// Redis - use Bun.redis
// Note: Check Bun version for Redis support availability
// ❌ Don't use: ioredis, redis
```

### WebSockets

Use built-in `WebSocket` instead of `ws` package:

```typescript
// ✅ Bun way - built-in WebSocket
const ws = new WebSocket("ws://localhost:3000");

ws.addEventListener("open", () => {
  ws.send("Hello!");
});

ws.addEventListener("message", (event) => {
  console.log("Received:", event.data);
});

// ❌ Don't use: ws package
// import WebSocket from 'ws';
```

### Shell Commands

Use `Bun.$` for shell commands instead of execa:

```typescript
// ✅ Bun way
import { $ } from "bun";

const output = await $`ls -la`.text();
const exitCode = await $`npm run build`.exitCode();

// Pipe commands
await $`cat file.txt | grep "pattern"`;

// ❌ Don't use: execa, child_process
// import { execa } from 'execa';
```

## Frontend Development with Bun

Bun has built-in support for frontend development - no need for Vite or Webpack.

### HTML Imports

Bun can import HTML files directly and serve them with automatic bundling:

```typescript
// server.ts
import index from "./index.html";

Bun.serve({
  routes: {
    "/": index,  // Automatically serves HTML with bundled assets
  },
  development: {
    hmr: true,    // Hot module reloading for React, CSS, etc.
    console: true
  }
});
```

### HTML File with React

HTML files can import `.tsx`, `.jsx`, or `.js` files directly:

```html
<!-- index.html -->
<html>
  <head>
    <title>My App</title>
    <!-- Bun bundles CSS automatically -->
    <link rel="stylesheet" href="./styles.css">
  </head>
  <body>
    <div id="root"></div>
    <!-- Bun transpiles and bundles automatically -->
    <script type="module" src="./app.tsx"></script>
  </body>
</html>
```

```typescript
// app.tsx
import React from "react";
import { createRoot } from "react-dom/client";

// CSS imports work automatically
import "./app.css";

function App() {
  return <h1>Hello from Bun!</h1>;
}

const root = createRoot(document.getElementById("root")!);
root.render(<App />);
```

### Running the Dev Server

```bash
bun --hot ./server.ts   # HMR for frontend changes
```

### Tailwind CSS

Bun automatically processes Tailwind CSS:

```html
<!-- index.html -->
<html>
  <head>
    <!-- Bun processes Tailwind directives automatically -->
    <link rel="stylesheet" href="./styles.css">
  </head>
  <body>
    <div class="bg-blue-500 text-white p-4">
      Tailwind works!
    </div>
  </body>
</html>
```

```css
/* styles.css */
@tailwind base;
@tailwind components;
@tailwind utilities;
```

## When NOT to Use Bun APIs

Even in Bun projects, sometimes Node.js APIs are more appropriate:

1. **Library code** - If building a library that should work in Node.js, use Node.js APIs
2. **Shared code** - Code that runs in both Bun and Node.js environments
3. **Third-party compatibility** - When integrating with tools that expect Node.js APIs
4. **Ecosystem constraints** - Some packages may not work with Bun APIs yet

In these cases, use Node.js APIs and let Bun handle compatibility:

```typescript
// Library code - use Node.js APIs for compatibility
import { readFile } from "node:fs/promises";
import { createServer } from "node:http";

// App code in a Bun project - use Bun APIs
import { file } from "bun";
```

## Bun Type Definitions

Bun provides TypeScript definitions via `bun-types`:

```json
// package.json
{
  "devDependencies": {
    "bun-types": "latest"
  }
}
```

```json
// tsconfig.json
{
  "compilerOptions": {
    "types": ["bun-types"]
  }
}
```

This provides types for:
- `Bun.serve()`
- `Bun.file()`
- `Bun.$`
- `bun:test`
- `bun:sqlite`
- All Bun-specific APIs

## Additional Resources

For more detailed information:
- Official docs: https://bun.sh/docs
- API reference: Check `node_modules/bun-types/docs/**.md` in your project
- GitHub: https://github.com/oven-sh/bun

## Migration Checklist

When migrating to or working with a Bun project:

- [ ] Verify `bun.lockb` exists or run `bun install` to generate it
- [ ] Update scripts in `package.json` to use `bun` commands
- [ ] Replace test imports with `bun:test`
- [ ] Remove `dotenv` package and imports
- [ ] Replace `express`/`fastify` with `Bun.serve()` if building new features
- [ ] Replace `fs` operations with `Bun.file()` for performance
- [ ] Add `bun-types` to devDependencies
- [ ] Update `tsconfig.json` to include `bun-types`
- [ ] Update CI/CD to use Bun instead of Node.js
- [ ] Update Dockerfile to use `oven/bun` base image
