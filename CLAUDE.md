# CLAUDE.md

!! Be extremely concise. Sacrifice grammar for the sake of concision.
!! never use dymamic imports (unless asked to) lile `await import(...)`
!! never cast to `any`
!! do not add extra defensive checks or try/catch blocks

## 🚨 MANDATORY AUTOMATIC AGENTS (MUST RUN WITHOUT USER ASKING)

**AFTER ANY CODE CHANGE, YOU MUST AUTOMATICALLY RUN:**

1. **test runner agent** (via Task tool) - Uses IDE diagnostics + runs tests, linting, formatting
2. **code commenter agent** (via Task tool) - Uses IDE symbol analysis for smart documentation

**These are PROACTIVE agents - they MUST run AUTOMATICALLY after EVERY code edit.**
**DO NOT wait for the user to ask. DO NOT skip for "small" changes.**
**Fix ALL errors before proceeding with ANY other task.**
**CRITICAL: These agents now use IDE/LSP capabilities for deeper analysis.**

## Identity & Communication Style

- Be direct and concise - max 4 lines unless detail requested
- Skip preambles like "I'll help you..." or "Let me..."
- Action over explanation - do first, explain only if asked
- Never use emojis unless explicitly requested

## Coding Standards

### IDE-First Development (WHEN CONNECTED TO CURSOR/VS CODE)

**PRIORITY ORDER for code analysis:**

1. **IDE Diagnostics**: immediate LSP feedback
2. **IDE Symbol Navigation**: Use ide-navigator agent for exploration
3. **Traditional Tools**: Only after IDE tools (grep, find, etc.)

**Key IDE Usage Patterns:**

- Before ANY file edit: Check IDE diagnostics for that file
- Before running tests: Get all workspace diagnostics first
- For navigation: Use IDE symbol search over text search
- For refactoring: Use IDE to find all references first

### Documentation & Research (CRITICAL)

- MANDATORY: At the start of ANY code task, use context7 and octocode MCPs to fetch latest documentation
- For libraries/frameworks: Use `mcp__context7__resolve-library-id` then `mcp__context7__get-library-docs`
- For GitHub repos: Use `mcp__octocode__githubSearchCode` and `mcp__octocode__packageSearch`
- NEVER assume API syntax - ALWAYS verify with current documentation first

### General Principles

- Prefer editing existing files over creating new ones
- Never create documentation unless explicitly requested
- Follow existing code patterns and conventions in each project
- Always check for existing dependencies before suggesting new ones
- Delete unused or obsolete files when your changes make them irrelevant (refactors, feature removals, etc.), and revert files only when the change is yours or explicitly requested. If a git operation leaves you unsure about other agents' in-flight work, stop and coordinate instead of deleting.
- **Before attempting to delete a file to resolve a local type/lint failure, stop and ask the user.** Other agents are often editing adjacent files; deleting their work to silence an error is never acceptable without explicit approval.
- NEVER edit `.env` or any environment variable files—only the user may change them.
- Coordinate with other agents before removing their in-progress edits—don't revert or delete work you didn't author unless everyone agrees.
- Moving/renaming and restoring files is allowed.
- **AFTER ANY CODE CHANGE: Immediately run test-runner agent**

### Code Style

- Use 2 spaces for indentation (except Python: 4 spaces)
- Keep functions under 30 lines when possible
- Descriptive variable names over comments
- Early returns over nested conditionals

### Git Workflow

