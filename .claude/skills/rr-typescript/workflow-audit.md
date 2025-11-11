# Workflow Audit for rr-typescript

## ✓ Passed

- Workflow section exists ("Workflow" starting line 179)
- Three workflow subsections: Writing New Code, Reviewing Code, Refactoring
- Some checklist-like structures in workflows
- Good conditional detection patterns (Runtime Detection, Test Framework Detection)
- Core Principles section provides guidance (lines 95-174)
- Reference files support detailed workflows

## ✗ Missing/Needs Improvement

- Workflows lack explicit checkbox format
- No numbered sequential steps in workflows
- No comprehensive Development Workflow section
- Missing Plan-Validate-Execute structure
- No testing workflow (delegated to references only)
- No deployment/production readiness workflow
- Conditional sections (Runtime Detection, Test Framework Detection) are detection logic, not workflows
- No feedback loops explicitly structured
- No rollback/recovery procedures
- Missing quality gate workflow before commit

## Recommendations

1. **Add Development Workflow section before existing Workflow section**:

   ```markdown
   ## Development Workflow

   ### 1. Plan Implementation

   **Before writing code:**

   - [ ] Understand requirements clearly
   - [ ] Design type interfaces and schemas
   - [ ] Plan component structure (if React)
   - [ ] Identify reusable utilities needed
   - [ ] Consider accessibility requirements
   - [ ] Plan error handling strategy

   ### 2. Write Code

   - [ ] Define TypeScript interfaces first
   - [ ] Write implementation with type annotations
   - [ ] Use modern JavaScript (ES6+, async/await)
   - [ ] Follow accessibility guidelines (semantic HTML, ARIA)
   - [ ] Handle errors appropriately
   - [ ] Keep functions focused and under 30 lines
   - [ ] Use descriptive names (no abbreviations)

   ### 3. Quality Checks

   - [ ] Run Ultracite: `bunx ultracite fix`
   - [ ] Resolve all type errors
   - [ ] Fix all linting errors
   - [ ] Verify formatting applied correctly
   - [ ] Review accessibility warnings
   - [ ] Check for console statements (remove)

   ### 4. Testing

   - [ ] Write unit tests for logic
   - [ ] Test edge cases (null, undefined, empty)
   - [ ] Test error handling
   - [ ] Run tests: Framework-specific command
   - [ ] Verify coverage is adequate
   - [ ] Fix failing tests

   ### 5. Code Review

   - [ ] Review own code for clarity
   - [ ] Check type safety (no `any` types)
   - [ ] Verify accessibility compliance
   - [ ] Ensure no security issues (XSS, injection)
   - [ ] Confirm no secrets in code
   - [ ] Run final quality check

   ### 6. Commit

   - [ ] Stage only relevant files
   - [ ] Write clear commit message
   - [ ] Run pre-commit hooks
   - [ ] Push changes
   ```

2. **Convert existing workflows to checkbox format**:

   ```markdown
   ## Implementation Workflows

   ### Writing New Code Workflow

   - [ ] **Start with types**: Define interfaces and types before implementation
   - [ ] **Use inference**: Let TypeScript infer types when obvious
   - [ ] **Build incrementally**: Write small, testable functions
   - [ ] **Run Ultracite**: `bunx ultracite fix` to format and catch issues
   - [ ] **Validate types**: Ensure no `any` types leak into code
   - [ ] **Test as you go**: Write tests alongside implementation
   - [ ] **Review accessibility**: Verify semantic HTML and ARIA usage

   ### Reviewing Code Workflow

   - [ ] **Check accessibility**: Verify semantic HTML, ARIA, and keyboard support
   - [ ] **Verify type safety**: Look for `any`, missing types, or type assertions
   - [ ] **Assess complexity**: Ensure functions are focused and maintainable
   - [ ] **Review security**: Check for XSS, injection vulnerabilities, and secrets
   - [ ] **Run checks**: `bunx ultracite check` to verify compliance
   - [ ] **Test coverage**: Ensure adequate test coverage
   - [ ] **Provide feedback**: Clear, actionable review comments

   ### Refactoring Workflow

   - [ ] **Preserve behavior**: Use tests to verify unchanged functionality
   - [ ] **Improve types**: Replace `any` with proper types, add generics
   - [ ] **Simplify logic**: Extract functions, reduce nesting, use early returns
   - [ ] **Enhance accessibility**: Add semantic HTML and ARIA where needed
   - [ ] **Validate changes**: Run `bunx ultracite fix`
   - [ ] **Test thoroughly**: Verify all tests pass
   - [ ] **Verify no regressions**: Check existing functionality unaffected
   ```

