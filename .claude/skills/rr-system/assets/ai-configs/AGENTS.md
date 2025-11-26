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

Important: when you used a skill, tell the user in your final message.

<!-- SKILLS_TABLE_START -->
<usage>
When users ask you to perform tasks, check if any of the available skills below can help complete the task more effectively. Skills provide specialized capabilities and domain knowledge.

How to use skills:
- Invoke: Bash("openskills read <skill-name>")
- The skill content will load with detailed instructions on how to complete the task
- Base directory provided in output for resolving bundled resources (references/, scripts/, assets/)

Usage notes:
- Only use skills listed in <available_skills> below
- Do not invoke a skill that is already loaded in your context
- Each skill invocation is stateless
</usage>

<available_skills>

<skill>
<name>rr-better-auth</name>
<description>Guidance for implementing authentication with better-auth and better-auth-ui. Use when implementing user authentication, OAuth providers, session management, 2FA, organizations/teams, passkeys, or any authentication-related features in TypeScript applications. Also triggers when working with authentication-related TypeScript files (.ts, .tsx), auth configuration files, or session management code. Example triggers: "Implement user authentication", "Add OAuth login", "Set up 2FA", "Create login page", "Add session management", "Implement passwordless auth", "Build multi-tenant auth"</description>
<location>global</location>
</skill>

<skill>
<name>rr-chrome-devtools</name>
<description>Chrome DevTools browser automation with on-demand MCP server loading. Use when automating browser interactions, taking screenshots, debugging web pages, monitoring network requests, or performance profiling. Example triggers: "Take screenshot", "Click button", "Fill form", "Debug webpage", "Check network requests", "Profile performance", "Enable browser automation"</description>
<location>global</location>
</skill>

<skill>
<name>rr-drizzle</name>
<description>Comprehensive guidance for implementing type-safe database operations with Drizzle ORM and PostgreSQL. Use when working with database schemas, queries, migrations, or performance optimization in TypeScript applications. Also triggers when working with Drizzle schema files (.ts files with pgTable, drizzle imports), migration files, database query code, or drizzle.config.ts files. Example triggers: "Create database schema", "Write Drizzle query", "Generate migration", "Optimize database query", "Set up Drizzle ORM", "Add database table", "Fix query performance"</description>
<location>global</location>
</skill>

<skill>
<name>rr-gitops</name>
<description>Comprehensive Git and GitHub workflow management using conventional commits, atomic commits, gh CLI for all GitHub operations, and safe git practices. Use this skill for any git operation, commit creation, PR management, CI monitoring, or GitHub interaction. Also triggers when working with .git files, GitHub Actions workflows (.yml, .yaml in .github/workflows/), or when performing git operations. Example triggers: "Create a commit", "Make a pull request", "Check CI status", "Watch GitHub Actions", "Create PR", "Fix commit message", "Monitor CI run", "Get PR comments"</description>
<location>global</location>
</skill>

<skill>
<name>rr-kubernetes</name>
<description>Comprehensive Kubernetes, Helm, and OpenShift operations skill. Use for creating production-ready K8s manifests, Helm charts, security policies, RBAC configurations, and OpenShift-specific resources. Also triggers when working with Kubernetes YAML files (.yaml, .yml), Helm chart files (Chart.yaml, values.yaml), or container orchestration configuration. Example triggers: "Create Kubernetes deployment", "Write Helm chart", "Set up RBAC", "Create K8s manifest", "Deploy to Kubernetes", "Configure OpenShift", "Add security policy"</description>
<location>global</location>
</skill>

<skill>
<name>rr-linear</name>
<description>Linear issue tracking integration with on-demand MCP server loading. Use when working with Linear issues, projects, or workflows. Provides instructions to enable Linear MCP per-project and common issue CRUD operations. Example triggers: "Create Linear issue", "List my issues", "Update issue status", "Work on Linear ticket", "Enable Linear integration"</description>
<location>global</location>
</skill>

<skill>
<name>rr-nestjs</name>
<description>Comprehensive NestJS framework skill for building scalable server-side applications. Use for TypeScript backend development with controllers, providers, modules, dependency injection, middleware, guards, interceptors, pipes, database integration (MikroORM + MongoDB), GraphQL, microservices, testing, and API documentation. Also triggers when working with NestJS TypeScript files (.ts), NestJS module files, nest-cli.json, or NestJS project structure. Example triggers: "Create NestJS controller", "Set up dependency injection", "Add middleware", "Create GraphQL resolver", "Build microservice", "Write NestJS test", "Set up database module"</description>
<location>global</location>
</skill>