- Branch naming: `feat/`, `fix/`, `chore/`, `docs/` prefixes
- Commit format: `type(scope): description` (conventional commits)
- Never commit directly to main/master
- ABSOLUTELY NEVER run destructive git operations (e.g., `git reset --hard`, `rm`, `git checkout`/`git restore` to an older commit) unless the user gives an explicit, written instruction in this conversation. Treat these commands as catastrophic; if you are even slightly unsure, stop and ask before touching them. *(When working within Cursor or Codex Web, these git limitations do not apply; use the tooling's capabilities as needed.)*
- Never use `git restore` (or similar commands) to revert files you didn't author—coordinate with other agents instead so their in-progress work stays intact.
- Always double-check git status before any commit
- Keep commits atomic: commit only the files you touched and list each path explicitly. For tracked files run `git commit -m "<scoped message>" -- path/to/file1 path/to/file2`. For brand-new files, use the one-liner `git restore --staged :/ && git add "path/to/file1" "path/to/file2" && git commit -m "<scoped message>" -- path/to/file1 path/to/file2`.
- Quote any git paths containing brackets or parentheses (e.g., `src/app/[candidate]/**`) when staging or committing so the shell does not treat them as globs or subshells.
- When running `git rebase`, avoid opening editors—export `GIT_EDITOR=:` and `GIT_SEQUENCE_EDITOR=:` (or pass `--no-edit`) so the default messages are used automatically.
- Never amend commits unless you have explicit written approval in the task thread.
- **MANDATORY before ANY commit: Run test-runner agent**
- **DO NOT commit if agents report errors - fix them first**
- When you are pushing to a PR or opening a PR, watch the successful CI run with `gh run watch <run-id>`

## Common Commands & Aliases

### Frequently Used Commands

- Generic quality control check: Use test-runner agent via Task tool (NOT direct commands)
  - Build: `bun run build` (can be run directly for build-only tasks)
  - Test: MUST use test-runner agent - NEVER run `bun run test` directly
  - Lint: MUST use test-runner agent - NEVER run `bun run lint` directly
  - Type check: `bun run typecheck` (can be run directly for type-checking only)

## Tool Preferences

### IDE Integration (PRIORITIZE WHEN CONNECTED)

**When IDE is connected (Cursor/VS Code), ALWAYS use these MCP tools first:**

**Benefits of IDE-First Approach:**

- Instant feedback from Language Server Protocol (LSP)
- Type errors caught without compilation
- Dead code and unused imports detected immediately
- Symbol relationships understood automatically

### Language-Specific

- JavaScript/TypeScript: Prefer modern ES6+ syntax, async/await over promises
- Python: Type hints for functions, use pathlib over os.path
- Shell: Prefer bash over sh, use shellcheck conventions

### Testing & Code Review (MANDATORY - IDE-ENHANCED AUTOMATIC EXECUTION)

- **CRITICAL: After ANY code change, you MUST IMMEDIATELY use BOTH:**
  1. **test-runner agent** - IDE diagnostics FIRST, then tests/linting/formatting (via Task tool)
  2. **code-commenter agent** - Symbol-aware documentation (via Task tool)
- **IDE FIRST PRINCIPLE: Always check ide diagnostics before running tests**
- **These are NOT OPTIONAL - they MUST run AUTOMATICALLY after EVERY code edit**
- **NO EXCEPTIONS - even for "small" changes**
- NEVER run `bun run test`, `npm test`, or any test commands directly via Bash
- The agents will return focused error lists that you MUST fix immediately
- Continue running agents until ALL errors are resolved
- IDE diagnostics often catch errors faster than running full test suites
- Prefer unit tests with clear test names
- Mock external dependencies

## Security & Best Practices

- Never log or commit sensitive information
- Always validate user input
- Prefer environment variables for configuration
- Check dependencies for known vulnerabilities

## Personal Workflow Preferences

- Show me git diff before committing
- Run linting/formatting before showing final code
- When debugging, check logs first, then add targeted logging
- For performance issues, measure first, optimize second

## Multi-Model Collaboration Preferences

**CRITICAL: The tool/agent currently reading this file is the main thread and owns implementation. Other models provide analysis/insights ONLY.**

- **Gemini**: `gemini -m gemini-2.5-pro -p "<prompt>"` — validation, fact‑checking, and technical analysis
- **Codex (GPT-5, high reasoning)**: `codex -m gpt-5 -c reasoning.level="high" "<prompt>"` — complex debugging insights and root cause analysis
- **Claude (Opus)**: `claude --model opus --print "<prompt>"` — synthesis, plan refinement, and risk assessment

**Never ask other models to:**

- Write code, fix errors, or implement solutions
- Create files, documentation, or content
- Provide code snippets for fixes

**Always ask them for:**

- Analysis, insights, and explanations
- Root cause identification
- Technical validation and fact-checking

## Quick Reference Reminders

- Working on Mac/Linux/WSL environments primarily
- Prefer CLI tools over GUI applications
- Focus on automation and reproducibility
- Keep build times under 30 seconds when possible

## Tooling for shell interactions

**CRITICAL**: This system uses MODERN TOOLS ONLY. Traditional commands are ALIASED to modern alternatives.
**WARNING**: Parameter syntax DIFFERS from traditional tools. ALWAYS use the modern tool syntax.

### MANDATORY Tool Usage:

- Finding FILES? **USE `fd`** (NOT find - even though `find` is aliased to `fd`)
- Finding TEXT/strings? **USE `rg`** (NOT grep - even though `grep` is aliased to `rg`)
- Finding CODE STRUCTURE? **USE `ast-grep`**
- SELECTING from results? **PIPE TO `fzf`**
- Interacting with JSON? **USE `jq`**
- Interacting with YAML/XML? **USE `yq`**

## Modern Tool Aliases (IMPORTANT: TRADITIONAL COMMANDS ARE ALIASED)

**⚠️ CRITICAL: The traditional commands below are ALIASED to modern tools. Using `ls` actually runs `eza`, using `cat` runs `bat`, etc.**
**⚠️ ALWAYS use the modern tool's syntax and parameters, NOT the traditional command's syntax.**

When you need to call tools from the shell, **use this rubric**:

- **Is it about finding FILES?** use `fd`
- **Is it about finding TEXT/strings?** use `rg`
- **Is it about finding CODE STRUCTURE?** use `ast-grep`
  - **Default to TypeScript:**
    - `.ts` → `ast-grep --lang ts -p '<pattern>'`
    - `.tsx` (React) → `ast-grep --lang tsx -p '<pattern>'`
  - For other languages, set `--lang` appropriately (e.g., `--lang rust`).
- **Need to SELECT from multiple results?** pipe to `fzf`
- **Interacting with JSON?** use `jq`
- **Interacting with YAML or XML?** use `yq`

You run in an environment where **`ast-grep` is available**.
Whenever a search requires **syntax‑aware / structural matching**, **default to `ast-grep`** with the correct `--lang`, and **avoid** falling back to text‑only tools like `rg` or `grep` unless a plain‑text search is explicitly requested.

This system has modern alternatives installed and ALIASED:

- `bat` — Use instead of `cat` for file viewing with syntax highlighting and Git context. For machine‑readable output, prefer `bat --style=plain <file>`.
- `eza` — Use instead of `ls`/`tree` for listings. Common: `eza -la`; tree view: `eza -T`.
- `rg` (ripgrep) — Use instead of `grep` for text search. Examples: `rg "pattern" -n`, add `-i` for case‑insensitive, scope with `--glob`.
- `fd` — Use instead of `find` to locate files/dirs. Examples: `fd <pattern> -t f` (files), `fd <pattern> -t d` (dirs).
- `difft` — Already configured for Git; run `git diff` to see styled, syntax‑aware diffs.
- `hexyl` (alias: `hex`) — View files in hexadecimal: `hexyl <file>`.
- `procs` — Use instead of `ps` to inspect processes. Examples: `procs`, `procs -A`. Aliases: `pst`, `psw`.
- `tmux` — Terminal multiplexer for sessions/panes. `tm*` aliases are available.
- `uv` — Python project and package manager. Use for envs and installs. Aliases: `uvs`, `uvi`, `uvr`.
- `forge`/`cast` — Foundry tools for EVM development. Use when working with Ethereum smart contracts.

### ⚠️ CRITICAL REMINDERS:

1. **NEVER use traditional command syntax** - Even though `ls` exists, it's actually `eza`
2. **ALWAYS use modern tool parameters** - `fd` syntax NOT `find` syntax
3. **When in doubt, use the modern tool directly** - Use `eza` instead of `ls`, `bat` instead of `cat`
4. **Examples of CORRECT usage:**
   - `fd . -t f` (NOT `find . -type f`)
   - `rg "pattern"` (NOT `grep "pattern"`)
   - `eza -la` (NOT `ls -la` even though it might work)
   - `bat file.txt` (NOT `cat file.txt` even though it's aliased)

## Coding guidelines (REQUIRED and CRITICAL)

Copy-pasteable **LLM ruleset extensions**. Clear, prescriptive, and phrased in the positive. Designed for generation _and_ review. Keep using the “What the assistant produces” and “Checklist” sections from the base ruleset; these modules plug right in.

---

### A) Accessibility (a11y) — Generate markup that screen readers and keyboards love

**Semantics first**

- Prefer native semantic elements (`<button>`, `<a>`, `<nav>`, `<main>`, `<table>`, `<th>`, etc.) over adding ARIA. Only add ARIA when native semantics can’t express the widget, and then use **valid, non‑abstract roles**, with **all required ARIA attributes** and **valid values**. If available, use the shadcn components that handle this internally.
- Rely on implicit roles by default; specify `role` only when changing semantics.
- Use `scope` **only** on `<th>` cells that label rows/columns.

**Focus & keyboard**

- Keep DOM order = tab order. Use `tabIndex={0}` only to make a custom widget focusable, and use `tabIndex={0}` on the composite container when using `aria-activedescendant`.
- Avoid positive `tabIndex` values; manage order structurally.
- Pair pointer handlers with keyboard: `onClick` ⇢ add `onKeyUp`/`onKeyDown` (Space/Enter); `onMouseOver`/`onMouseOut` ⇢ add `onFocus`/`onBlur`.
- Make any element with interactive behavior _focusable_ and give it an appropriate role, or better, use a native interactive element instead of a div.

**Discernible, accurate names**

- Give every control a programmatic name: `<label for>` or `aria-label/aria-labelledby` bound to an `<input>`.
- Ensure links have accessible content (text or ARIA label) and a **real** `href`.
- Provide meaningful `alt` text for images; describe the content and omit filler words like “image/photo/picture”.
- Headings (`<h1>…<h6>`) contain text that is _not_ hidden from assistive tech.

**Media & graphics**

- Add caption tracks to `<audio>`/`<video>`.
- For inline SVG, include a `<title>` child for a text alternative.

**Document & i18n**

- Set `<html lang="…">` using correct BCP‑47 codes (e.g., `en`, `en-GB`, `nl-BE`).
- Use valid `autocomplete` values on form controls.
- Give `<iframe>` a descriptive `title`.

**Roles/props hygiene**

- Only apply ARIA roles/properties/states that the element and role support; validate all `aria-*` attributes.
- Ensure explicit `role` is never a redundant repeat of the implicit one.

**Buttons & activation**

- Always set `<button type="button|submit|reset">` explicitly.
- If you must use a static element with a click handler, add `role="button"`, `tabIndex={0}`, and proper keyboard handlers; otherwise, use `<button>`.

**Motion & shortcuts**

- Use CSS animations/transitions that respect `prefers-reduced-motion`. Keep markup free of obsolete movement tags; provide keyboard shortcuts via event handlers rather than `accessKey`.

### B) Code Complexity & Quality — Generate code that stays readable six months later

**Control flow & structure**

- Keep functions small and below your Cognitive Complexity threshold; split long ones.
- Prefer `for…of` (or `for (const [i,v] of arr.entries())` when you need the index) and `while` when you only need a condition; avoid loop gimmicks. Favor early returns over `else` ladders.
- Use arrow functions instead of function expressions. Keep parameters immutable; create new locals instead of reassigning parameters.

**APIs & idioms**

- Use rest parameters `(...args)` instead of the old `arguments` object.
- Use `Date.now()` for epoch milliseconds.
- Favor `arr.flatMap(fn)` over `arr.map(fn).flat()`.
- Access known properties with dot syntax (`obj.key`) rather than computed (`obj['key']`) unless the key is dynamic.
- Use optional chaining / nullish coalescing for concise guards (`a?.b ?? fallback`).

**Numbers, strings, and regex**

- Use numeric literals for binary/octal/hex (`0b…`, `0o…`, `0x…`) instead of `parseInt` tricks; when parsing strings, call `parseInt(str, 10)` or `Number.parseInt(str, 10)` with a radix.
- Use numeric separators in long literals (`1_000_000`).
- Prefer template literals over `+` concatenation (and don’t use templates when plain strings suffice).
- Prefer **regex literals** over `new RegExp` when static; declare reusable regexes at module scope; write minimal, valid patterns (no empty classes, no redundant escapes, no backreferences that always match empty).
- Represent whitespace intentionally in regex; don’t encode it via mystery sequences.

**Types & generics (language‑agnostic pieces)**

- Give generics real constraints (`<T extends Record<string, unknown>>`), not `any/unknown`, and don’t create empty type parameters.
- Don’t build fake “static namespaces” with classes; use modules/objects.

**Constructor/error hygiene**

- Keep constructors minimal; don’t return values from them.
- Throw `new Error('message')` (or a subclass), not plain values. Always include an error message.

**Performance-minded habits**

- Use assignment operator shorthands (`+=`, `||=`, `&&=`, `??=`) when they aid clarity.
- Avoid spreading accumulators in tight loops; mutate a local or push to an array and return a new object only when needed.

### C) React & JSX — Predictable components, predictable renders

**Hooks & components**

- Call React hooks **only** at the top level of function components and custom hooks. Provide complete dependency arrays; memoize handlers with `useCallback`/`useMemo` when appropriate.
- Define components at module scope, not inside other components.
- Treat props as immutable; compute derived state, don’t assign to props.

**Lists, keys, and children**

- Provide stable, meaningful `key` props (ids, not array indices).
- Pass children between tags, not via a `children` prop value in JSX.

**Events & roles**

- Attach event handlers to interactive elements; if you must use a non‑interactive element, give it an appropriate role and keyboard support. Avoid dangerous props; when `dangerouslySetInnerHTML` is truly necessary, sanitize the input and never combine it with `children`.

**JSX hygiene**

- Use fragment shorthand `<> … </>` instead of `<Fragment>`.
- Self‑close components without children; set each JSX prop once; keep stray semicolons out of JSX; don’t insert comments as text nodes.

**Cross‑framework note**

- In Solid projects, access props via accessors (e.g., `props.title`) rather than destructuring, to retain reactivity.

---

### D) Correctness & Safety — No foot‑guns, no time bombs

**Sound control flow**

- Remove unreachable code. Ensure `for`-loop updates move counters the right way. Keep `finally` for cleanup only, not control flow.
- Ensure `switch` statements are exhaustive (use a `never` check or a `default` that throws).

**Promises & async**

- Await or otherwise handle every promise; prefer `Promise.all` over `await` inside loops when independent.
- Construct promises with synchronous executors; put `async`/`await` logic _inside_ them, not on the executor itself.

**Types & runtime checks**

- Compare `typeof` results to valid strings (`"string"`, `"number"`, etc.).
- Use `Number.isNaN` and `Number.isFinite` for checks.
- Keep getters and setters adjacent; getters always return a value.
- Use `Object.hasOwn(obj, key)` (or its safe equivalent) inside `for…in`.

**Imports & modules**

- Use named (or explicit default) imports; avoid namespace/dynamic access to namespace imports. Break import cycles.
- Use `with { type: "json" }` for JSON imports where supported.
- Don’t mutate built‑ins or read‑only globals; never assign to imported bindings.

**Security & web hygiene**

- Load Google Fonts with a recommended strategy: `preconnect` to font hosts and a display mode like `display=swap`.
- When using `target="_blank"`, include `rel="noopener noreferrer"`.
- Keep secrets out of source; inject via environment/secret management.
- Use `Response.json()`/`Response.redirect()` where available instead of `new Response(...)`.

**Language pitfalls**

- Avoid self‑assignment, constant conditions, and value‑less expressions; separate assignment from comparison.
- Treat `document.cookie` via a safe helper (attributes, encoding) rather than writing raw strings.
- Prefer `===`/`!==`. Avoid bitwise operators unless intentionally manipulating bits.
- Avoid sparse arrays; use dense arrays or `Map`.
- Keep whitespace regular; avoid control characters in regex and strings.
- Ensure JSON/regex/string escapes are modern (no octal, no legacy `\8`/`\9` sequences).
- Don’t use `void` except as a function return type or generic parameter.

**ES modules vs. CommonJS caveats**

- In ESM, emulate `__dirname`/`__filename` with `import.meta.url` + `fileURLToPath`.

---

## E) TypeScript Best Practices — Strong types without drama

**General**

- Prefer unions of string/number literals (with `as const` objects) over `enum`.
  _If you must use `enum` in existing code, make all members literal values and set each member explicitly._
- Lean on inference: when a variable or property is initialized, omit redundant annotations.
- Keep types and values separate: use `export type` / `import type` for types.
- Maintain strictness: values must never drift to `any` via reassignment; use `unknown` at boundaries and refine with user‑defined **type guards** where needed (not non‑null assertions).
- Place overload signatures contiguously.
- Prefer ES modules; avoid TS “namespaces”. _If forced into legacy code, use the `namespace` keyword (not `module`) and keep it ambient‑only._

**Classes & fields**

- Declare fields explicitly; assign in the constructor (no parameter properties).
- In subclass constructors, call `super()` exactly once and before using `this`.

### F) Style & Consistency — Predictable across the codebase

**Core style**

- Use `const` for single‑assignment variables; `let` otherwise; never `var`.
- Prefer early returns; reduce nesting; use `else if` rather than deep `else { if (…) }`.
- Follow the project’s brace and spacing conventions; keep irregular whitespace out.
- Use `new` for built‑ins that are constructors (e.g., `Date`, `Map`, `Set`) and **not** for `String`, `Number`, or `Boolean`.

**Strings & numbers**

- Use `String.slice()` over `substr/substring`.
- Use `String.trimStart()` / `String.trimEnd()`.
- Prefer template literals over concatenation when interpolating.

**Operations & comparisons**

- Use exponent operator `**` over `Math.pow`.
- Don’t compare against `-0` unless you intentionally use `Object.is(x, -0)`.
- Keep logical expressions minimal (drop redundant `&& true`, `|| false`, etc.).

**Objects & arrays**

- Prefer object spread to `Object.assign` when creating new objects.
- Use `Array.isArray()` for array checks.
- Use `at()` for safe indexing.
- Keep object literals consistent and without duplicate keys; don’t redeclare in the same scope.

**Diagnostics**

- Replace `console.*` and `debugger` with the project’s logging and debugging facilities.

**Switches & errors**

- Put the `default`/exhaustive case last; break every case unless intentionally falling through with a comment.
- Always construct built‑in errors with a message: `new TypeError('…')`.

### H) Testing — Reliable suites, no landmines

- Keep tests runnable as a full suite: no focused or skipped tests (`.only`, `.skip`).
- Place assertions (`expect`, etc.) **inside** `it`/`test` blocks.
- Use ES module imports in tests; keep test files free of exports unless the runner requires them.
- Keep `describe` nesting shallow and hooks non‑duplicated; avoid callback‑style async tests—use promises/async‑await.
