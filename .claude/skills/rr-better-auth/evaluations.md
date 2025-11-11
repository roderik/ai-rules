# Evaluation Scenarios for rr-better-auth

## Scenario 1: Basic Usage - Set Up Email/Password Authentication

**Input:** "Set up email and password authentication using better-auth with session management"

**Expected Behavior:**

- Automatically activate when "better-auth" or "authentication" is mentioned
- Install better-auth and better-auth-ui
- Create auth.ts configuration file
- Configure database adapter (Drizzle/Prisma)
- Set up email/password provider
- Create session management
- Add middleware for protected routes
- Create sign-up and sign-in forms
- Include TypeScript types

**Success Criteria:**

- [ ] Installs better-auth package
- [ ] Creates auth.ts config file
- [ ] Database adapter configured (PostgreSQL with Drizzle)
- [ ] Secret key set from environment variable
- [ ] Email provider configured
- [ ] Session configuration included
- [ ] Sign-up endpoint created
- [ ] Sign-in endpoint created
- [ ] Protected route middleware example
- [ ] TypeScript types properly defined

## Scenario 2: Complex Scenario - Multi-Provider OAuth with 2FA

**Input:** "Build a complete authentication system with Google and GitHub OAuth providers, plus email/password auth. Add two-factor authentication and organization support for team features."

**Expected Behavior:**

- Load skill and understand complex auth requirements
- Configure better-auth with:
  - Email/password provider
  - Google OAuth provider
  - GitHub OAuth provider
  - 2FA plugin
  - Organizations plugin
- Set up OAuth credentials in environment
- Create auth routes for each provider
- Implement 2FA flow:
  - Setup endpoint
  - Verify endpoint
  - Backup codes
- Add organization management:
  - Create organization
  - Invite members
  - Role-based access
- Create comprehensive UI with better-auth-ui
- Include session management
- Add proper error handling

**Success Criteria:**

- [ ] Multiple providers configured (email, Google, GitHub)
- [ ] OAuth client IDs and secrets in environment variables
- [ ] 2FA plugin enabled and configured
- [ ] Organizations plugin enabled
- [ ] Auth routes created for all providers
- [ ] 2FA setup flow implemented
- [ ] 2FA verification flow implemented
- [ ] Backup codes generation included
- [ ] Organization creation endpoint
- [ ] Member invitation system
- [ ] Role-based access control (owner/admin/member)
- [ ] UI components for all auth flows
- [ ] Session management with refresh tokens
- [ ] Error handling for all flows

## Scenario 3: Error Handling - Session Expired Redirect

**Input:** "Users are getting errors when their session expires. I need to redirect them to login and preserve their intended destination."

**Expected Behavior:**

- Recognize session expiration handling issue
- Explain better-auth session lifecycle
- Show how to check session status in middleware
- Implement redirect with return URL:
  - Capture original URL
  - Store in query parameter or session
  - Redirect to login
  - Redirect back after successful auth
- Show client-side session checking
- Handle token refresh if configured
- Provide proper error messages
- Reference better-auth session docs

**Success Criteria:**

- [ ] Checks session status in middleware
- [ ] Captures original URL before redirect
- [ ] Stores return URL in query param or cookie
- [ ] Redirects to login with return URL
- [ ] After login, redirects to original destination
- [ ] Handles missing or invalid return URL
- [ ] Client-side session check implemented
- [ ] Token refresh logic if configured
- [ ] Proper error messages displayed
- [ ] References better-auth session management
