---
name: rr-better-auth
description: Guidance for implementing authentication with better-auth and better-auth-ui. Use when implementing user authentication, OAuth providers, session management, 2FA, organizations/teams, passkeys, or any authentication-related features in TypeScript applications. Also triggers when working with authentication-related TypeScript files (.ts, .tsx), auth configuration files, or session management code. Example triggers: "Implement user authentication", "Add OAuth login", "Set up 2FA", "Create login page", "Add session management", "Implement passwordless auth", "Build multi-tenant auth"
---

# Better Auth Implementation Skill

## Purpose

This skill provides comprehensive guidance for implementing authentication using better-auth (backend framework) and better-auth-ui (React component library). Better auth is a TypeScript-first authentication framework that supports multiple authentication methods, database systems, and provides a rich plugin ecosystem for advanced features like 2FA, organizations, and API keys.

## When to Use This Skill

Use this skill when:

- Implementing user authentication in a TypeScript/React application
- Setting up OAuth providers (GitHub, Google, Discord, etc.)
- Adding email/password authentication with verification
- Implementing passwordless authentication (magic links, passkeys)
- Setting up two-factor authentication (2FA)
- Building multi-tenant applications with organizations/teams
- Managing user sessions and API keys
- Creating authentication UI components
- Migrating from other authentication solutions

## How to Use This Skill

### Step 1: Review Documentation

Before implementing authentication, review the comprehensive reference documentation:

- **`references/better-auth.md`**: Core authentication setup, configuration, plugins, database adapters, and framework integration
- **`references/better-auth-ui.md`**: React components, customization options, and UI implementation patterns

Use grep to quickly find relevant sections:

```bash
# Find setup instructions
rg "Installation|Setup" references/

# Find specific plugin documentation
rg "twoFactor|organization|apiKey" references/better-auth.md

# Find UI component examples
rg "AuthCard|SessionsCard|OrganizationSwitcher" references/better-auth-ui.md
```

### Step 2: Plan Authentication Requirements

Determine authentication requirements:

1. **Authentication Methods**: Email/password, OAuth providers, magic links, passkeys?
2. **Database**: Which database system (PostgreSQL, MySQL, MongoDB, Prisma)?
3. **Framework**: Next.js, Remix, SvelteKit, or other?
4. **Features**: 2FA, organizations, API keys, multi-session?
5. **UI Requirements**: Custom styling, localization, additional fields?

### Step 3: Install Dependencies

Install better-auth and the appropriate database adapter:

```bash
# Core authentication
bun add better-auth

# Database adapter (choose one)
bun add @better-auth/pg        # PostgreSQL
bun add @better-auth/prisma    # Prisma ORM
bun add @better-auth/mongodb   # MongoDB

# UI components (optional)
bun add @daveyplate/better-auth-ui
```

### Step 4: Configure Backend Authentication

Create authentication configuration with database adapter and plugins:

```typescript
// lib/auth.ts
import { betterAuth } from "better-auth"
import { pg } from "@better-auth/pg"
import { twoFactor, organization } from "better-auth/plugins"

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
    }
  },
  plugins: [
    twoFactor({
      issuer: "Your App Name"
    }),
    organization()
  ]
})
```

Refer to `references/better-auth.md` for:
- Complete configuration options
- Available plugins and their configuration
- Database adapter setup for different systems
- Framework-specific integration patterns

### Step 5: Set Up Framework Integration

Configure better-auth with your framework. For Next.js:

```typescript
// app/api/auth/[...all]/route.ts
import { auth } from "@/lib/auth"
import { toNextJsHandler } from "better-auth/next-js"

export const { GET, POST } = toNextJsHandler(auth)
```

Refer to `references/better-auth.md` section "Framework Integration" for other frameworks (Remix, SvelteKit, Express, etc.).

### Step 6: Create Auth Client (Frontend)

Set up the client-side authentication:

```typescript
// lib/auth-client.ts
import { createAuthClient } from "better-auth/react"

export const authClient = createAuthClient({
  baseURL: process.env.NEXT_PUBLIC_APP_URL
})
```

### Step 7: Implement UI Components

If using better-auth-ui, wrap your application with the provider:

```tsx
// app/providers.tsx
import { AuthUIProvider } from "@daveyplate/better-auth-ui"
import { authClient } from "@/lib/auth-client"

export function Providers({ children }) {
  const router = useRouter()

  return (
    <AuthUIProvider
      authClient={authClient}
      navigate={router.push}
      social={{ providers: ["github", "google"] }}
    >
      {children}
    </AuthUIProvider>
  )
}
```

