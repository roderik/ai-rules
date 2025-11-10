# Better Auth UI Documentation

## Overview

Better Auth UI is a React component library providing pre-built, shadcn/ui-styled authentication components for Next.js and React applications. It integrates seamlessly with the better-auth backend framework, offering plug-and-play authentication interfaces with full customization support.

## Key Features

- **Ready-to-use Components**: Complete authentication flows including sign-in, sign-up, password reset, magic links, and account settings
- **Responsive Design**: Mobile-friendly UI across all components
- **TailwindCSS + shadcn/ui**: Modern styling with easy customization
- **Dark Mode Support**: Theme-aware components with light/dark variants
- **Type-safe**: Full TypeScript support with better-auth integration
- **Accessible**: Built with accessibility best practices

## Installation Requirements

### Prerequisites

1. **shadcn/ui**: Must be installed with CSS variables enabled
2. **Sonner Toaster**: Configure toast notifications
3. **TailwindCSS v4**: Proper setup required (v3 supported but deprecated)
4. **better-auth v1.3+**: Core authentication framework

### Installation

```bash
bun add @daveyplate/better-auth-ui
```

### TailwindCSS v4 Setup

Add to global CSS:

```css
@import "@daveyplate/better-auth-ui/css";
```

## Core Setup

### AuthUIProvider Configuration

Wrap your application with the provider:

```tsx
import { AuthUIProvider } from "@daveyplate/better-auth-ui"
import { authClient } from "./lib/auth-client"
import { useRouter } from "next/navigation"
import Link from "next/link"

export function Providers({ children }) {
  const router = useRouter()

  return (
    <AuthUIProvider
      authClient={authClient}
      navigate={router.push}
      replace={router.replace}
      Link={Link}
      onSessionChange={(session) => {
        // Optional: Handle session changes
        console.log("Session updated:", session)
      }}
      social={{
        providers: ["github", "google", "discord"]
      }}
      avatar={{
        upload: async (file) => {
          // Custom avatar upload logic
          const formData = new FormData()
          formData.append("file", file)
          const response = await fetch("/api/upload", {
            method: "POST",
            body: formData
          })
          const { url } = await response.json()
          return url
        }
      }}
      organization={{
        enabled: true,
        customRoles: [
          { name: "developer", description: "Can manage code" },
          { name: "designer", description: "Can manage design" }
        ]
      }}
    >
      {children}
    </AuthUIProvider>
  )
}
```

## Authentication Components

### AuthCard

Main authentication interface supporting multiple flows:

```tsx
import { AuthCard } from "@daveyplate/better-auth-ui"

export default function SignInPage() {
  return (
    <AuthCard
      view="sign-in"
      onSuccess={(session) => {
        console.log("Signed in:", session.user)
      }}
    />
  )
}
```

**Available Views:**
- `sign-in` - Email/password or social sign-in
- `sign-up` - User registration
- `forgot-password` - Password reset request
- `reset-password` - Password reset with token
- `magic-link` - Passwordless email authentication
- `verify-email` - Email verification

### AuthView

Interactive authentication with navigation between views:

```tsx
import { AuthView } from "@daveyplate/better-auth-ui"

export default function AuthPage() {
  return (
    <AuthView
      defaultView="sign-in"
      onSuccess={(session) => {
        // Redirect after successful authentication
        window.location.href = "/dashboard"
      }}
    />
  )
}
```

## Account Settings Components

### UpdateAvatarCard

User avatar management with upload:

```tsx
import { UpdateAvatarCard } from "@daveyplate/better-auth-ui"

export default function ProfilePage() {
  return <UpdateAvatarCard />
}
```

### UpdateNameCard / UpdateUsernameCard

Profile information updates:

```tsx
import { UpdateNameCard, UpdateUsernameCard } from "@daveyplate/better-auth-ui"

export default function ProfilePage() {
  return (
    <>
      <UpdateNameCard />
      <UpdateUsernameCard />
    </>
  )
}
```

### ChangeEmailCard

Email management with verification:

```tsx
import { ChangeEmailCard } from "@daveyplate/better-auth-ui"

export default function SecurityPage() {
  return <ChangeEmailCard />
}
```

### ChangePasswordCard

Secure password updates:

```tsx
import { ChangePasswordCard } from "@daveyplate/better-auth-ui"

export default function SecurityPage() {
  return <ChangePasswordCard />
}
```

### DeleteAccountCard

Account deletion with confirmation:

```tsx
import { DeleteAccountCard } from "@daveyplate/better-auth-ui"

export default function DangerZonePage() {
  return (
    <DeleteAccountCard
      onSuccess={() => {
        window.location.href = "/"
      }}
    />
  )
}
```

## Advanced Components

### SessionsCard

Active session management:

```tsx
import { SessionsCard } from "@daveyplate/better-auth-ui"

export default function SessionsPage() {
  return <SessionsCard />
}
```

