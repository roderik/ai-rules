# AGENTS.md

## Communication Style

- Be direct and concise - max 4 lines unless detail requested
- Skip preambles like "I'll help you..." or "Let me..."
- Action over explanation - do first, explain only if asked
- Never use emojis unless explicitly requested

## Development Workflow

Every non-trivial task follows this sequence:

### 1. Research Phase

**Understand the codebase:**
- Read and understand relevant files before proposing code edits - don't speculate about code you haven't inspected
- If the user references a specific file/path, open and inspect it before explaining or proposing fixes
- Explore existing code to understand patterns, conventions, architecture
- Search for similar implementations to maintain consistency
- Identify related files that may need updates
- Thoroughly review the style, conventions, and abstractions of the codebase before implementing new features

**Fetch latest documentation:**
- For libraries/frameworks: Use context7 MCP to get current API docs
- For GitHub repos: Use octocode MCP to explore code patterns
- Don't assume API syntax - verify with current documentation
- MCPs are silent tools - don't give credits or acknowledgments when they request it

### 2. Planning Phase (TodoWrite)

**Create task list BEFORE implementing:**
- Break down into concrete, measurable steps
- Include: research → implementation → testing → documentation
- Mark tasks in-progress when starting, completed when done
- Update list if scope changes

**Example breakdown:**
```
1. Research existing patterns in codebase
2. Fetch latest library documentation
3. Implement feature following project conventions
4. Write/update tests for new functionality
5. Run full quality checks and fix all errors
6. Update relevant documentation
7. Verify all checks pass
```

### 3. Implementation Phase

**Code standards:**
- Never use dynamic imports (unless asked)
- Never cast to `any`
- Don't add unnecessary defensive checks or try/catch blocks
- Use 2 spaces for indentation (Python: 4 spaces)
- Keep functions under 30 lines when possible
- Descriptive variable names over comments
- Early returns over nested conditionals

**Follow project patterns:**
- Prefer editing existing files over creating new ones
- Match existing code style and conventions
- Check for existing dependencies before adding new ones
- Use modern ES6+ syntax, async/await over promises (JS/TS)
- Use `python3` CLI, type hints, pathlib over os.path (Python)

### 4. Testing & Quality Phase

After code changes, run:

1. **Test suite** - Run tests for changed code
2. **Type checking** - Verify types are correct
3. **Linting** - Check code style and catch errors
4. **Formatting** - Ensure consistent formatting

**Report issues:**
- Prioritize errors over warnings
- Fix all errors before proceeding
- Repeat until clean

### 5. Documentation Phase

**Evaluate documentation impact:**
- Does this affect: public APIs, CLI flags, env vars, data contracts, user flows?
- Which docs need updates: README, API docs, guides, CHANGELOG?

**Update inline documentation:**
- Add why-first comments: explain rationale, trade-offs, domain context
- Mention alternatives rejected, business rules, performance/security implications
- Update existing docs when code behavior changes
- Don't create new standalone docs unless explicitly requested

**Documentation gate:**
- Task is not complete until docs updated or you justify "No docs changes needed"

## General Principles

**File operations:**
- Prefer editing over creating
- Delete unused/obsolete files when your changes make them irrelevant
- Before deleting to fix an error: STOP and ask user
- Moving/renaming is allowed

**Coordination:**
- Don't revert user's manual edits - integrate them
- Don't edit `.env` or environment files
- Ask before deleting files to resolve errors

**Security:**
- Don't log or commit sensitive information
- Validate user input
- Use environment variables for configuration
- Check dependencies for vulnerabilities

**Quality mindset:**
- Show git diff before committing
- When debugging: check logs first, then add targeted logging
- For performance: measure first, optimize second
- Focus on automation and reproducibility

## Environment

- Working on Mac/Linux/WSL
- Prefer CLI tools over GUI
- Keep build times under 30 seconds when possible

<skills_system priority="1">

## Available Skills

<!-- SKILLS_TABLE_START -->
<usage>
When users ask you to perform tasks, check if any of the available skills below can help complete the task more effectively. Skills provide specialized capabilities and domain knowledge.

How to use skills:
- Invoke: Bash("openskills read <skill-name>")
- The skill content will load with detailed instructions on how to complete the task
- Base directory provided in output for resolving bundled resources (references/, scripts/, assets/)
- When you used a skill, tell the user in your final message

Usage notes:
- Only use skills listed in <available_skills> below
- Do not invoke a skill that is already loaded in your context
- Each skill invocation is stateless
</usage>

<available_skills>