Then use pre-built components:

```tsx
// app/auth/page.tsx
import { AuthCard } from "@daveyplate/better-auth-ui"

export default function AuthPage() {
  return <AuthCard view="sign-in" />
}
```

Refer to `references/better-auth-ui.md` for:
- Complete component API reference
- Customization options (styling, localization, paths)
- Organization and team management components
- Settings and account management components

### Step 8: Configure Environment Variables

Set up required environment variables:

```env
# Database
DATABASE_URL=postgresql://...

# OAuth Providers
GITHUB_CLIENT_ID=...
GITHUB_CLIENT_SECRET=...
GOOGLE_CLIENT_ID=...
GOOGLE_CLIENT_SECRET=...

# App URL
NEXT_PUBLIC_APP_URL=http://localhost:3000
```

### Step 9: Initialize Database Schema

Better auth automatically creates necessary database tables on first run. For production, use migrations:

```bash
# Generate migration
bun run better-auth migrate

# Run migration
bun run better-auth migrate --apply
```

### Step 10: Test Authentication Flows

Test each authentication method:

1. Email/password registration and sign-in
2. OAuth provider sign-in
3. Email verification
4. Password reset
5. Session management
6. Two-factor authentication (if enabled)
7. Organization/team features (if enabled)

## Common Patterns

### Pattern: Email/Password with Verification

```typescript
export const auth = betterAuth({
  emailAndPassword: {
    enabled: true,
    requireEmailVerification: true,
    minPasswordLength: 8
  },
  // Email sending configuration
  emailVerification: {
    sendVerificationEmail: async ({ user, token }) => {
      await sendEmail({
        to: user.email,
        subject: "Verify your email",
        html: `Click here: ${process.env.APP_URL}/verify?token=${token}`
      })
    }
  }
})
```

### Pattern: Multi-Provider OAuth

```typescript
export const auth = betterAuth({
  socialProviders: {
    github: {
      clientId: process.env.GITHUB_CLIENT_ID,
      clientSecret: process.env.GITHUB_CLIENT_SECRET
    },
    google: {
      clientId: process.env.GOOGLE_CLIENT_ID,
      clientSecret: process.env.GOOGLE_CLIENT_SECRET
    },
    discord: {
      clientId: process.env.DISCORD_CLIENT_ID,
      clientSecret: process.env.DISCORD_CLIENT_SECRET
    }
  }
})
```

### Pattern: Organizations with Custom Roles

```typescript
import { organization } from "better-auth/plugins"

export const auth = betterAuth({
  plugins: [
    organization({
      roles: {
        owner: { permissions: ["*"] },
        admin: { permissions: ["manage_members", "manage_settings"] },
        developer: { permissions: ["manage_code", "read"] },
        member: { permissions: ["read"] }
      }
    })
  ]
})
```

### Pattern: Protected Routes

```tsx
import { RedirectToSignIn } from "@daveyplate/better-auth-ui"

export default function ProtectedPage() {
  return (
    <>
      <RedirectToSignIn />
      <div>Protected content</div>
    </>
  )
}
```

## Best Practices

1. **Environment Variables**: Store all secrets in environment variables
2. **Email Verification**: Enable for production applications
3. **Rate Limiting**: Configure to prevent abuse
4. **HTTPS Only**: Always use HTTPS in production
5. **Session Expiration**: Set reasonable expiration times
6. **Password Policies**: Enforce strong password requirements
7. **Error Handling**: Provide clear user feedback
8. **Testing**: Thoroughly test all authentication flows
9. **Monitoring**: Track authentication events and failures
10. **Type Safety**: Leverage TypeScript types throughout

## Troubleshooting

### Database Connection Issues

Check database adapter configuration and connection string format in `references/better-auth.md`.

### OAuth Provider Errors

Verify OAuth credentials and callback URLs are correctly configured.

### Session Not Persisting

Ensure cookies are properly configured with secure flags in production.

### Email Not Sending

Verify email service configuration and test with a simple email first.

### Type Errors

Ensure better-auth version matches better-auth-ui version requirements (v1.3+).

## Additional Resources

- Search `references/better-auth.md` for backend configuration details
- Search `references/better-auth-ui.md` for UI component examples
- Check plugin documentation for advanced features (2FA, organizations, API keys)
- Review framework integration sections for specific setup patterns
