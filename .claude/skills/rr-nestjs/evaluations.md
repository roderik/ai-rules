# Evaluation Scenarios for rr-nestjs

## Scenario 1: Basic Usage - Create User Controller

**Input:** "Create a new NestJS controller for managing users with CRUD endpoints"

**Expected Behavior:**

- Automatically activate when "NestJS controller" is mentioned
- Generate controller with proper decorators (@Controller, @Get, @Post, etc.)
- Include CRUD methods (create, read, update, delete)
- Add proper TypeScript types and DTOs
- Include validation decorators
- Add Swagger/OpenAPI decorators
- Follow NestJS naming conventions

**Success Criteria:**

- [ ] Controller file created with correct naming (users.controller.ts)
- [ ] All CRUD methods present (create, findAll, findOne, update, remove)
- [ ] Proper dependency injection used (constructor injection)
- [ ] Swagger decorators added (@ApiTags, @ApiOperation, @ApiResponse)
- [ ] HTTP decorators correct (@Get, @Post, @Patch, @Delete)
- [ ] Validation pipes referenced or implemented
- [ ] Follows code style from SKILL.md examples

## Scenario 2: Complex Scenario - Full Feature Module with Auth

**Input:** "Build a complete posts module with authentication using JWT guards. Include database integration with MikroORM, validation, and Swagger documentation. Users should only be able to edit their own posts."

**Expected Behavior:**

- Load skill automatically based on NestJS mention
- Create complete module structure:
  - posts.module.ts
  - posts.controller.ts
  - posts.service.ts
  - dto/create-post.dto.ts, dto/update-post.dto.ts
  - entities/post.entity.ts
  - guards/post-owner.guard.ts
- Implement JWT authentication guard
- Add MikroORM entity with relationships to User
- Implement ownership verification guard
- Add comprehensive Swagger documentation
- Include error handling
- Write unit tests for service
- Reference `references/nestjs-patterns.md` for implementation details

**Success Criteria:**

- [ ] Complete module structure created
- [ ] MikroORM entity defined with @Entity decorator
- [ ] DTOs have class-validator decorators (@IsString, @IsNotEmpty, etc.)
- [ ] JWT guard applied to protected routes (@UseGuards(JwtAuthGuard))
- [ ] Custom guard created to verify post ownership
- [ ] Service uses proper dependency injection with @InjectRepository
- [ ] Swagger decorators comprehensive (@ApiTags, @ApiOperation, @ApiResponse, @ApiBearerAuth)
- [ ] Unit tests created for service methods
- [ ] Error handling with NestJS exceptions (NotFoundException, ForbiddenException)
- [ ] Module exports service for use in other modules

## Scenario 3: Error Handling - Circular Dependency

**Input:** "I'm getting a 'Cannot resolve dependencies' error when trying to inject PostsService into UsersService, and UsersService is already injected into PostsService."

**Expected Behavior:**

- Recognize circular dependency issue from error description
- Reference `references/nestjs-patterns.md` or troubleshooting section
- Explain the circular dependency problem
- Provide solution using forwardRef()
- Show proper implementation in both modules
- Explain alternative approaches (separate shared service, events)
- Verify module configuration

**Success Criteria:**

- [ ] Identifies circular dependency as the root cause
- [ ] Provides forwardRef() solution with code example
- [ ] Shows correct usage in both module imports
- [ ] Explains when to use forwardRef() vs restructuring
- [ ] Suggests alternative patterns to avoid circular deps
- [ ] References troubleshooting section from SKILL.md
- [ ] Validates that both modules are properly configured