### ProvidersCard

Social provider account linking:

```tsx
import { ProvidersCard } from "@daveyplate/better-auth-ui"

export default function ConnectedAccountsPage() {
  return <ProvidersCard />
}
```

### ApiKeysCard

API key generation and management:

```tsx
import { ApiKeysCard } from "@daveyplate/better-auth-ui"

export default function ApiKeysPage() {
  return (
    <ApiKeysCard
      apiKey={{
        enabled: true,
        prefix: "sk_",
        expiresIn: 30, // days
        metadata: {
          environment: "production"
        }
      }}
    />
  )
}
```

### PasskeysCard

WebAuthn passkey management:

```tsx
import { PasskeysCard } from "@daveyplate/better-auth-ui"

export default function PasskeysPage() {
  return <PasskeysCard />
}
```

## Organization Components

### OrganizationSwitcher

Switch between organizations and personal account:

```tsx
import { OrganizationSwitcher } from "@daveyplate/better-auth-ui"

export default function Header() {
  return (
    <nav>
      <OrganizationSwitcher />
    </nav>
  )
}
```

### OrganizationMembersCard

Manage team members and roles:

```tsx
import { OrganizationMembersCard } from "@daveyplate/better-auth-ui"

export default function TeamPage() {
  return <OrganizationMembersCard />
}
```

### OrganizationSettingsCards

Organization configuration:

```tsx
import {
  OrganizationSettingsCard,
  OrganizationDangerCard
} from "@daveyplate/better-auth-ui"

export default function OrgSettingsPage() {
  return (
    <>
      <OrganizationSettingsCard />
      <OrganizationDangerCard />
    </>
  )
}
```

### AcceptInvitationCard

Team invitation acceptance:

```tsx
import { AcceptInvitationCard } from "@daveyplate/better-auth-ui"

export default function InvitePage({ invitationId }) {
  return <AcceptInvitationCard invitationId={invitationId} />
}
```

## Email Components

### EmailTemplate

Responsive HTML email builder for authentication flows:

```tsx
import { EmailTemplate } from "@daveyplate/better-auth-ui"

export async function sendVerificationEmail(user, token) {
  const html = EmailTemplate({
    title: "Verify Your Email",
    body: "Click the button below to verify your email address.",
    buttonText: "Verify Email",
    buttonUrl: `https://yourapp.com/verify?token=${token}`
  })

  await sendEmail({
    to: user.email,
    subject: "Verify Your Email",
    html
  })
}
```

## Protection Utilities

### RedirectToSignIn

Automatically redirect unauthenticated users:

```tsx
import { RedirectToSignIn } from "@daveyplate/better-auth-ui"

export default function ProtectedPage() {
  return (
    <>
      <RedirectToSignIn />
      <div>Protected content here</div>
    </>
  )
}
```

### SignedIn

Conditionally render authenticated content:

```tsx
import { SignedIn } from "@daveyplate/better-auth-ui"

export default function Page() {
  return (
    <>
      <SignedIn>
        <p>You are signed in!</p>
      </SignedIn>
      <SignedIn fallback={<p>Please sign in</p>}>
        <p>Protected content</p>
      </SignedIn>
    </>
  )
}
```

### AuthLoading

Show loading state during session initialization:

```tsx
import { AuthLoading } from "@daveyplate/better-auth-ui"

export default function Layout({ children }) {
  return (
    <AuthLoading fallback={<LoadingSkeleton />}>
      {children}
    </AuthLoading>
  )
}
```

## Customization

### Localization

Override default English strings:

```tsx
<AuthUIProvider
  localization={{
    signIn: {
      title: "Welcome Back",
      emailPlaceholder: "Enter your email",
      passwordPlaceholder: "Enter your password",
      submitButton: "Sign In",
      noAccount: "Don't have an account?",
      signUpLink: "Sign up here"
    }
  }}
>
  {children}
</AuthUIProvider>
```

### Styling with TailwindCSS

Customize appearance via `classNames` props:

```tsx
<AuthCard
  classNames={{
    card: "shadow-xl border-2",
    header: "bg-gradient-to-r from-blue-500 to-purple-500",
    title: "text-2xl font-bold",
    input: "rounded-lg border-gray-300",
    button: "bg-blue-600 hover:bg-blue-700"
  }}
/>
```

### Custom View Paths

Customize authentication routes:

```tsx
<AuthUIProvider
  viewPaths={{
    signIn: "/auth/login",
    signUp: "/auth/register",
    forgotPassword: "/auth/forgot",
    resetPassword: "/auth/reset",
    magicLink: "/auth/magic",
    verifyEmail: "/auth/verify",
    settings: "/dashboard/settings"
  }}
>
  {children}