<skill>
<name>rr-orpc</name>
<description>Guidance for implementing type-safe RPC APIs with oRPC framework. Use when implementing type-safe RPC APIs, building server procedures, setting up routers, or integrating oRPC with frameworks like Next.js or React Query. Also triggers when working with oRPC-related TypeScript files (.ts, .tsx), files importing from @orpc packages, or RPC server/client code. Example triggers: "Set up oRPC server", "Create RPC procedure", "Implement type-safe API", "Add oRPC router", "Integrate with Next.js", "Set up streaming", "Create RPC client"</description>
<location>global</location>
</skill>

<skill>
<name>rr-pulumi</name>
<description>Comprehensive Pulumi infrastructure-as-code skill for AWS, Kubernetes, and multi-cloud deployments. Use for defining cloud infrastructure using TypeScript, Python, Go, or other languages. Covers projects, stacks, resources, configuration, state management, Automation API, and CI/CD integration. Also triggers when working with Pulumi files (.ts, .py, .go), Pulumi.yaml, or infrastructure definition files. Example triggers: "Create Pulumi stack", "Define AWS resources", "Set up Kubernetes cluster", "Deploy infrastructure", "Create Pulumi project", "Manage cloud resources", "Update infrastructure"</description>
<location>global</location>
</skill>

<skill>
<name>rr-shadcn</name>
<description>shadcn/ui component library integration with on-demand MCP server loading. Use when adding UI components, searching component registries, viewing component examples, or scaffolding new UI. Example triggers: "Add button component", "Search shadcn components", "View component examples", "Install shadcn", "Enable shadcn integration"</description>
<location>global</location>
</skill>

<skill>
<name>rr-skill-creator</name>
<description>Guide for creating effective skills. This skill should be used when users want to create a new skill (or update an existing skill) that extends Claude's capabilities with specialized knowledge, workflows, or tool integrations.</description>
<location>global</location>
</skill>

<skill>
<name>rr-solidity</name>
<description>Comprehensive Solidity smart contract development skill using Foundry framework. Use for writing, testing, deploying, and auditing Solidity contracts with security-first practices. Also triggers when working with .sol files, Foundry project files (foundry.toml), test files (.t.sol), or smart contract deployment scripts. Example triggers: "Write smart contract", "Create Solidity test", "Deploy contract", "Audit smart contract", "Fix security vulnerability", "Write Foundry test", "Set up Foundry project"</description>
<location>global</location>
</skill>

<skill>
<name>rr-system</name>
<description>System setup, tool information, and AI configuration management for development environments. Use when setting up new machines, explaining available tools (shell-config, ai-rules, wt), managing AI assistant configurations (Claude/Codex/Gemini/OpenCode), checking system configuration, or troubleshooting environment issues. Also triggers when working with configuration files (.json, .toml, .fish, .zsh, .bash), Brewfiles, or installation scripts. Example triggers: "Set up my development environment", "Install tools on new machine", "Configure AI assistant", "What tools do I have?", "Update my shell config", "Add MCP server to Claude", "Check system configuration"</description>
<location>global</location>
</skill>

<skill>
<name>rr-tanstack</name>
<description>Comprehensive guidance for implementing TanStack libraries (Query, Table, Router, Form, Start, Virtual, Store, DB) in modern web applications. Use when working with data fetching, state management, routing, forms, tables, virtualization, or full-stack React development. Also triggers when working with TanStack-related TypeScript files (.ts, .tsx), files importing from @tanstack packages, or React components using TanStack hooks. Example triggers: "Implement data fetching", "Create a data table", "Set up routing", "Build a form", "Add server-side rendering", "Implement virtual scrolling", "Set up state management", "Use TanStack Query"</description>
<location>global</location>
</skill>

<skill>
<name>rr-temporal</name>
<description>Comprehensive guidance for building durable, fault-tolerant workflows with Temporal and TypeScript. Use when implementing workflow orchestration, distributed systems, long-running processes, saga patterns, or durable execution. Also triggers when working with Temporal TypeScript files (.ts), files importing from @temporalio packages, workflow/activity definitions, or worker configurations. Example triggers: "Create Temporal workflow", "Implement saga pattern", "Set up Temporal worker", "Add activity with retry", "Handle workflow signals", "Use continueAsNew for long-running workflow"</description>
<location>global</location>
</skill>

<skill>
<name>rr-typescript</name>
<description>Guidance for writing TypeScript code following Ultracite code quality standards. Use when writing or reviewing TypeScript/JavaScript code, implementing type-safe patterns, working with advanced types (generics, conditional types, mapped types), or ensuring code quality and accessibility. Also triggers when working with TypeScript files (.ts, .tsx), JavaScript files (.js, .jsx), tsconfig.json, or when reviewing code quality. Example triggers: "Write TypeScript code", "Fix type errors", "Review code quality", "Implement type-safe patterns", "Add type definitions", "Refactor to TypeScript", "Check accessibility", "Run Ultracite"</description>
<location>global</location>
</skill>

</available_skills>
<!-- SKILLS_TABLE_END -->

</skills_system>
