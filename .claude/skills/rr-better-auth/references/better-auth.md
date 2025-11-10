# Better Auth Core Documentation

## Overview

Better Auth is a comprehensive authentication framework for TypeScript applications. It provides a complete solution for implementing user authentication with support for multiple authentication methods, database systems, and framework integrations.

## Core Features

### Authentication Methods

- **Email and Password**: Traditional username/password authentication with built-in password hashing and validation
- **OAuth 2.0 Social Providers**: 40+ providers including GitHub, Google, Discord, Microsoft, LinkedIn, Apple, Facebook, Twitter, Spotify, and more
- **Magic Links**: Passwordless authentication via email links
- **Email OTP**: One-time passwords sent via email
- **Passkeys**: WebAuthn/biometric authentication (Face ID, Touch ID, Windows Hello)
- **SAML SSO**: Enterprise single sign-on integration
- **Device Authorization**: OAuth device flow for TVs and IoT devices

### Database Support

Better Auth supports multiple database systems through dedicated adapters:

- PostgreSQL
- MySQL
- SQLite
- MongoDB
- MS SQL
- Prisma ORM (supports all Prisma-compatible databases)

Each adapter handles schema creation, migrations, and query optimization automatically.

### Session & Security

- **Cookie-based Sessions**: Secure, HTTP-only cookies with configurable expiration
- **Session Management**: Active session tracking, revocation, and refresh
- **Rate Limiting**: Built-in protection against brute force attacks
- **Password Security**: Integration with "Have I Been Pwned" API to check for compromised passwords
- **TypeScript Type Safety**: Full type inference for authentication state and user data
- **CSRF Protection**: Built-in cross-site request forgery protection

## Installation & Setup

### Basic Installation

```bash
bun add better-auth
```

### Database Adapter Installation

Install the appropriate adapter for your database:

```bash
# PostgreSQL
bun add @better-auth/pg

# Prisma
bun add @better-auth/prisma

# MongoDB
bun add @better-auth/mongodb
```

### Basic Configuration

Create an authentication instance with configuration:

```typescript
import { betterAuth } from "better-auth"
import { pg } from "@better-auth/pg"

export const auth = betterAuth({
  database: pg({
    connectionString: process.env.DATABASE_URL
  }),
  emailAndPassword: {
    enabled: true,
    requireEmailVerification: true
  },
  socialProviders: {
    github: {
      clientId: process.env.GITHUB_CLIENT_ID,
      clientSecret: process.env.GITHUB_CLIENT_SECRET
    },
    google: {
      clientId: process.env.GOOGLE_CLIENT_ID,
      clientSecret: process.env.GOOGLE_CLIENT_SECRET
    }
  }
})
```

## Plugin Ecosystem

Better Auth provides an extensive plugin system for additional functionality:

### Core Plugins

#### Two-Factor Authentication (2FA)

```typescript
import { twoFactor } from "better-auth/plugins"

export const auth = betterAuth({
  plugins: [
    twoFactor({
      issuer: "Your App Name",
      otpOptions: {
        period: 30
      }
    })
  ]
})
```

#### Multi-Session

Support concurrent sessions across multiple devices:

```typescript
import { multiSession } from "better-auth/plugins"

export const auth = betterAuth({
  plugins: [
    multiSession({
      maximumSessions: 5
    })
  ]
})
```

#### Organization/Team Management

Multi-tenant organization support with role-based access control:

```typescript
import { organization } from "better-auth/plugins"

export const auth = betterAuth({
  plugins: [
    organization({
      roles: {
        owner: { permissions: ["*"] },
        admin: { permissions: ["manage_members", "manage_settings"] },
        member: { permissions: ["read"] }
      }
    })
  ]
})
```

#### API Key Authentication

Generate and validate API keys for programmatic access:

```typescript
import { apiKey } from "better-auth/plugins"

export const auth = betterAuth({
  plugins: [
    apiKey({
      prefix: "sk_",
      expiresIn: 30 // days
    })
  ]
})
```

#### JWT Support

Use JWTs for non-browser services:

```typescript
import { jwt } from "better-auth/plugins"

export const auth = betterAuth({
  plugins: [
    jwt({
      secret: process.env.JWT_SECRET,
      expiresIn: "7d"
    })
  ]
})
```

### Payment & Integration Plugins

- **Stripe Integration**: Connect authentication with Stripe customers
- **Polar Integration**: Payment provider integration
- **Admin Panel**: Built-in admin dashboard for user management
- **Anonymous Users**: Support for guest/anonymous sessions

## Framework Integration

Better Auth provides native adapters for popular frameworks:

### Next.js