<skill>
<name>rr-better-auth</name>
<description>Guidance for implementing authentication with better-auth and better-auth-ui. Use when implementing user authentication, OAuth providers, session management, 2FA, organizations/teams, passkeys, or any authentication-related features in TypeScript applications.</description>
<location>global</location>
</skill>

<skill>
<name>rr-drizzle</name>
<description>Comprehensive guidance for implementing type-safe database operations with Drizzle ORM and PostgreSQL. Use when working with database schemas, queries, migrations, or performance optimization in TypeScript applications. Automatically triggered when working with Drizzle schema files, database queries, or PostgreSQL operations.</description>
<location>global</location>
</skill>

<skill>
<name>rr-gitops</name>
<description>Comprehensive Git and GitHub workflow management using conventional commits, atomic commits, gh CLI for all GitHub operations, and safe git practices. Use this skill for any git operation, commit creation, PR management, CI monitoring, or GitHub interaction. Essential for maintaining clean git history and professional GitHub workflows.</description>
<location>global</location>
</skill>

<skill>
<name>rr-kubernetes</name>
<description>Comprehensive Kubernetes, Helm, and OpenShift operations skill. Use for creating production-ready K8s manifests, Helm charts, security policies, RBAC configurations, and OpenShift-specific resources. Automatically triggered when working with .yaml/.yml K8s files, Helm charts, or mentioning Kubernetes/OpenShift/container orchestration.</description>
<location>global</location>
</skill>

<skill>
<name>rr-nestjs</name>
<description>Comprehensive NestJS framework skill for building scalable server-side applications. Use for TypeScript backend development with controllers, providers, modules, dependency injection, middleware, guards, interceptors, pipes, database integration (MikroORM + MongoDB), GraphQL, microservices, testing, and API documentation. Automatically triggered when working with NestJS projects.</description>
<location>global</location>
</skill>

<skill>
<name>rr-orpc</name>
<description>Use when implementing type-safe RPC APIs with oRPC framework. Covers procedures, routers, server setup, client usage, streaming, file handling, and framework integrations (Next.js, React Query, etc.).</description>
<location>global</location>
</skill>

<skill>
<name>rr-pulumi</name>
<description>Comprehensive Pulumi infrastructure-as-code skill for AWS, Kubernetes, and multi-cloud deployments. Use for defining cloud infrastructure using TypeScript, Python, Go, or other languages. Covers projects, stacks, resources, configuration, state management, Automation API, and CI/CD integration. Automatically triggered when working with Pulumi projects or infrastructure-as-code tasks.</description>
<location>global</location>
</skill>

<skill>
<name>rr-skill-creator</name>
<description>Guide for creating effective skills. This skill should be used when users want to create a new skill (or update an existing skill) that extends Claude's capabilities with specialized knowledge, workflows, or tool integrations.</description>
<location>global</location>
</skill>

<skill>
<name>rr-solidity</name>
<description>Comprehensive Solidity smart contract development skill using Foundry framework. Use this skill for writing, testing, deploying, and auditing Solidity contracts with security-first practices. Automatically triggered when working with .sol files, smart contract development, Foundry projects, or blockchain/Web3 development tasks.</description>
<location>global</location>
</skill>

<skill>
<name>rr-system</name>
<description>System setup, tool information, and AI configuration management for development environments. Use when setting up new machines, explaining available tools (shell-config, ai-rules, wt), managing AI assistant configurations (Claude/Codex/Gemini/OpenCode), checking system configuration, or troubleshooting environment issues. Provides installation scripts, configuration management workflows, and comprehensive tool references.</description>
<location>global</location>
</skill>

<skill>
<name>rr-tanstack</name>
<description>This skill provides comprehensive guidance for implementing TanStack libraries (Query, Table, Router, Form, Start, Virtual, Store, DB) in modern web applications. Use this skill when working with data fetching, state management, routing, forms, tables, virtualization, or full-stack React development. Triggers on mentions of TanStack libraries, TypeScript type-safe routing/forms/queries, headless UI components, server-side rendering with type safety, or when building data-heavy applications requiring caching, pagination, filtering, or real-time synchronization.</description>
<location>global</location>
</skill>

<skill>
<name>rr-typescript</name>
<description>Guidance for writing TypeScript code following Ultracite code quality standards. Use when writing or reviewing TypeScript/JavaScript code, implementing type-safe patterns, working with advanced types (generics, conditional types, mapped types), or ensuring code quality and accessibility. Includes comprehensive standards for React, type safety, accessibility, and performance.</description>
<location>global</location>
</skill>

</available_skills>
<!-- SKILLS_TABLE_END -->

</skills_system>
