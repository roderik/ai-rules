# Evaluation Scenarios for rr-typescript

## Scenario 1: Basic Usage - Write Type-Safe Component

**Input:** "Create a TypeScript React component for a user profile card with props for name, email, avatar URL, and an optional bio"

**Expected Behavior:**

- Automatically activate for TypeScript/React code
- Check for Bun runtime (look for bun.lockb)
- Define proper TypeScript interface for props
- Use explicit types (no implicit any)
- Mark optional props with ?
- Include proper React.FC or component function type
- Add accessibility attributes (ARIA)
- Follow TypeScript best practices from SKILL.md
- Use 2-space indentation

**Success Criteria:**

- [ ] Interface defined for props (UserProfileProps)
- [ ] All props properly typed (name: string, email: string, avatarUrl: string, bio?: string)
- [ ] Optional bio marked with ?
- [ ] Component typed as React.FC<UserProfileProps> or function with explicit return type
- [ ] No any types used
- [ ] ARIA attributes included (role, aria-label where appropriate)
- [ ] Accessible HTML (semantic elements, alt text for images)
- [ ] 2-space indentation
- [ ] Follows code style from SKILL.md

## Scenario 2: Complex Scenario - Generic Type Utility with Conditional Types

**Input:** "Create a TypeScript utility type that extracts all properties from an object type where the value is a function. Also create a type that converts all function properties to their return types. Test it with a sample API service object."

**Expected Behavior:**

- Load skill and recognize advanced TypeScript patterns
- Create mapped type with conditional types
- Use keyof and indexed access types
- Implement proper type constraints
- Create FunctionProperties<T> utility
- Create FunctionReturnTypes<T> utility
- Provide example usage with API service
- Ensure type inference works correctly
- Add explanatory comments
- Reference advanced TypeScript patterns

**Success Criteria:**

- [ ] FunctionProperties<T> uses mapped types and conditional types
- [ ] Correctly filters only function properties
- [ ] FunctionReturnTypes<T> extracts return types
- [ ] Uses ReturnType<T> utility type
- [ ] Proper type constraints (extends Record<string, any>)
- [ ] Example API service object provided
- [ ] Type inference demonstrated
- [ ] No errors when testing utility types
- [ ] Code includes explanatory comments
- [ ] Follows TypeScript advanced patterns

## Scenario 3: Error Handling - Vitest Test Setup

**Input:** "I want to set up Vitest for testing my TypeScript code. Can you help me configure it?"

**Expected Behavior:**

- Check for existing test framework (look for vitest.config.ts)
- Check for Bun project (bun.lockb)
- If Bun detected:
  - Recommend bun:test instead
  - Load `references/bun-runtime.md`
  - Show Bun test examples
- If Vitest appropriate:
  - Load `references/vitest-testing.md`
  - Create vitest.config.ts
  - Install dependencies (vitest, @vitest/ui)
  - Configure for TypeScript
  - Show example test file
  - Add test scripts to package.json
- Explain trade-offs between options

**Success Criteria:**

- [ ] Checks for bun.lockb to detect Bun project
- [ ] Checks for existing vitest.config.ts
- [ ] If Bun: recommends bun:test, loads bun-runtime.md
- [ ] If Bun: shows bun test syntax examples
- [ ] If Vitest: loads vitest-testing.md
- [ ] If Vitest: creates proper vitest.config.ts
- [ ] If Vitest: configures TypeScript support
- [ ] If Vitest: provides example test file
- [ ] If Vitest: adds test scripts to package.json
- [ ] Explains when to use each framework
- [ ] References appropriate documentation