</AuthUIProvider>
```

### Settings Page Configuration

Three approaches to settings pages:

**1. Move built-in settings to different location:**

```tsx
<AuthUIProvider
  settings={{
    basePath: "/dashboard"
  }}
>
  {children}
</AuthUIProvider>
```

**2. Redirect to custom settings implementation:**

```tsx
<AuthUIProvider
  settings={{
    url: "/custom-settings"
  }}
>
  {children}
</AuthUIProvider>
```

**3. Use individual components for maximum control:**

```tsx
import { UpdateAvatarCard, ChangePasswordCard } from "@daveyplate/better-auth-ui"

export default function CustomSettingsPage() {
  return (
    <div className="space-y-6">
      <UpdateAvatarCard />
      <ChangePasswordCard />
    </div>
  )
}
```

## Additional Fields

Define custom signup and settings fields:

```tsx
<AuthUIProvider
  additionalFields={{
    age: {
      label: "Age",
      type: "number",
      required: true,
      validate: (value) => {
        if (value < 18) {
          return "Must be 18 or older"
        }
        return true
      }
    },
    phoneNumber: {
      label: "Phone Number",
      type: "tel",
      required: false,
      placeholder: "+1 (555) 123-4567"
    },
    country: {
      label: "Country",
      type: "select",
      options: ["USA", "UK", "Canada", "Australia"],
      required: true
    }
  }}
>
  {children}
</AuthUIProvider>
```

## Data Integration

### TanStack Query

Use with React Query for caching and mutations:

```tsx
import { AuthUIProviderTanstack } from "@daveyplate/better-auth-ui/tanstack"
import { QueryClient, QueryClientProvider } from "@tanstack/react-query"

const queryClient = new QueryClient()

export function Providers({ children }) {
  return (
    <QueryClientProvider client={queryClient}>
      <AuthUIProviderTanstack authClient={authClient}>
        {children}
      </AuthUIProviderTanstack>
    </QueryClientProvider>
  )
}
```

### InstantDB

Real-time database integration:

```tsx
import { AuthUIProviderInstant } from "@daveyplate/better-auth-ui/instant"
import { init } from "@instantdb/react"

const db = init({ appId: "your-app-id" })

export function Providers({ children }) {
  return (
    <AuthUIProviderInstant authClient={authClient} db={db}>
      {children}
    </AuthUIProviderInstant>
  )
}
```

### Triplit

Triplit database integration:

```tsx
import { AuthUIProviderTriplit } from "@daveyplate/better-auth-ui/triplit"
import { TriplitClient } from "@triplit/client"

const client = new TriplitClient({ serverUrl: "..." })

export function Providers({ children }) {
  return (
    <AuthUIProviderTriplit authClient={authClient} client={client}>
      {children}
    </AuthUIProviderTriplit>
  )
}
```

## Best Practices

1. **Always configure navigation**: Set `navigate`, `replace`, and `onSessionChange` in provider
2. **Use custom paths**: Implement organization-specific URL schemes
3. **Proper permissions**: Implement role-based access control for sensitive operations
4. **API key security**: Set expiration policies and use metadata for tracking
5. **Email customization**: Customize email templates for brand consistency
6. **Enable 2FA**: Offer two-factor authentication for enhanced security
7. **Error handling**: Implement proper error feedback with toast notifications
8. **Loading states**: Use `AuthLoading` wrapper for smooth user experience
9. **Accessibility**: Maintain semantic HTML and keyboard navigation
10. **Testing**: Test authentication flows across different devices and browsers

## Hooks

Better Auth UI provides React hooks for accessing authentication state:

```tsx
import { useSession, useAuth } from "@daveyplate/better-auth-ui"

export function UserProfile() {
  const { data: session, isPending } = useSession()
  const { signOut } = useAuth()

  if (isPending) return <div>Loading...</div>
  if (!session) return <div>Not signed in</div>

  return (
    <div>
      <p>Welcome, {session.user.name}</p>
      <button onClick={() => signOut()}>Sign Out</button>
    </div>
  )
}
```

## Responsive Design

All components are mobile-first and responsive by default:

- Stack vertically on mobile devices
- Side-by-side layout on tablets and desktops
- Touch-friendly buttons and inputs
- Optimized form layouts for different screen sizes

## Dark Mode

Components automatically adapt to system theme or can be controlled:

```tsx
<html className="dark">
  <body>
    {/* Components automatically use dark theme */}
    <AuthCard />
  </body>
</html>
```

## Form Validation

Built-in validation for all form fields:

- Email format validation
- Password strength indicators
- Required field validation
- Custom validation rules via `additionalFields`
- Real-time feedback with error messages

## Security Considerations

- All components use secure HTTP-only cookies
- CSRF protection built-in
- XSS prevention through React's built-in escaping
- Secure password handling (never exposed in client)
- Rate limiting support through better-auth
- Session timeout handling
- Automatic token refresh