```typescript
// app/api/auth/[...all]/route.ts
import { auth } from "@/lib/auth"
import { toNextJsHandler } from "better-auth/next-js"

export const { GET, POST } = toNextJsHandler(auth)
```

Client-side setup:

```typescript
import { createAuthClient } from "better-auth/react"

export const authClient = createAuthClient({
  baseURL: process.env.NEXT_PUBLIC_APP_URL
})
```

### SvelteKit

```typescript
// src/hooks.server.ts
import { auth } from "$lib/auth"
import { svelteKitHandler } from "better-auth/svelte-kit"

export const handle = svelteKitHandler(auth)
```

### Remix

```typescript
// app/routes/api.auth.$.ts
import { auth } from "~/lib/auth"
import { remixHandler } from "better-auth/remix"

export const { loader, action } = remixHandler(auth)
```

### Express/NestJS/Hono/Fastify

Direct integration with Node.js frameworks:

```typescript
import express from "express"
import { auth } from "./auth"

const app = express()

app.use("/api/auth/*", (req, res) => auth.handler(req, res))
```

## Configuration Options

### Email and Password Options

```typescript
emailAndPassword: {
  enabled: true,
  requireEmailVerification: true,
  autoSignIn: false,
  minPasswordLength: 8,
  maxPasswordLength: 128,
  passwordStrength: {
    requireUppercase: true,
    requireLowercase: true,
    requireNumbers: true,
    requireSpecialChars: true
  }
}
```

### Session Configuration

```typescript
session: {
  expiresIn: 60 * 60 * 24 * 7, // 7 days in seconds
  updateAge: 60 * 60 * 24, // Update session every 24 hours
  cookieCache: {
    enabled: true,
    maxAge: 5 * 60 // 5 minutes
  }
}
```

### Rate Limiting

```typescript
rateLimit: {
  window: 60, // 1 minute
  max: 10, // 10 requests per window
  storage: "memory" // or "redis"
}
```

## Custom Hooks

Extend authentication behavior with lifecycle hooks:

```typescript
export const auth = betterAuth({
  hooks: {
    after: [
      {
        matcher: (ctx) => ctx.path === "/sign-up",
        handler: async (ctx) => {
          // Send welcome email
          await sendWelcomeEmail(ctx.user.email)
        }
      }
    ],
    before: [
      {
        matcher: (ctx) => ctx.path === "/sign-in",
        handler: async (ctx) => {
          // Custom rate limiting or logging
          console.log(`Sign-in attempt: ${ctx.body.email}`)
        }
      }
    ]
  }
})
```

## Custom Database Adapters

Create custom adapters for unsupported databases:

```typescript
import { Adapter } from "better-auth"

export function customAdapter(config: CustomConfig): Adapter {
  return {
    id: "custom-adapter",
    async create(data) {
      // Insert record
    },
    async findOne(filter) {
      // Find single record
    },
    async findMany(filter) {
      // Find multiple records
    },
    async update(id, data) {
      // Update record
    },
    async delete(id) {
      // Delete record
    }
  }
}
```

## Schema Management

Better Auth automatically creates necessary database tables:

- `users` - User accounts
- `sessions` - Active sessions
- `accounts` - OAuth provider connections
- `verificationTokens` - Email verification tokens

When using plugins, additional tables are created:

- `organizations` - Organization/team data (organization plugin)
- `organizationMembers` - Membership relationships (organization plugin)
- `twoFactorBackupCodes` - 2FA backup codes (twoFactor plugin)
- `apiKeys` - API key storage (apiKey plugin)

## Best Practices

1. **Environment Variables**: Store all secrets in environment variables, never hardcode
2. **Email Verification**: Enable email verification for production applications
3. **Rate Limiting**: Configure appropriate rate limits to prevent abuse
4. **Session Expiration**: Set reasonable session expiration times based on security needs
5. **Password Requirements**: Enforce strong password policies
6. **HTTPS Only**: Always use HTTPS in production for secure cookie transmission
7. **Database Indexes**: Ensure proper indexes on frequently queried fields
8. **Error Handling**: Implement proper error handling and user feedback
9. **Testing**: Test authentication flows thoroughly in staging environments
10. **Monitoring**: Monitor authentication events and failed login attempts

## TypeScript Types

Better Auth provides full type safety:

```typescript
import type { Session, User } from "better-auth"

// Type-safe authentication state
const session: Session = await authClient.getSession()
const user: User = session.user

// Type-safe plugin data
import type { Organization } from "better-auth/plugins"
const org: Organization = await authClient.organization.get()
```

## Migration from Other Solutions

Better Auth provides migration utilities for:

- NextAuth.js
- Lucia Auth
- Supabase Auth
- Firebase Auth

Migration tools preserve existing user data and session state.