3. **Add Testing Workflow**:

   ```markdown
   ### Testing Workflow

   **Detect test framework first:**

   - [ ] Check for `vitest.config.ts` → Use Vitest
   - [ ] Check for `bun.lockb` → Use Bun test
   - [ ] Check for `jest.config.js` → Use Jest
   - [ ] If Vitest: Load `references/vitest-testing.md`
   - [ ] If Bun: Load `references/bun-runtime.md`

   **Write tests:**

   - [ ] Create test file with appropriate naming (`.test.ts`, `.spec.ts`)
   - [ ] Import test utilities from framework
   - [ ] Write test cases for happy path
   - [ ] Write test cases for edge cases
   - [ ] Write test cases for error conditions
   - [ ] Use descriptive test names
   - [ ] Keep tests focused and isolated

   **Run tests:**

   - [ ] Run all tests: Framework-specific command
   - [ ] Verify all pass
   - [ ] Check coverage report
   - [ ] Fix failing tests
   - [ ] Repeat until clean
   ```

4. **Add Runtime-Specific Workflows**:

   ```markdown
   ### Runtime Detection and Selection

   **Detect Bun usage:**

   - [ ] Check for `bun.lockb` file
   - [ ] Check for `bunfig.toml` file
   - [ ] Check `package.json` for Bun references
   - [ ] If Bun detected: Load `references/bun-runtime.md`
   - [ ] If Bun detected: Use Bun-specific APIs and patterns

   **If using Bun:**

   - [ ] Use `bun` instead of `node`
   - [ ] Use `bun test` instead of Jest/Vitest
   - [ ] Use `Bun.serve()` instead of Express
   - [ ] Use `bun:sqlite` instead of better-sqlite3
   - [ ] Use `Bun.file` instead of `fs.readFile`
   - [ ] Leverage built-in APIs (WebSocket, Redis, SQL)

   **If using Node.js:**

   - [ ] Use standard npm/yarn/pnpm commands
   - [ ] Use Express or Fastify for servers
   - [ ] Use standard database libraries
   - [ ] Use dotenv for environment variables
   ```

5. **Add Production Readiness Workflow**:

   ```markdown
   ### Production Readiness Checklist

   **Code quality:**

   - [ ] All Ultracite checks pass: `bunx ultracite check`
   - [ ] No TypeScript errors: `tsc --noEmit`
   - [ ] All tests pass
   - [ ] Coverage meets targets (>80%)
   - [ ] No console statements in production code
   - [ ] No debugger statements
   - [ ] No commented-out code

   **Security:**

   - [ ] No secrets or API keys in code
   - [ ] All user input validated
   - [ ] XSS protection implemented
   - [ ] SQL injection protection (parameterized queries)
   - [ ] Dependencies checked for vulnerabilities
   - [ ] HTTPS enforced in production

   **Accessibility:**

   - [ ] All interactive elements keyboard accessible
   - [ ] Proper focus management
   - [ ] ARIA labels where needed
   - [ ] Semantic HTML used
   - [ ] Color contrast meets WCAG standards
   - [ ] Screen reader tested

   **Performance:**

   - [ ] No memory leaks
   - [ ] Efficient algorithms used
   - [ ] Images optimized
   - [ ] Bundle size reasonable
   - [ ] Lazy loading implemented where beneficial
   ```

6. **Add Troubleshooting Workflow**:

   ```markdown
   ### Troubleshooting Workflow

   **Type errors:**

   - [ ] Read error message carefully
   - [ ] Check type definitions
   - [ ] Verify imports are correct
   - [ ] Use type guards for narrowing
   - [ ] Check for `any` types leaking
   - [ ] Run `tsc --noEmit` for full type check

   **Linting errors:**

   - [ ] Run `bunx ultracite check` to see all issues
   - [ ] Read rule documentation (error message includes link)
   - [ ] Fix auto-fixable issues: `bunx ultracite fix`
   - [ ] Manually fix remaining issues
   - [ ] If rule is incorrect: Document why and disable with comment

   **Test failures:**

   - [ ] Read failure message
   - [ ] Run single test: Framework-specific command
   - [ ] Add console.log for debugging
   - [ ] Check test assumptions
   - [ ] Verify mocks are correct
   - [ ] Fix code or update test
   - [ ] Remove debug logging

   **Build failures:**

   - [ ] Check for TypeScript errors first
   - [ ] Verify all dependencies installed
   - [ ] Check for syntax errors
   - [ ] Review build configuration
   - [ ] Clear cache and rebuild
   ```
